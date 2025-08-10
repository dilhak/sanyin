import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import 'memory_manager.dart';

class AppLifecycleManager extends WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  bool _isInitialized = false;

  void initialize() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addObserver(this);
      _isInitialized = true;
      print('AppLifecycleManager initialized');
    }
  }

  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
      print('AppLifecycleManager disposed');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    print('App lifecycle state changed to: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  void _handleAppResumed() {
    print('App resumed - performing health checks');
    
    // Verify critical services are still available
    _verifyServicesHealth();
  }

  void _handleAppPaused() {
    print('App paused - performing cleanup');
    
    // Perform memory cleanup
    MemoryManager.clearReactiveVariables();
    
    // Close any open dialogs
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    
    // Close any open snackbars
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  }

  void _handleAppDetached() {
    print('App detached - final cleanup');
    
    // Dispose of services if needed
    _disposeServices();
  }

  void _handleAppInactive() {
    print('App inactive');
    // App is transitioning between foreground and background
  }

  void _handleAppHidden() {
    print('App hidden');
    // App is hidden but still running
  }

  Future<void> _verifyServicesHealth() async {
    try {
      // Check if database is still accessible
      if (Get.isRegistered<DatabaseService>()) {
        final dbService = Get.find<DatabaseService>();
        await dbService.database;
        print('Database service health check: OK');
      }
      
      // Check connectivity service
      if (Get.isRegistered<ConnectivityService>()) {
        final connectivityService = Get.find<ConnectivityService>();
        await connectivityService.checkConnectivity();
        print('Connectivity service health check: OK');
      }
    } catch (e) {
      print('Service health check failed: $e');
      // Could trigger a service restart or error recovery here
    }
  }

  void _disposeServices() {
    try {
      // Dispose connectivity service
      if (Get.isRegistered<ConnectivityService>()) {
        final connectivityService = Get.find<ConnectivityService>();
        connectivityService.dispose();
      }
      
      print('Services disposed successfully');
    } catch (e) {
      print('Error disposing services: $e');
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    print('Memory pressure detected - performing aggressive cleanup');
    
    // Perform aggressive memory cleanup
    MemoryManager.forceGarbageCollection();
    MemoryManager.clearReactiveVariables();
    MemoryManager.cleanupGetXResources();
  }
}

