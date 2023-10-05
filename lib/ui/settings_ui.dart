import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../constants/globals.dart';
import '../controllers/auth_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/menu_option_model.dart';
import '../revenuecat/ui/user.dart';
import '../ui/auth/auth.dart';
import 'package:get/get.dart';
import '../ui/components/segmented_selector.dart';
import 'components/dropdown_picker.dart';

class SettingsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr),
      ),
      body: _buildLayoutSection(context),
    );
  }

  Widget _buildLayoutSection(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Spacer(flex: 1),
            IntrinsicWidth(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLanguageListTile(context),
                      _buildThemeListTile(context),
                      ListTile(
                        title: Text('settings.updateProfile'.tr),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Get.to(() =>UpdateProfileUI());
                          },
                          child: Text('settings.updateProfile'.tr),
                        ),
                      ),
                      ListTile(
                        title: Text('settings.signOut'.tr),
                        trailing: ElevatedButton(
                          onPressed: () {
                            AuthController.to.signOut();
                          },
                          child: Text('settings.signOut'.tr),
                        ),
                      ),
                      ListTile(
                        title: Text('RevenueCat'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Get.to(() =>UserScreen());
                          },
                          child: Text('RevenueCat'),
                        ),
                      ),
                    ])),
            Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageListTile(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (controller) => ListTile(
        title: Text('settings.language'.tr),
        trailing: DropdownPicker(
          menuOptions: Globals.languageOptions,
          selectedOption: controller.currentLanguage,
          onChanged: (value) async {
            await controller.updateLanguage(value!);
            Get.forceAppUpdate();
          },
        ),
      ),
    );
  }

  Widget _buildThemeListTile(BuildContext context) {
    final List<MenuOptionsModel> themeOptions = [
      MenuOptionsModel(
        key: "system",
        value: 'settings.system'.tr,
        icon: Icons.brightness_4,
      ),
      MenuOptionsModel(
        key: "light",
        value: 'settings.light'.tr,
        icon: Icons.brightness_low,
      ),
      MenuOptionsModel(
        key: "dark",
        value: 'settings.dark'.tr,
        icon: Icons.brightness_3,
      ),
    ];

    return GetBuilder<ThemeController>(
      builder: (controller) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 90.w, // Adjust the width according to your needs
              child: SegmentedSelector(
                selectedOption: controller.currentTheme,
                menuOptions: themeOptions,
                onValueChanged: (value) {
                  controller.setThemeMode(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}