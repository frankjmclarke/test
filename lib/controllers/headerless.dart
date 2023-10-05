import 'dart:async';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:shopping_lister/controllers/storage_controller.dart';
import '../../controllers/browser_controller.dart';

class Headerless {
  final StorageController _storageController = Get.find<StorageController>();
  HeadlessInAppWebView? headlessWebView;
  String log = 'Headerless';
  final List<String> urlListPrev = [];

  //From FAB search Google using list names and AI keywords to find and add first time Url
  Future<bool> searchAndInsertUrlNoImages(String searchUrl, String category) async {
    if (urlListPrev.contains(searchUrl)) {
      print('🟩 $log URL already exists: $searchUrl');
      return true;
    }
    Get.put(BrowserController(), tag: 'bc1');
    BrowserController bc1 = Get.find(tag: 'bc1');
    if (Platform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
    headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(searchUrl)),
      onWebViewCreated: (controller) {
        print('🟩🟢 $log insertNewUrlNoImages onWebViewCreated: $searchUrl');
      },
      onConsoleMessage: (controller, consoleMessage) {},
      onLoadStart: (controller, url) async {
        print('🟩 $log onLoadStart: $url');
      },
      onLoadStop: (controller, url) async {
        print('🟩🟢 $log insertNewUrlNoImages onLoadStop: $url');
        if (!urlListPrev.contains(searchUrl)) {//can be called twice
          urlListPrev.add(searchUrl);
          //we have the search results
          //run javascript to get productUrlList
          //calls insertUpdateUrlImages with new product link
          await bc1.googleLink2Url(controller, searchUrl, category);
        }//no images
      },
    );
    //await headlessWebView?.dispose();
    await headlessWebView?.run().timeout(Duration(seconds: 20), onTimeout: () {
      print('🔴 $log Timeout: Failed to load $searchUrl within 20 seconds');
      _storageController.deleteUidPermanent(_storageController.currentUid);
      return false;
    });
    return true;
  }

  //from searchAndInsertUrlNoImages to add image urls
  //or from onTap Category Pick UI to create new record
  Future<bool> insertUpdateUrlImages(String newUrl, String category, {required bool newRecord}) async {
    // If the URL already exists in the list, exit the method
    if (newRecord)
      _storageController.newRecordUid();
    if (urlListPrev.contains(newUrl)) {
      print('🟩 $log URL already exists: $newUrl');
      return true;
    }
    Get.put(BrowserController(), tag: 'bc2');
    BrowserController bc2 = Get.find(tag: 'bc2');
    if (Platform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
    headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(newUrl)),
      onWebViewCreated: (controller) {
        bc2.imagesFound = false;
        bc2.imagesInProgress = false;
        print('🟩🟢 $log insertUpdateUrlImages onWebViewCreated: $newUrl');
      },
      onLoadStart: (controller, url) async {
        print('🟩 $log onLoadStart: $url');
      },
      onProgressChanged: (controller, progress) {
        if (progress > 50) {
          //todo add success check to insertUrlWithImages
          bc2.insertUrlWithImages(controller, newUrl, category);
        }
      },
      onLoadStop: (controller, url) async {
        print('🟩🟢 $log insertUpdateUrlImages onLoadStop: $url');
        if (!urlListPrev.contains(newUrl)) {//can be called twice
          urlListPrev.add(newUrl);
          if (!bc2.imagesFound) {
            print('🟩🟢 $log insertUpdateUrlImages bc2.imagesFound NOT: $url');
            await bc2.insertUrlWithImages(controller, newUrl, category);
            _storageController.clearRecordUid();//finished updating the new record
          } else{
            print('🟩🟢 $log insertUpdateUrlImages bc2.imagesFound ALREADY DONE: $url');
          }
        }
      },
    );
    //await headlessWebView?.dispose();
    await headlessWebView?.run().timeout(Duration(seconds: 20), onTimeout: () {
      print('🔴 $log Timeout: Failed to load $newUrl within 20 seconds');
      _storageController.deleteUidPermanent(_storageController.currentUid);
      return false;
      //throw TimeoutException('Failed to load $urlx within 20 seconds');
    });
    return true;
  }
}
