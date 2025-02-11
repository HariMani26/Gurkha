import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:ghurka/core/constants/routes.constant.dart';
import 'package:ghurka/ui/screens/home/home.screen.dart';

final List<GetPage> routesPages = [
  GetPage(
    name: Routes.home,
    page: () => const HomeScreen(),
  ),
];
