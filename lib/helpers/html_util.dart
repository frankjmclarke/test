import 'image.dart';

class HtmlUtil {
/*
  static Future<List<String>> parseHtmlText(String htmlText, String url) async {
    try {
      print("💙 parseHtmlText");
      final document = parse(htmlText);
      final titleElement = document.querySelector('title');
      final name = titleElement?.text ?? '';

      final imageUrl = await getImageUrlHost(
          htmlText, url); // Await the getImageUrl function call

      return [name, imageUrl];
    } catch (error) {
      print('Error fetching HTML: $error');
    }
    return ['', '']; // Return empty strings if there was an error
  }*/

  static Future<List<String>> parseNameImagesNew(
      List<String> imageList, String name, String url) async {
    try {
      print("💙 parseHtmlText");

      final imageUrl = await getImageUrlListNew(
          imageList, url, 5, 11); // Await the getImageUrl function call

      return [
        name,
        imageUrl[0],
        imageUrl[1],
        imageUrl[2],
        imageUrl[3],
        imageUrl[4]
      ];
    } catch (error) {
      print('🟥Error fetching HTML: $error');
    }
    return [
      'No Title',
      '',
      '',
      '',
      '',
      ''
    ]; // Return empty strings if there was an error
  }

  static bool isValidURL(String urlString) {
    Uri? uri = Uri.tryParse(urlString);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  static bool isValidURL2(String url) {
    final RegExp urlPattern = RegExp(
      r'^(http|https):\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(:[0-9]+)?([\/\?].*)?$',
    );
    return urlPattern.hasMatch(url);
  }
}
