import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/services/notification_service.dart';
import 'app/core/error_handler.dart';
import 'app/core/memory_manager.dart';
import 'app/services/connectivity_service.dart';
import 'app/services/database_service.dart';
import 'app/services/photo_service.dart';
import 'app/services/keyboard_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling
  final errorHandler = ErrorHandler();
  
  // Initialize services
  final connectivityService = ConnectivityService();
  final notificationService = NotificationService();
  final databaseService = DatabaseService();
  final photoService = PhotoService();
  final keyboardService = KeyboardService();
  
  try {
    await connectivityService.initialize();
    await notificationService.initialize();
  } catch (e) {
    errorHandler.logError(errorHandler.categorizeError(e));
  }
  
  // Register services for disposal
  Get.put(connectivityService);
  Get.put(notificationService);
  Get.put(databaseService);
  Get.put(photoService);
  Get.put(keyboardService);
  
  // Log initial memory usage
  MemoryManager.logMemoryUsage();
  
  runApp(
    GetMaterialApp(
      title: "Sanyin",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
