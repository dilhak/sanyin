import 'package:get/get.dart';
import '../controllers/care_log_history_controller.dart';

class CareLogHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CareLogHistoryController>(
      () => CareLogHistoryController(),
    );
  }
} 