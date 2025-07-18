import 'package:get/get.dart';
import '../controllers/quick_actions_controller.dart';

class QuickActionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuickActionsController>(
      () => QuickActionsController(),
    );
  }
} 