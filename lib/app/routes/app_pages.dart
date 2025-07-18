import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/client/bindings/client_dashboard_binding.dart';
import '../modules/client/views/client_dashboard_view.dart';
import '../modules/client/bindings/add_client_binding.dart';
import '../modules/client/views/add_client_view.dart';
import '../modules/care_log/bindings/quick_actions_binding.dart';
import '../modules/care_log/views/quick_actions_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.CLIENT_DASHBOARD;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
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
      name: _Paths.QUICK_ACTIONS,
      page: () => const QuickActionsView(),
      binding: QuickActionsBinding(),
    ),
  ];
}
