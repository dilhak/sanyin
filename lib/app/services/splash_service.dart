// service file here for the business logic of the splash screen
// use this file to handle the business logic and connect the file to the controller

import 'package:sanyin/app/routes/app_pages.dart';
import 'package:get/get.dart';

class SplashService {
  SplashService._();

  static final SplashService instance = SplashService._();

  Future<void> checkUserLogin() async {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(Routes.CLIENT_DASHBOARD);
    });
  }
}
