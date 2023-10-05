import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../edit_text_ui.dart';

class WebviewUI extends StatefulWidget {
  @override
  State<WebviewUI> createState() => _WebviewUIState();
}

class _WebviewUIState extends State<WebviewUI> {

  var loadingPercentage = 0;
  late final int index;
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewSettings settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllowFullscreen: true,
      javaScriptCanOpenWindowsAutomatically: true,
      supportMultipleWindows: true
  );
  String url=' ';
  String log ='WebviewUI';

  void initState() {
    super.initState();
    if (Get.arguments[0] != null) {
      url = Get.arguments[0]!['url'] ?? "http:www.google.com";
      index = Get.arguments[0]!['index'] ?? 0;
    } else {
      url = "http:www.google.com";
      index = 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void editItem(int index) {
    Get.to(() => EditTextUI(), arguments: [
      {"index": index},
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web View'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              editItem(index);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(url)),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                //webViewController = controller;
                print('🟩 $log  onWebViewCreated:');
              },
              onLoadStart: (controller, url) {
              },
              onLoadStop: (controller, url) {
                //title = controller.getTitle();
                print('🟩 $log  onLoadStop:');
              },
              onReceivedError: (controller, request, error) {
                // Handle error if needed
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
    );
  }
}
