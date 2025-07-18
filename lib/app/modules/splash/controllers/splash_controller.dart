import 'package:flutter_demo/app/services/splash_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  SplashService splashService = SplashService.instance;

  @override
  void onInit() {
    super.onInit();
    splashService.checkUserLogin();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
