import 'dart:async';
import 'dart:math';
import '../core/error_handler.dart';

class RetryMechanism {
  static final RetryMechanism _instance = RetryMechanism._internal();
  factory RetryMechanism() => _instance;
  RetryMechanism._internal();

  final ErrorHandler _errorHandler = ErrorHandler();
  final Random _random = Random();

  /// Retry an operation with exponential backoff
  Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool showRetryMessage = true,
    String? operationName,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        if (attempt >= maxAttempts) {
          // Final attempt failed
          if (showRetryMessage) {
            _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
          }
          rethrow;
        }

        // Log retry attempt
        final opName = operationName ?? 'Operation';
        print('$opName failed (attempt $attempt/$maxAttempts), retrying in ${delay.inSeconds}s...');
        
        if (showRetryMessage) {
          _errorHandler.showWarningSnackbar('$opName failed, retrying... (${attempt + 1}/$maxAttempts)');
        }

        // Wait before retry with exponential backoff and jitter
        await Future.delayed(delay + Duration(milliseconds: _random.nextInt(1000)));
        
        // Increase delay for next attempt
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }

    throw Exception('All retry attempts failed');
  }

  /// Retry with custom retry condition
  Future<T> retryWithCondition<T>(
    Future<T> Function() operation, {
    required bool Function(dynamic error) shouldRetry,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    bool showRetryMessage = true,
    String? operationName,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        if (attempt >= maxAttempts || !shouldRetry(e)) {
          // Final attempt failed or error is not retryable
          if (showRetryMessage) {
            _errorHandler.showErrorSnackbar(_errorHandler.categorizeError(e));
          }
          rethrow;
        }

        // Log retry attempt
        final opName = operationName ?? 'Operation';
        print('$opName failed (attempt $attempt/$maxAttempts), retrying in ${delay.inSeconds}s...');
        
        if (showRetryMessage) {
          _errorHandler.showWarningSnackbar('$opName failed, retrying... (${attempt + 1}/$maxAttempts)');
        }

        // Wait before retry
        await Future.delayed(delay);
        
        // Increase delay for next attempt
        delay = Duration(milliseconds: (delay.inMilliseconds * 2).round());
      }
    }

    throw Exception('All retry attempts failed');
  }

  /// Check if an error is retryable
  bool isRetryableError(dynamic error) {
    if (error is AppError) {
      // Don't retry validation errors
      if (error.type == ErrorType.validation) {
        return false;
      }
      
      // Don't retry permission errors
      if (error.type == ErrorType.permission) {
        return false;
      }
      
      // Retry network, database, and unknown errors
      return error.type == ErrorType.network || 
             error.type == ErrorType.database || 
             error.type == ErrorType.unknown;
    }
    
    // For non-AppError exceptions, check the error message
    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') ||
           errorString.contains('connection') ||
           errorString.contains('network') ||
           errorString.contains('database') ||
           errorString.contains('temporary') ||
           errorString.contains('unavailable');
  }

  /// Retry database operations
  Future<T> retryDatabaseOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    bool showRetryMessage = true,
    String? operationName,
  }) async {
    return retryWithCondition(
      operation,
      shouldRetry: isRetryableError,
      maxAttempts: maxAttempts,
      showRetryMessage: showRetryMessage,
      operationName: operationName ?? 'Database operation',
    );
  }

  /// Retry network operations
  Future<T> retryNetworkOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    bool showRetryMessage = true,
    String? operationName,
  }) async {
    return retryWithCondition(
      operation,
      shouldRetry: (error) {
        if (error is AppError) {
          return error.type == ErrorType.network;
        }
        final errorString = error.toString().toLowerCase();
        return errorString.contains('network') ||
               errorString.contains('connection') ||
               errorString.contains('timeout');
      },
      maxAttempts: maxAttempts,
      showRetryMessage: showRetryMessage,
      operationName: operationName ?? 'Network operation',
    );
  }

  /// Retry file operations
  Future<T> retryFileOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 2,
    bool showRetryMessage = true,
    String? operationName,
  }) async {
    return retryWithCondition(
      operation,
      shouldRetry: (error) {
        if (error is AppError) {
          return error.type == ErrorType.file;
        }
        final errorString = error.toString().toLowerCase();
        return errorString.contains('file') ||
               errorString.contains('permission') ||
               errorString.contains('access');
      },
      maxAttempts: maxAttempts,
      showRetryMessage: showRetryMessage,
      operationName: operationName ?? 'File operation',
    );
  }
} 