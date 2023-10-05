import 'dart:convert';
import 'dart:math';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:shopping_lister/controllers/controllers.dart';
import '../helpers/html_util.dart';
import 'headerless.dart';

class BrowserController extends GetxController {
  String log = 'BrowserController';
  final List<String> urlListPrev = [];
  Headerless hl = Headerless();
  String prevUrl = '';
  bool imagesFound = false;
  bool imagesInProgress = false;

// Extract links from Google Search results
// Add a random link as a new URL with no images
  Future<void> googleLink2Url(InAppWebViewController controller, String searchUrl, String category) async {
    if (urlListPrev.contains(searchUrl)) {
      print('🟩 $log URL already exists: $searchUrl');
      return;
    }
    print('🟩🟢 $log  googleLink2Url : $searchUrl');
    String linkAWithRole = "Array.from(document.querySelectorAll('a[role=\"presentation\"]')).map(i => i.href);";
    final linkAWithRoleJS =
        await controller.evaluateJavascript(source: linkAWithRole);
    if (linkAWithRoleJS.isEmpty)
      return;
    List<String> productUrlList;
    if (linkAWithRoleJS is List<dynamic>) {
      productUrlList = List<String>.from(linkAWithRoleJS);
    } else {
      productUrlList = List<String>.from(jsonDecode(linkAWithRoleJS));
    }
    final Random random = new Random();
    int index = random.nextInt(productUrlList.length-1);
    if (index>-1) {
      String googleProductUrl = productUrlList[index];
      await _productLinkToUrl(googleProductUrl, category);
    }

    urlListPrev.add(searchUrl);
  }

  Future <void> _productLinkToUrl(String linkFromGoogle, String category) async {
    print('🟩🟢 $log  productLinkToUrl : $linkFromGoogle');
    if (urlListPrev.contains(linkFromGoogle)) {
      print('🟩 $log URL already exists: $linkFromGoogle');
      return;
    }
    bool success= await hl.insertUpdateUrlImages(linkFromGoogle, category, newRecord: false);
    if (!success)
      await hl.insertUpdateUrlImages(linkFromGoogle, category, newRecord: false);
    prevUrl = linkFromGoogle;
  }

//get list of image links
//Create new URL with 5 image links
  Future<void> insertUrlWithImages(InAppWebViewController controller, String url, String catUid) async {
    if (imagesFound || imagesInProgress) return;
    print('🟩🟢 $log insertUpdateUrlImages: $url');
    imagesFound = false;
    imagesInProgress = true;
    String titleJS = 'window.document.title;';
    String command3 =
        "Array.from(document.getElementsByTagName('img')).map(i => i.src);";
    List<String> imgList;
    String title = '';
    final StorageController _storageController = Get.find<StorageController>();
    try {
      title = await controller.evaluateJavascript(source: titleJS);
      final imageJSON = await controller.evaluateJavascript(source: command3);
    //mirrors on the elevator
    _storageController.addInitialUrl(title, url, uid: _storageController.currentUid, category: _storageController.currentCategory);

    if (imageJSON is List<dynamic>) {
      imgList = List<String>.from(imageJSON);
    } else {
      imgList = List<String>.from(jsonDecode(imageJSON));
    }
    }catch (e){
      print('🟩🟢🟥  insertUrlWithImages'+e.toString());
      imagesInProgress = false;
      return;
    }
    print('🟩🟢  pre insertUrlWithImages');
    DateTime _now = DateTime.now();
    print('timestamp: ${_now.minute}:${_now.second}.${_now.millisecond}');
    List<String> nameAndImages =
        await HtmlUtil.parseNameImagesNew(imgList, title, url);

    print('🟩🟢  post insertUrlWithImages '+nameAndImages.length.toString());
    _now = DateTime.now();
    print('timestamp: ${_now.minute}:${_now.second}.${_now.millisecond}');
    await _storageController.insertUrl(nameAndImages, url, catUid);
    String imageLast = nameAndImages[nameAndImages.length-1];
    imagesFound = HtmlUtil.isValidURL(imageLast);
    imagesInProgress = false;
  }
}
