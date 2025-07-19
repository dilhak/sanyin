import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/error_handler.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final ErrorHandler _errorHandler = ErrorHandler();
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _isConnected = result != ConnectivityResult.none;
      
      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (ConnectivityResult result) {
          final wasConnected = _isConnected;
          _isConnected = result != ConnectivityResult.none;
          
          if (wasConnected && !_isConnected) {
            _errorHandler.showWarningSnackbar('No internet connection');
          } else if (!wasConnected && _isConnected) {
            _errorHandler.showInfoSnackbar('Internet connection restored');
          }
        },
        onError: (error) {
          _errorHandler.logError(_errorHandler.categorizeError(error));
        },
      );
    } catch (e) {
      _errorHandler.logError(_errorHandler.categorizeError(e));
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = result != ConnectivityResult.none;
      return _isConnected;
    } catch (e) {
      _errorHandler.logError(_errorHandler.categorizeError(e));
      return false;
    }
  }

  Future<T> withConnectivityCheck<T>(Future<T> Function() operation) async {
    if (!_isConnected) {
      throw AppError(
        message: 'No internet connection',
        type: ErrorType.network,
      );
    }
    
    try {
      return await operation();
    } catch (e) {
      if (e is AppError) rethrow;
      
      // Check if it's a network error
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('timeout')) {
        throw AppError(
          message: 'Network connection issue',
          type: ErrorType.network,
          originalError: e,
        );
      }
      
      rethrow;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
} 