import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ErrorType {
  network,
  database,
  validation,
  permission,
  file,
  unknown,
}

class AppError {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    required this.type,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppError($type): $message';
}

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Error categorization
  AppError categorizeError(dynamic error) {
    if (error is AppError) return error;

    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('database') || 
        errorString.contains('sql') || 
        errorString.contains('table') ||
        errorString.contains('constraint')) {
      return AppError(
        message: 'Database operation failed',
        type: ErrorType.database,
        originalError: error,
      );
    }
    
    if (errorString.contains('permission') || 
        errorString.contains('denied') ||
        errorString.contains('camera') ||
        errorString.contains('storage')) {
      return AppError(
        message: 'Permission denied',
        type: ErrorType.permission,
        originalError: error,
      );
    }
    
    if (errorString.contains('file') || 
        errorString.contains('path') ||
        errorString.contains('photo') ||
        errorString.contains('image')) {
      return AppError(
        message: 'File operation failed',
        type: ErrorType.file,
        originalError: error,
      );
    }
    
    if (errorString.contains('validation') || 
        errorString.contains('invalid') ||
        errorString.contains('required')) {
      return AppError(
        message: 'Validation failed',
        type: ErrorType.validation,
        originalError: error,
      );
    }
    
    return AppError(
      message: 'An unexpected error occurred',
      type: ErrorType.unknown,
      originalError: error,
    );
  }

  // User-friendly error messages
  String getUserFriendlyMessage(AppError error) {
    switch (error.type) {
      case ErrorType.database:
        return 'Unable to save or retrieve data. Please try again.';
      case ErrorType.permission:
        return 'Permission required. Please grant the necessary permissions in settings.';
      case ErrorType.file:
        return 'Unable to access or save file. Please check storage permissions.';
      case ErrorType.validation:
        return error.message;
      case ErrorType.network:
        return 'Network connection issue. Please check your internet connection.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  // Error logging
  void logError(AppError error) {
    print('=== ERROR LOG ===');
    print('Type: ${error.type}');
    print('Message: ${error.message}');
    print('Original Error: ${error.originalError}');
    if (error.stackTrace != null) {
      print('Stack Trace: ${error.stackTrace}');
    }
    print('================');
  }

  // Show error snackbar
  void showErrorSnackbar(AppError error) {
    final message = getUserFriendlyMessage(error);
    final color = _getErrorColor(error.type);
    
    Get.snackbar(
      'Error',
      message,
      backgroundColor: color.withValues(alpha: 0.1),
      colorText: color,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: Icon(Icons.error_outline, color: color),
    );
  }

  // Show success snackbar
  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.withValues(alpha: 0.1),
      colorText: Colors.green,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: Colors.green),
    );
  }

  // Show warning snackbar
  void showWarningSnackbar(String message) {
    Get.snackbar(
      'Warning',
      message,
      backgroundColor: Colors.orange.withValues(alpha: 0.1),
      colorText: Colors.orange,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.warning, color: Colors.orange),
    );
  }

  // Show info snackbar
  void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      colorText: Colors.blue,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.info, color: Colors.blue),
    );
  }

  // Get error color based on type
  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.database:
        return Colors.red;
      case ErrorType.permission:
        return Colors.orange;
      case ErrorType.file:
        return Colors.red;
      case ErrorType.validation:
        return Colors.orange;
      case ErrorType.network:
        return Colors.blue;
      case ErrorType.unknown:
        return Colors.red;
    }
  }

  // Handle errors with try-catch wrapper
  Future<T> handleAsync<T>(Future<T> Function() operation, {
    String? customErrorMessage,
    bool showError = true,
    bool logError = true,
  }) async {
    try {
      return await operation();
    } catch (error) {
      final appError = categorizeError(error);
      
      if (customErrorMessage != null) {
        // Create a new AppError with custom message
        final customError = AppError(
          message: customErrorMessage,
          type: appError.type,
          originalError: appError.originalError,
          stackTrace: appError.stackTrace,
        );
        
        if (logError) {
          this.logError(customError);
        }
        
        if (showError) {
          showErrorSnackbar(customError);
        }
        
        rethrow;
      }
      
              if (logError) {
          this.logError(appError);
        }
      
      if (showError) {
        showErrorSnackbar(appError);
      }
      
      rethrow;
    }
  }

  // Handle synchronous errors
  T handleSync<T>(T Function() operation, {
    String? customErrorMessage,
    bool showError = true,
    bool logError = true,
  }) {
    try {
      return operation();
    } catch (error) {
      final appError = categorizeError(error);
      
      if (customErrorMessage != null) {
        // Create a new AppError with custom message
        final customError = AppError(
          message: customErrorMessage,
          type: appError.type,
          originalError: appError.originalError,
          stackTrace: appError.stackTrace,
        );
        
        if (logError) {
          this.logError(customError);
        }
        
        if (showError) {
          showErrorSnackbar(customError);
        }
        
        rethrow;
      }
      
              if (logError) {
          this.logError(appError);
        }
      
      if (showError) {
        showErrorSnackbar(appError);
      }
      
      rethrow;
    }
  }
} 