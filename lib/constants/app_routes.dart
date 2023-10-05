import 'package:shopping_lister/ui/webview/browser_ui.dart';
import '../ui/storage/cat_storage_list_ui.dart';
import '../ui/onboarding/onboarding.dart';
import '../ui/storage/stored_list_ui.dart';
import 'package:get/get.dart';
import '../ui/ui.dart';
import '../ui/auth/auth.dart';
import '../ui/home_menu_ui.dart';

class AppRoutes {
  AppRoutes._(); //this is to prevent anyone from instantiating this object
  static final routes = [//allows Get.to(SignUpUI()),
    GetPage(name: '/', page: () => SplashUI()),//SplashUI
    GetPage(name: '/signin', page: () => SignInUI()),
    GetPage(name: '/signup', page: () => SignUpUI()),
    GetPage(name: '/home', page: () => HomeUI()),
    GetPage(name: '/home-menu', page: () => HomeMenuUI()),
    GetPage(name: '/urllist', page: () => CatStorageListUI()),
    GetPage(name: '/catlist', page: () => CatStorageListUI()),
    GetPage(name: '/settings', page: () => SettingsUI()),
    GetPage(name: '/reset-password', page: () => ResetPasswordUI()),
    GetPage(name: '/update-profile', page: () => UpdateProfileUI()),
    GetPage(name: '/onboarding', page: () => OnboardingUI()),
    GetPage(name: '/storedlist', page: () => StoredListUI()),
    GetPage(name: '/browser', page: () => BrowserUI()),
  ];
}
/*
Map response = {
  "data": [
    {"name": "Parth Darji"},
    {"name": "Darshan Popat"},
    {"name": "Jitendra Mistry"}
  ],
  "message": "All data get successfully"
};

Get.to(Screen1(), arguments: response, transition: Transition.leftToRightWithFade,);

var data = Get.arguments;
*/

/*
class AuthGuard extends GetMiddleware {
  final authService = Get.find<AuthController>();
//   The default is 0 but you can update it to any number. Please ensure you match the priority based
//   on the number of guards you have.
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Navigate to login if client is not authenticated other wise continue
    if (authService.initialized) return RouteSettings(name: 'home');
    return RouteSettings(name: 'signup');
  }
}
*/

