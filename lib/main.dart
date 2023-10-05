import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shopping_lister/controllers/string_list_controller.dart';
import 'package:shopping_lister/revenuecat/store_config.dart';
import '../constants/constants.dart';
import '../ui/components/components.dart';
import '../helpers/helpers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'constants/revenuecat.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cat_storage_controller.dart';
import 'controllers/chatgpt_controller.dart';
import 'controllers/clipboard_controller.dart';
import 'controllers/key_word_controller.dart';
import 'controllers/keyword_controller.dart';
import 'controllers/language_controller.dart';
import 'controllers/storage_controller.dart';
import 'package:sizer/sizer.dart';
import 'controllers/theme_controller.dart';
import 'controllers/url_controller.dart';
import 'firebase_options.dart';
//◼️ ◻️ 🟥 🟧 🟨 🟩 🟦 🟪 ⬛️ ⬜️ 🟫 🛑 ⛔️⚠️☣️🔘❓ 🔴 🟠 🟡 🟢 🔵 🟣 ⚫️ ⚪️ 🟤‍
void main() async {
  if (Platform.isIOS || Platform.isMacOS) {
    StoreConfig(
      store: Store.appStore,
      apiKey: appleApiKey,
    );
  } else if (Platform.isAndroid) {
    // Run the app passing --dart-define=AMAZON=true
    const useAmazon = false;//bool.fromEnvironment("amazon");
    StoreConfig(
      store: useAmazon ? Store.amazon : Store.playStore,
      apiKey: useAmazon ? amazonApiKey : googleApiKey,
    );
  }
  WidgetsFlutterBinding.ensureInitialized();

/*
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
      AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ));
    }
  }
*/

  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await GetStorage.init();
  Get.put<AuthController>(AuthController());
  Get.put<ThemeController>(ThemeController());
  Get.put<LanguageController>(LanguageController());
  Get.put<StorageController>(StorageController());
  Get.put<UrlController>(UrlController());
  Get.put<ChatGPTController>(ChatGPTController());
  Get.put<CatStorageController>(CatStorageController());
  Get.put<KeywordController>(KeywordController());
  Get.put<StringListController>(StringListController());
  Get.put<Key_wordController>(Key_wordController());
  Get.put<ClipboardController>(ClipboardController());
  await _configureSDK();
  ClipboardController cc= ClipboardController();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeController.to.getThemeModeFromStore();
    return GetBuilder<LanguageController>(
      builder: (languageController) => Loading(
        child: Sizer(
          builder: (context, orientation, deviceType) => GetMaterialApp(
            translations: Localization(),
            locale: languageController.getLocale,
            navigatorObservers: [
              // FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
            ],
            debugShowCheckedModeBanner: false,
            // Configure GetX navigation
            initialRoute: '/',
            getPages: AppRoutes.routes,
          ),
        ),
      ),
    );
  }
}
Future<void> _configureSDK() async {
  // Enable debug logs before calling `configure`.
  await Purchases.setLogLevel(LogLevel.debug);

  /*
    - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK.
    Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids

    - observerMode is false, so Purchases will automatically handle finishing transactions.
    Read more about Observer Mode here: https://docs.revenuecat.com/docs/observer-mode
    */
  PurchasesConfiguration configuration;
  if (StoreConfig.isForAmazonAppstore()) {
    configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = null
      ..observerMode = false;
  } else {
    configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = null
      ..observerMode = false;
  }
  await Purchases.configure(configuration);
}
