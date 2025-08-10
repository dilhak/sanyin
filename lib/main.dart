import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/services/notification_service.dart';
import 'app/core/error_handler.dart';
import 'app/core/memory_manager.dart';
import 'app/core/app_lifecycle_manager.dart';
import 'app/services/connectivity_service.dart';
import 'app/services/database_service.dart';
import 'app/services/photo_service.dart';
import 'app/services/keyboard_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling first
  final errorHandler = ErrorHandler();
  
  // Initialize app lifecycle manager
  final lifecycleManager = AppLifecycleManager();
  lifecycleManager.initialize();
  
  // Initialize services
  final connectivityService = ConnectivityService();
  final notificationService = NotificationService();
  final databaseService = DatabaseService();
  final photoService = PhotoService();
  final keyboardService = KeyboardService();
  
  // Initialize all critical services with proper error handling
  bool initializationSuccessful = true;
  
  try {
    // Initialize connectivity service
    await connectivityService.initialize();
  } catch (e) {
    initializationSuccessful = false;
    errorHandler.logError(errorHandler.categorizeError(e));
    print('Critical: Failed to initialize connectivity service: $e');
  }
  
  try {
    // Initialize notification service
    await notificationService.initialize();
  } catch (e) {
    errorHandler.logError(errorHandler.categorizeError(e));
    print('Warning: Failed to initialize notification service: $e');
    // Notifications are not critical for app startup
  }
  
  try {
    // Initialize database service early to catch any issues
    await databaseService.database;
  } catch (e) {
    initializationSuccessful = false;
    errorHandler.logError(errorHandler.categorizeError(e));
    print('Critical: Failed to initialize database service: $e');
  }
  
  // Register services for disposal only if they initialized successfully
  Get.put(connectivityService);
  Get.put(notificationService);
  Get.put(databaseService);
  Get.put(photoService);
  Get.put(keyboardService);
  
  // Log initial memory usage
  MemoryManager.logMemoryUsage();
  
  if (!initializationSuccessful) {
    print('App starting with degraded functionality due to initialization failures');
  }
  
  runApp(
    GetMaterialApp(
      title: "Sanyin",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        // Log route changes for debugging
        print('Navigating to: ${settings.name}');
        return null;
      },
    ),
  );
}
