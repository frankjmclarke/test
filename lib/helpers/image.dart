import 'dart:io';

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

String extractImageUrl(String html) {
  final document = parser.parse(html);
  final imageElement = document.getElementsByTagName('img').first;
  final imageUrl = imageElement.attributes['src'];
  return imageUrl ?? '';
}

bool isUrlImage(var imageUrl) {
  return (imageUrl != null &&
      !imageUrl.endsWith('.svg') &&
      !imageUrl.endsWith('.pdf'));
}

bool isUrlImageNEW(String url) {
  //too picky
  final imageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  final lowerCaseUrl = url.toLowerCase();
  return imageFormats.any((format) => lowerCaseUrl.endsWith(format));
}

Future<List<String>> getImageUrlList(
    String html, String url, int numImages, int numImagesChecked) async {
  //return top numImages of the first numImagesChecked
  final int MIN_SIZE = 10000;
  final host = Uri.parse(url).host;
  final document = parser.parse(html);
  final images = document.getElementsByTagName('img');
  List<Map<String, dynamic>> topImages =
      List.generate(numImages, (index) => {"size": 0, "url": ''});
  print("🟩getImageUrlList: ");
  int maxCount = 0;
  for (final imageElement in images) {
    if (maxCount > numImagesChecked) break;
    var imageUrl = imageElement.attributes['src'] ?? '';
    int imageSizeInBytes = 0;
    if (isUrlImage(imageUrl)) {
      if (!imageUrl.startsWith('http')) {
        // Prepend host to imageUrl if no host specified
        if (!imageUrl.startsWith(host)) imageUrl = host + imageUrl;
        if (url.startsWith('http')) {
          imageUrl = 'http://' + imageUrl;
        } else {
          imageUrl = 'https://' + imageUrl;
        }
      }
      try {
        http.Response r = await http.head(Uri.parse(imageUrl));
        String len = r.headers["content-length"] ?? "0";
        if (len == "0") {
          final response = await http.get(Uri.parse(imageUrl));
          len = response.headers['content-length'] ?? "0";
        }
        imageSizeInBytes = int.parse(len);
        if (imageSizeInBytes > MIN_SIZE) maxCount++;
      } catch (e) {
        print("🟩🟩getImageUrlHost" + e.toString());
      }

      // Find the smallest image in the top images list
      int minSizeIndex = 0;
      for (int i = 1; i < numImages; i++) {
        if (topImages[i]["size"] < topImages[minSizeIndex]["size"])
          minSizeIndex = i;
      }

      // If the current image is bigger than the smallest one in the top images list, replace it
      if (imageSizeInBytes > topImages[minSizeIndex]["size"]) {
        topImages[minSizeIndex]["size"] = imageSizeInBytes;
        topImages[minSizeIndex]["url"] = imageUrl;
      }
    }
  }

  List<String> largestImageUrls =
      topImages.map((img) => img['url'].toString()).toList().cast<String>();
  print('🟩getImageUrlList largestImageUrls ' + largestImageUrls.toString());
  return largestImageUrls;
}

Future<List<String>> getImageUrlListNew(List<String> imageList, String url,
    int numImages, int numImagesChecked) async {
  final int MIN_SIZE = 10000;
  final host = Uri.parse(url).host;
  final scheme = Uri.parse(url).scheme; // Get http or https from the main URL

  List<Map<String, dynamic>> topImages =
      List.generate(numImages, (index) => {"size": 0, "url": ''});

  print("🟩 getImageUrlListNew: ");

  int maxCount = 0;
  for (final imageUrl in imageList) {
    if (maxCount > numImagesChecked) break;

    String processedImageUrl = imageUrl;
    if (isUrlImage(processedImageUrl)) {
      // Make sure the URL starts with http/https and has a host
      if (!processedImageUrl.startsWith('http')) {
        if (!processedImageUrl.startsWith('/')) {
          processedImageUrl = '/' + processedImageUrl;
        }
        processedImageUrl = '$scheme://$host$processedImageUrl';
      }

      int imageSizeInBytes = 0;
      try {
        http.Response r = await http.head(Uri.parse(processedImageUrl));
        String len = r.headers["content-length"] ?? "0";
        if (len == "0") {
          final response = await http.get(Uri.parse(processedImageUrl));
          len = response.headers['content-length'] ?? "0";
        }
        imageSizeInBytes = int.parse(len);
        if (imageSizeInBytes > MIN_SIZE) maxCount++;
      } catch (e) {
        if (e is SocketException) {
          print(" � getImageUrlHost Socket exception: ${e.toString()}");
        } else
          print(
              " � getImageUrlHost encountered a unknown error: ${e.toString()}");
      }

      int minSizeIndex = topImages.indexWhere((img) =>
          img["size"] ==
          topImages
              .map((img) => img["size"])
              .reduce((curr, next) => curr < next ? curr : next));

      if (imageSizeInBytes > topImages[minSizeIndex]["size"]) {
        topImages[minSizeIndex]["size"] = imageSizeInBytes;
        topImages[minSizeIndex]["url"] = processedImageUrl;
      }
    }
  }

  List<String> largestImageUrls =
      topImages.map((img) => img['url'].toString()).toList();
  print('🟩 getImageUrlListNew largestImageUrls $largestImageUrls');

  return largestImageUrls;
}
