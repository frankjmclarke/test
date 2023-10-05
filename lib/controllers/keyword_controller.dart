import 'dart:math';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopping_lister/controllers/base_controller.dart';
import '../helpers/string_util.dart';
import '../models/keyword_model.dart';

class KeywordController extends BaseController<KeywordModel> {
  final box = GetStorage();

  RxBool isDataLoaded = false.obs;
  String categoryFilter = '';
  final String ALL_ITEMS = '1';
  final String STORAGE_NAME = 'shopperkeymodel';
  bool get isEmpty => urlList.isEmpty;
  int get length => urlList.length;

  int get lengthFiltered => filteredDataList.length;
  bool filtered() => (categoryFilter.isNotEmpty && categoryFilter != ALL_ITEMS);

  @override
  void onInit() {
    super.onInit();
    readListAll();
  }

  Future<void> saveData() async {
    final jsonData = urlList.map((item) => item.toMap()).toList();
    await box.write(STORAGE_NAME, jsonData);
  }

  void addUrl(KeywordModel newItem) async {
    if (urlList.any((item) => item.uid == newItem.uid)) {
      print("@EXISTS@ "+newItem.name);
      return;
    }
    urlList.add(newItem);
    if (filtered()) {
      if (newItem.category.contains(categoryFilter)) {
        filteredDataList.add(newItem);
      }
    } else {
      filteredDataList.add(newItem);
    }
    print("##NEW## "+newItem.name);
    await saveData();
  }

  void saveUrlList(List<String> keywords, int upVotes) async {
    for (var keyword in keywords) {
      bool existingKeywordFound = urlList.any((item) =>
      item.name == keyword && item.category == categoryFilter);

      if (existingKeywordFound) {
        urlList
            .where((item) => item.name == keyword && item.category == categoryFilter)
            .forEach((item) => item.upVotes += 1);

      } else {
        final newKeywordModel = KeywordModel(
          uid: generateUniqueOrRandomId(urlList),
          name: keyword,
          category: categoryFilter,
          upVotes: upVotes,
          downVotes: 0,
        );
        addUrl(newKeywordModel);
      }
    }
    await saveData(); // Updates duplicate keyword upVotes
  }

  void addSharedUrl(String name, String url, String imageUrl, String cat,) {
    final newKeywordModel = KeywordModel(
      uid: generateUniqueOrRandomId(urlList),
      name: name,
      category: cat,
      upVotes: 0,
      downVotes: 0,
    );
    addUrl(newKeywordModel);
  }

  String generateUniqueId(RxList<KeywordModel> urlList) {
    String uid;
    bool isUniqueId = false;

    do {
      uid = StringUtil.generateUid();
      final isUidExists = urlList.any((item) => item.uid == uid);
      isUniqueId = !isUidExists;
    } while (!isUniqueId);

    return uid;
  }

  String generateUniqueOrRandomId(RxList<KeywordModel> urlList) {
    final random = Random();
    final shouldGenerateRandomId = random.nextBool();

    if (shouldGenerateRandomId) {
      return StringUtil.generateRandomId(10);
    } else {
      return generateUniqueId(urlList);
    }
  }

  void deleteUid(String uid) async {
    urlList.removeWhere((item) => item.uid == uid);
    filteredDataList.removeWhere((item) => item.uid == uid);
    await saveData();
  }

  void loadData() async {
    final data = await box.read(STORAGE_NAME);
    if (data != null) {
      urlList.clear();
      urlList.addAll(data.map<KeywordModel>((item) => KeywordModel.fromMap(item)).toList());
      readListFiltered(categoryFilter);
    }
    isDataLoaded.value = true;
  }

  void readListFiltered(String query) {
    categoryFilter = query;
    if (filtered()) {
      filteredDataList.value =
          urlList.where((item) => item.category.contains(query)).toList();
    } else {
      filteredDataList.value = urlList;
    }
    isDataLoaded.value = true;
  }
}
