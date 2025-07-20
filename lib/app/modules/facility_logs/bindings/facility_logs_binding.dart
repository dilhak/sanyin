import 'package:get/get.dart';
import '../controllers/facility_logs_controller.dart';

class FacilityLogsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FacilityLogsController>(() => FacilityLogsController());
  }
} 