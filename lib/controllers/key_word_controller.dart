import 'dart:math';
import 'package:get/get.dart';
import 'package:shopping_lister/controllers/storage_controller.dart';
import 'package:shopping_lister/controllers/string_list_controller.dart';
import 'chatgpt_controller.dart';

class Key_wordController extends StringListController {
  final StorageController _storageController = Get.find<StorageController>();
  var urlNamesCsv;
  late List<String> urlNamesList;
  RxBool isButtonPressedRecently = false.obs;
  String log = 'Key_wordController';

  Future<String> generateSearchString(String category) async {
    //mirrors on the elevator
    _storageController.addInitialUrl('Checking AI...', '',
        category: category, uid: _storageController.currentUid);
    _storageController.addInitialUrl('Gathering data...', '',
        category: category,
        uid: _storageController.currentUid,
        secondsDelay: 2);
    await _callAIifNeeded(category);
    //pick a random keyword, search for it, and make a new url from it
    int limit = urlNamesList.length - 1;
    bool aiSucceeded = limit > -1;
    if (aiSucceeded) {
      int index = 0;
      if (limit > 0) {
        final Random random = new Random();
        index = random.nextInt(limit);
      }
      String keyword = urlNamesList[index];
      String url = 'https://www.google.com/search?q=' + keyword;
      print('🟩🟢 $log  generateSearchString : $url');
      return url;
    } else {
      print('🟢 $log  generateSearchString no keywords');
      _storageController.deleteUidPermanent(_storageController.currentUid);
    }
    return '';
  }

  Future<void> _callAIifNeeded(String category) async {
    try {
      urlNamesCsv = _storageController.readNameCSV();
      urlNamesList = _storageController.readNameListShort();

      final bool needToRunAI = _lookForChanges(category);
      final String chatGPTKeywordsFilename = 'shopaikey' + category;
      loadStringList(chatGPTKeywordsFilename);
      if (needToRunAI) {
        await _callAiThenMergeIn(0.9);
        print('🟩🟢 checkForNewNames $category newNames');
      }
    } catch (error) {
      print("🟥 checkForNewNames $category " + error.toString());
    }
    print('🟩🟢 checkForNewNames $category newNames ' + get().join(','));
  }

  bool _lookForChanges(String uid) {
    //if we have new items, add name words to list.
    loadStringList('shopnamelist' + uid);
    int lengthPrev = length;
    mergeIn(urlNamesList);
    saveStringList();
    return (lengthPrev != length) && length > 0;
  }

  Future<void> _callAiThenMergeIn(double temperature) async {
    final ChatGPTController _chatController = Get.find<ChatGPTController>();
    List<String> keywords =
        await _chatController.chat1(urlNamesCsv, temperature);
    mergeIn(keywords);
    saveStringList();
    print('🟩🟢 $log  mergeIntoGPTKeywordsFile ' + keywords.join(','));
  }
}
