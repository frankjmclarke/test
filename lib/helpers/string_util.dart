import 'dart:math';

class StringUtil {

  // Check if a string is empty or null
  static bool isNullOrEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  // Check if a string is not empty and not null
  static bool isNotNullOrEmpty(String? str) {
    return str != null && str.isNotEmpty;
  }

  // Capitalize the first letter of a string
  static String capitalize(String str) {
    if (isNullOrEmpty(str)) {
      return str;
    }
    return str[0].toUpperCase() + str.substring(1);
  }

  // Convert a string to title case
  static String toTitleCase(String str) {
    if (isNullOrEmpty(str)) {
      return str;
    }
    return str.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Trim leading and trailing whitespace from a string
  static String trimWhitespace(String str) {
    return str.trim();
  }

  // Check if a string starts with a specified prefix
  static bool startsWith(String str, String prefix) {
    return str.startsWith(prefix);
  }

  // Check if a string ends with a specified suffix
  static bool endsWith(String str, String suffix) {
    return str.endsWith(suffix);
  }

  // Replace all occurrences of a substring with another substring
  static String replaceAll(String str, String from, String to) {
    return str.replaceAll(from, to);
  }

  // Split a string into a list of substrings based on a delimiter
  static List<String> split(String str, String delimiter) {
    return str.split(delimiter);
  }

  static String ellipsisMid(String str, int length) {
    if (isNullOrEmpty(str) || str.length <= length) {
      return str;
    }

    final int ellipsisLength = 3; // Length of the ellipsis (...)
    final int halfLength = (length - ellipsisLength) ~/ 2;

    final String firstHalf = str.substring(0, halfLength);
    final String secondHalf = str.substring(str.length - halfLength);

    return '$firstHalf...$secondHalf';
  }

  // Truncate a string with an ellipsis (...) if it exceeds the specified length
  static String ellipsis(String str, int length) {
    if (isNullOrEmpty(str) || str.length <= length) {
      return str;
    }
    return str.substring(0, length) + '...';
  }
/*
  static List<String> extractFirstNWord(String text, int num) {
    List<String> words = text.trim().split(' ');
    if (words.length <= num) {
      return words;
    } else {
      return words.sublist(0, num);
    }
  }*/

  static String extractFirstNWords(String text, int num) {
    List<String> words = text.trim().split(' ');
    if (words.length <= num) {
      return text;
    } else {
      List<String> first10Words = words.sublist(0, num);
      return first10Words.join(' ');
    }
  }

  static String generateRandomId(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final maxIndex = characters.length - 1;

    String id = '';
    for (int i = 0; i < length; i++) {
      final randomIndex = random.nextInt(maxIndex);
      id += characters[randomIndex];
    }
    return id;
  }

  static String generateUniqueUid(List<String> existingUids) {
    String uid;
    do {
      uid = generateUid(); // Replace this with your preferred method of generating UIDs
    } while (existingUids.contains(uid));
    return uid;
  }

  static int dtPrev = DateTime.now().millisecondsSinceEpoch;

  static String generateUid() {
    DateTime now = DateTime.now();
    int milliSec = now.millisecondsSinceEpoch;
    String result;
    if (milliSec == dtPrev)
      result = generateRandomId(9);
    else {
      result = milliSec.toString();
      dtPrev = milliSec;
    }
    return result;
  }
}
