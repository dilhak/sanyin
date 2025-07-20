import 'package:get/get.dart';

import '../modules/tasks/bindings/tasks_binding.dart';
import '../modules/tasks/views/tasks_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/client/bindings/client_dashboard_binding.dart';
import '../modules/client/views/client_dashboard_view.dart';
import '../modules/client/bindings/add_client_binding.dart';
import '../modules/client/views/add_client_view.dart';
import '../modules/client/bindings/client_details_binding.dart';
import '../modules/client/views/client_details_view.dart';
import '../modules/client/bindings/edit_client_binding.dart';
import '../modules/client/views/edit_client_view.dart';
import '../modules/care_log/bindings/quick_actions_binding.dart';
import '../modules/care_log/views/quick_actions_view.dart';
import '../modules/care_log/bindings/care_log_history_binding.dart';
import '../modules/care_log/views/care_log_history_view.dart';
import '../modules/care_log/bindings/photo_capture_binding.dart';
import '../modules/care_log/views/photo_capture_view.dart';
import '../modules/home/views/facility_history_view.dart';
import '../modules/facility_logs/bindings/facility_logs_binding.dart';
import '../modules/facility_logs/views/facility_logs_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.TASKS;

  static final routes = [
    GetPage(
      name: _Paths.TASKS,
      page: () => const TasksView(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.CLIENT_DASHBOARD,
      page: () => const ClientDashboardView(),
      binding: ClientDashboardBinding(),
    ),
    GetPage(
      name: _Paths.ADD_CLIENT,
      page: () => const AddClientView(),
      binding: AddClientBinding(),
    ),
    GetPage(
      name: _Paths.CLIENT_DETAILS,
      page: () => const ClientDetailsView(),
      binding: ClientDetailsBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_CLIENT,
      page: () => const EditClientView(),
      binding: EditClientBinding(),
    ),
    GetPage(
      name: _Paths.QUICK_ACTIONS,
      page: () => const QuickActionsView(),
      binding: QuickActionsBinding(),
    ),
    GetPage(
      name: _Paths.CARE_LOG_HISTORY,
      page: () => const CareLogHistoryView(),
      binding: CareLogHistoryBinding(),
    ),
    GetPage(
      name: _Paths.PHOTO_CAPTURE,
      page: () => const PhotoCaptureView(),
      binding: PhotoCaptureBinding(),
    ),
    GetPage(
      name: _Paths.FACILITY_HISTORY,
      page: () => const FacilityHistoryView(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.FACILITY_LOGS,
      page: () => const FacilityLogsView(),
      binding: FacilityLogsBinding(),
    ),
  ];
}
