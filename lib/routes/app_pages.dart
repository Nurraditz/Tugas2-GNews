import 'package:get/get.dart';

import '../controllers/detail_controller.dart';
import '../views/detail_view.dart';
import '../views/home_view.dart';
import '../views/search_results_view.dart';
import 'app_routes.dart';

/// Daftar halaman dan binding untuk GetX routing.
class AppPages {
  AppPages._();

  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DetailController>(() => DetailController());
      }),
    ),
    GetPage(
      name: AppRoutes.searchResults,
      page: () => const SearchResultsView(),
    ),
  ];
}
