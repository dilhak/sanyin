import 'package:get/get.dart';
import '../controllers/edit_client_controller.dart';

class EditClientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditClientController>(
      () => EditClientController(),
    );
  }
} 