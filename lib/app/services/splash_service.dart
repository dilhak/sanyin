// service file here for the business logic of the splash screen
// use this file to handle the business logic and connect the file to the controller

import 'package:sanyin/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../core/error_handler.dart';
import '../services/database_service.dart';

class SplashService {
  SplashService._();

  static final SplashService instance = SplashService._();

  Future<void> checkUserLogin() async {
    try {
      // Ensure critical services are available before proceeding
      final databaseService = Get.find<DatabaseService>();
      
      // Verify database is accessible
      await databaseService.database;
      
      // Proceed to main dashboard after verification
      await Future.delayed(const Duration(seconds: 2));
      
      if (Get.currentRoute != Routes.CLIENT_DASHBOARD) {
        Get.offAllNamed(Routes.CLIENT_DASHBOARD);
      }
    } catch (e) {
      print('Splash service error: $e');
      final errorHandler = ErrorHandler();
      errorHandler.logError(errorHandler.categorizeError(e));
      
      // Still navigate but with degraded functionality
      await Future.delayed(const Duration(seconds: 2));
      if (Get.currentRoute != Routes.CLIENT_DASHBOARD) {
        Get.offAllNamed(Routes.CLIENT_DASHBOARD);
      }
    }
  }
}
