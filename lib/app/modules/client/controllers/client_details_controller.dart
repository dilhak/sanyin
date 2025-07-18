import 'package:get/get.dart';
import '../models/client_model.dart';
import '../../../routes/app_pages.dart';

class ClientDetailsController extends GetxController {
  late Client client;
  
  @override
  void onInit() {
    super.onInit();
    client = Get.arguments as Client;
  }

  void openQuickActions() {
    Get.toNamed(Routes.QUICK_ACTIONS, arguments: client);
  }

  void openCareHistory() {
    Get.toNamed(Routes.CARE_LOG_HISTORY, arguments: client);
  }

  void editClient() {
    Get.toNamed('/client/edit', arguments: client);
  }

  void takePhoto() {
    Get.toNamed(Routes.PHOTO_CAPTURE, arguments: client);
  }

  void goBack() {
    Get.back();
  }
} 