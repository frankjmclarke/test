import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shopping_lister/controllers/url_controller.dart';
import 'package:shopping_lister/helpers/html_util.dart';

class ClipboardController extends GetxController with ClipboardListener  {

  @override
  void onInit() {
    super.onInit();
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
  }

  @override
  void dispose() {
    clipboardWatcher.removeListener(this);
    clipboardWatcher.stop();
    super.dispose();
  }

  @override
  void onClipboardChanged() async {
    final UrlController _urlController = Get.put(UrlController());
    ClipboardData? newClipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String? url = newClipboardData?.text;
    if (url != null && HtmlUtil.isValidURL(url)){
      _urlController.addUrl(url);
    }
    print(newClipboardData?.text ?? "");
  }

}