import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../controllers/browser_controller.dart';
import '../../controllers/storage_controller.dart';
import '../../helpers/image.dart';
import '../../helpers/string_util.dart';
import '../../models/url_model.dart';

//Browser screen with 5 google searches
class BrowserUI extends StatefulWidget {
  @override
  _BrowserUIState createState() => _BrowserUIState();
}

class _BrowserUIState extends State<BrowserUI> {

  final StorageController _storageController = Get.find<StorageController>();
  late List<String> keywords;
  var title;
  var scrollPosition;
  String html = "";
  String url = "";
  String category = "";
  int screenIndex = 0;
  bool isBrowser = false;
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllowFullscreen: true,
      javaScriptCanOpenWindowsAutomatically: true,
      supportMultipleWindows: true
  );
  BrowserController _browserController = Get.put(BrowserController());
  String log ='BrowserUI';

  void initState() {
    super.initState();
    dynamic argumentData = Get.arguments;
    List<String> urls = [
      "http://www.amazon.com",
      "http://www.google.com",
      "http://www.craigslist.com",
      "http://www.walmart.com",
      "http://www.bing.com",
    ];

    isBrowser = argumentData[0]['url'] != null;
    keywords = argumentData[0]['keywords'] ?? urls;
    url =  'https://www.google.com/search?q=' + keywords[screenIndex];
    category = argumentData[0]['category'] ?? '1';
    print('BrowserUI.initState! $url');
    stderr.writeln('stderr BrowserUI.initState! $url');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUrl = !isBrowser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Browser'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_link),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Saving Changes...'),
                ),
              );
              _saveChanges().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Changes saved'),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(url)),
              initialSettings: settings,
              onWebViewCreated: (controller) async  {
                print('🟩 $log onWebViewCreated: $url');
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                print('🟩 $log onLoadStart: $url');
                webViewController = controller;
              },
              onLoadStop: (controller, url) async  {
                print('🟩 $log onLoadStop: $url');
                title = controller.getTitle();
                _browserController.insertUrlWithImages(controller, url.toString(), category);
               // _browserController.generateNewAIUrl(controller, url.toString(), category);
              },
              onReceivedError: (controller, request, error) {
                print ("EEEEEEEEEEEERROR"+error.toString());
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                //makes click on link work
                final uri = navigationAction.request.url!;
                if (uri.toString().startsWith('https://www.youtube.com')) {
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
          ),
        ],
      ),

   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: hasUrl
          ? Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      screenIndex = (screenIndex - 1 + 5) % 5;
                      String newUrl = 'https://www.google.com/search?q=' + keywords[screenIndex];
                      await webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(newUrl)));
                    },
                    child: Icon(
                      Icons.reply_outlined,
                    ),
                    heroTag: "btn1",
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      screenIndex = (screenIndex + 1) % 5;
                      String newUrl = 'https://www.google.com/search?q=' + keywords[screenIndex];
                      await webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(newUrl)));
                    },
                    child: Icon(
                      Icons.reply_outlined,
                      textDirection: TextDirection.rtl,
                    ),
                    heroTag: "btn2",
                  ),
                ],
              ),
            )
          : null,// Hide the FloatingActionButton if hasUrl is false
    );
  }

  Future<void> _saveChanges() async {
    final currentUrl = await webViewController?.getUrl();
    List<String > imageUrl= await getImageUrlList(html, currentUrl.toString(), 5, 12);
    print('🟩_saveChanges ' + imageUrl[0]);
    if (currentUrl != null) {
      _storageController.addOrUpdateUrl(UrlModel(
        uid: StringUtil.generateRandomId(15),
        email: '',
        name: title,
        url: currentUrl.toString(),
        imageUrl0: imageUrl[0],
        imageUrl1: imageUrl[1],
        imageUrl2: imageUrl[2],
        imageUrl3: imageUrl[3],
        imageUrl4: imageUrl[4],
        address: '',
        quality: 0,
        distance: 0,
        value: 0,
        size: 0,
        note: '',
        features: '',
        phoneNumber: '',
        price: '',
        category: category,
      ));
    }
  }
}
