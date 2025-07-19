import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/services/notification_service.dart';
import 'app/core/error_handler.dart';
import 'app/services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling
  final errorHandler = ErrorHandler();
  
  // Initialize connectivity service
  final connectivityService = ConnectivityService();
  try {
    await connectivityService.initialize();
  } catch (e) {
    errorHandler.logError(errorHandler.categorizeError(e));
  }
  
  // Initialize notification service
  final notificationService = NotificationService();
  try {
    await notificationService.initialize();
  } catch (e) {
    errorHandler.logError(errorHandler.categorizeError(e));
  }
  
  runApp(
    GetMaterialApp(
      title: "Sanyin",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
