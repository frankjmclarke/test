import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopping_lister/controllers/base_controller.dart';
import '../helpers/string_util.dart';
import '../models/category_model.dart';
import '../models/url_model.dart';
import 'cat_storage_controller.dart';

class StorageController extends BaseController<UrlModel> {
  final box = GetStorage();
  RxBool isDataLoaded = false.obs;
  final String STORAGE_NAME = 'shoppermodel';

  @override
  void onInit() {
    super.onInit();
    readListAll();
  }

  int uid2index(RxList<UrlModel> list, String uid) {
    return list.indexWhere((item) => item.uid == uid);
  }

  List<String> getAllUids() {
    return urlList.map((url) => url.uid.toString()).toList();
  }

////////////////// UPDATE ////////////////////////

  void _updateFiltered(int index, UrlModel newItem) async {
    urlList[index] = newItem;
    final filteredIndex = uid2index(filteredDataList, newItem.uid.toString());
    if (filteredIndex != -1) {
      filteredDataList[filteredIndex] = newItem;
    } else {
      print('!!!!!!!!!!!!-updateData-!!!!!!!!!!!!!!!!!!! ' +
          newItem.uid.toString());
    }
    await saveData();
  }

  void updateData(UrlModel newItem) async {
    if (newItem.uid == null) return;
    final index = uid2index(urlList, newItem.uid.toString());
    await updateUrl(index, newItem);
  }

  Future<void> updateUrl(int index, UrlModel newItem) async {
    if (index >= 0 && index < urlList.length) {
      _updateFiltered(index, newItem);
    }
  }

////////////////// DELETE ////////////////////////
  void deleteUrl(UrlModel item) async {
    final index = urlList.indexWhere((url) => url.uid == item.uid);
    if (index != -1) {
      urlList.removeAt(index);
      final filteredIndex = uid2index(filteredDataList, item.uid.toString());
      if (filteredIndex != -1) {
        filteredDataList.removeAt(filteredIndex);
      }
      await saveData();
    }
  }

  Future<void> deleteCatContents(String uid) async {
    urlList.removeWhere((item) => item.category == uid);
    filteredDataList.removeWhere((item) => item.category == uid);
    await saveData();
  }

  Future<void> deleteUid(String uid) async {// preserves currentUid for later use
    urlList.removeWhere((item) => item.uid == uid);
    filteredDataList.removeWhere((item) => item.uid == uid);
    await saveData();
  }

  Future<void> deleteUidPermanent(String uid) async {
    urlList.removeWhere((item) => item.uid == uid);
    filteredDataList.removeWhere((item) => item.uid == uid);
    await saveData();
    clearRecordUid();
  }

////////////////// READ ////////////////////////

  void filterData(String query) {
    categoryFilter = query;
    if (filtered()) {
      filteredDataList.value =
          urlList.where((item) => item.category.contains(query)).toList();
    } else {
      filteredDataList.value = urlList;
    }
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

  bool loaded = false;

  Future<void> loadData() async {
    if (loaded) return;
    try {
      int i = 0;
      print('🛑 $i');
      final List<dynamic>? data = await box.read(STORAGE_NAME);
      if (data != null) {
        i = data.length;
        print('🟩 $i');
        urlList.clear();
        i = urlList.length;
        print('🔥😻 $i');
        urlList.addAll(data
            .map<UrlModel>(
                (item) => UrlModel.fromMap(item as Map<String, dynamic>))
            .toList());
        readListFiltered(categoryFilter);
        i = urlList.length;
        print('💙🐟 $i');
      } else {
        print('No data found in storage.');
      }
      loaded = true;
      isDataLoaded.value = true;
      update();
    } catch (error) {
      print('🟥 Error loading data from storage: $error');
    }
  }

  UrlModel? readUrl(String? uid) {
    final index = uid2index(filteredDataList, uid!);
    if (index >= 0 && index < filteredDataList.length) {
      UrlModel url = filteredDataList[index];
      return url;
    }
    print('!!!!!!!Invalid index');
    return null;
  }

  bool exists(String? uid) {
    final index = uid2index(filteredDataList, uid!);
    return (index >= 0 && index < filteredDataList.length);
  }

  List<String> readNameListShort() {
    return filteredDataList.map((url) => readFirstNWords(url.name, 6)).toList();
  }

  String readNameCSV() {
    List<String> nameListShort = readNameListShort();
    return nameListShort.join(',');
  }

  Set<String> readWordsFromNameFields() {
    final Set<String> uniqueWords = {};
    for (final item in urlList) {
      final words = item.name.split(' '); // Split the name into words
      uniqueWords.addAll(words); // Add the words to the set
    }
    return uniqueWords; // Return the set containing unique words
  }

  int getCounts(String uid) {
    filterData(uid);
    int itemCount = lengthFiltered;
    print('🟢 $itemCount');

    return itemCount;
  }

  late DateTime _lastCalled;
  void delayedUpdate(int seconds) {
    if (DateTime.now().difference(_lastCalled).inSeconds < 5) {
      print('Wait at least 5 seconds between calls.');
      return;
    }

    _lastCalled = DateTime.now();

    Future.delayed(Duration(seconds: seconds), () {
      update(); // Assuming update is defined elsewhere
    });
  }
///////////////// WRITE ///////////////

  void updateItemCounts() {
    final CatStorageController _catController = Get.find<CatStorageController>();
    print('🟢🟢🟢  updateItemCounts ');
    for (CategoryModel category in _catController.catList) {
      category.numItems = urlList.where((urlModel) => urlModel.uid == category.uid).length;
    }
    _catController.callUpdate();
  }

  Future<void> saveData() async {
    await box.write(STORAGE_NAME, urlList); // String key, Dynamic value
    update();
  }

  Future<void> saveDataNoUpdate() async {
    await box.write(STORAGE_NAME, urlList); // String key, Dynamic value
  }

  String currentCategory = '';
  String currentUid = '';

  void newRecordUid(){
    currentUid = StringUtil.generateUid();
    print('🟢  newRecordUid: $currentUid');
  }

  void clearRecordUid(){
    currentUid = '';
    print('🟢  clearRecordUid: $currentUid');
  }

  void addInitialUrl(
      String name, String url,
      {required String category, required String uid, int secondsDelay = 0}) {
    currentCategory = category;
    currentUid = uid;
    print('🟠🟢  addInitialUrl uid: $uid');

    // Introduce a delay if secondsDelay is greater than 0, and then execute the rest of the code
    Future.delayed(Duration(seconds: secondsDelay), () {
      deleteUid(uid);
      final newUrlModel = UrlModel(
        uid: currentUid,
        email: '',
        name: name,
        url: url,
        imageUrl0: '', //ic_blank if empty
        imageUrl1: '',
        imageUrl2: '',
        imageUrl3: '',
        imageUrl4: '',
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
      );
      addOrUpdateUrl(newUrlModel);
    });
  }



  Future<void> addSharedUrl(
      String name, String url, List<String> imageUrl, String cat) async {
    String uid = currentUid;
    if (currentUid.isEmpty) {
      print('🟠🟠🟢  addSharedUrl uid ERROR');
      return;
    }
    else {
      deleteUid(uid);
    }
    print('🟢🟢🟢  addSharedUrl uid: $uid');
    final newUrlModel = UrlModel(
      uid: uid,
      email: '',
      name: name,
      url: url,
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
      category: cat,
    );
    addOrUpdateUrl(newUrlModel);
  }

  void addOrUpdateUrl(UrlModel newItem) async {
    String uid = newItem.uid ?? '';
    if (newItem.uid != null && exists(uid)) {
      deleteUid(uid);
    }
    urlList.add(newItem);
    if (filteredDataList.isEmpty) await loadData();
    if (filtered()) {
      if (newItem.category == categoryFilter) {
        filteredDataList.add(newItem);
      }
    } else {
      filteredDataList.add(newItem);
    }
    await saveData();
    updateItemCounts();
  }

  Future<void> insertUrl(
      List<String> text, String url, String catUid) async {
    String name = text[0];
    List<String> imageUrlList = text;
    imageUrlList.removeAt(0);
    categoryFilter = ALL_ITEMS;
    await addSharedUrl(name, url, imageUrlList, catUid);
  }

  Future<void> storeUrlModelList(RxList<UrlModel> urlLists) async {
    box.write(STORAGE_NAME, urlLists);
  }

  Future<void> createAndStoreTestData() async {
    // Create test UrlModel objects
    UrlModel urlModel1 = UrlModel(
      uid: '1',
      email: 'test1@example.com',
      name: 'Gibson Les Paul Cherry Sunburst Classic',
      url:
          'https://vancouver.craigslist.org/rds/msg/d/white-rock-gibson-les-paul-cherry/7625381420.html',
      imageUrl0:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl1:
          'https://m.media-amazon.com/images/I/61bukzq027L._AC_SL1500_.jpg',
      imageUrl2:
          'https://images.craigslist.org/00x0x_4Mxosrb1GCh_0CI0t2_600x450.jpg',
      imageUrl3:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl4:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      address: 'Test Address 1',
      quality: 1,
      distance: 10,
      value: 8,
      size: 500,
      note: 'White Rock',
      features: 'Test Features 1',
      phoneNumber: '1234567890',
      price: '2,100',
      category: '2',
    );
    UrlModel urlModel2 = UrlModel(
      uid: '2',
      email: 'test2@example.com',
      name: 'Novelty Place Drinking Helmet - Can Holder Drinker Hat Cap',
      url:
          'https://www.amazon.ca/Novelty-Place-Guzzler-Drinking-Helmet/dp/B01KHOQ26Y/ref=sr_1_7?crid=M5UP0WKLWSF5&keywords=beer+hat&qid=1685665693&sprefix=beer+hat%2Caps%2C157&sr=8-7',
      imageUrl0:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl1:
          'https://m.media-amazon.com/images/I/61bukzq027L._AC_SL1500_.jpg',
      imageUrl2:
          'https://images.craigslist.org/00x0x_4Mxosrb1GCh_0CI0t2_600x450.jpg',
      imageUrl3:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl4:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      address: 'Test Address 2',
      quality: 3,
      distance: 15,
      value: 6,
      size: 250,
      note:
          ' Novelty Place Drinking Helmet - Can Holder Drinker Hat Cap with Straw for Beer and Soda - Party Fun - Red',
      features:
          'COOL PARTY WEAR - Just like all crazy parties you have seen in movies, Wearing this cool novelty drinking hat will bring you lots of fun!',
      phoneNumber: '9876543210',
      price: '21.95',
      category: '3',
    );
    UrlModel urlModel3 = UrlModel(
      uid: '3',
      email: 'test2@example.com',
      name: 'Barbeque',
      url: 'https://example.com/test2',
      imageUrl0:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl1:
          'https://m.media-amazon.com/images/I/61bukzq027L._AC_SL1500_.jpg',
      imageUrl2:
          'https://images.craigslist.org/00x0x_4Mxosrb1GCh_0CI0t2_600x450.jpg',
      imageUrl3:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl4:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      address: 'Test Address 2',
      quality: 3,
      distance: 15,
      value: 6,
      size: 250,
      note: 'Test Note 2',
      features: 'Test Features 2',
      phoneNumber: '9876543210',
      price: '20 USD',
      category: '2',
    );
    UrlModel urlModel4 = UrlModel(
      uid: '4',
      email: 'test4@example.com',
      name: 'Drone',
      url: 'https://example.com/test2',
      imageUrl0:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl1:
          'https://m.media-amazon.com/images/I/61bukzq027L._AC_SL1500_.jpg',
      imageUrl2:
          'https://images.craigslist.org/00x0x_4Mxosrb1GCh_0CI0t2_600x450.jpg',
      imageUrl3:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl4:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      address: 'Test Address 4',
      quality: 3,
      distance: 15,
      value: 6,
      size: 250,
      note: 'Test Note 4',
      features: 'Test Features 4',
      phoneNumber: '9876543210',
      price: '20 USD',
      category: '2',
    );
    UrlModel urlModel5 = UrlModel(
      uid: '5',
      email: 'test5@example.com',
      name: 'Les Paul Junior',
      url: 'https://example.com/test2',
      imageUrl0:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl1:
          'https://m.media-amazon.com/images/I/61bukzq027L._AC_SL1500_.jpg',
      imageUrl2:
          'https://images.craigslist.org/00x0x_4Mxosrb1GCh_0CI0t2_600x450.jpg',
      imageUrl3:
          'https://images.craigslist.org/00x0x_4Mxosrb1GCh_0CI0t2_600x450.jpg',
      imageUrl4:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      address: 'Test Address 5',
      quality: 3,
      distance: 15,
      value: 6,
      size: 250,
      note: 'Test Note 2',
      features: 'Test Features 5',
      phoneNumber: '9876543210',
      price: '20 USD',
      category: '2',
    );
    UrlModel urlModel6 = UrlModel(
      uid: '6',
      email: 'test3@example.com',
      name: 'Fender Stratocaster',
      url: 'https://flutter.dev',
      imageUrl0:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      imageUrl1:
          'https://m.media-amazon.com/images/I/61bukzq027L._AC_SL1500_.jpg',
      imageUrl2:
          'https://images.craigslist.org/00x0x_4Mxosrb1GCh_0CI0t2_600x450.jpg',
      imageUrl3:
          'https://images.craigslist.org/00x0x_4Mxosrb1GCh_0CI0t2_600x450.jpg',
      imageUrl4:
          'https://images.craigslist.org/00404_a72iXCulVC_0CI0t2_600x450.jpg',
      address: 'Test Address 3',
      quality: 0,
      distance: 20,
      value: 7,
      size: 400,
      note: 'Test Note 3',
      features: 'Test Features 3',
      phoneNumber: '4561237890',
      price: '15 USD',
      category: '2',
    );

    // Create UrlModelList with test data
    final RxList<UrlModel> testDataList = RxList<UrlModel>(
        [urlModel1, urlModel2, urlModel3, urlModel4, urlModel5, urlModel6]);

    // Store the UrlModelList
    await storeUrlModelList(testDataList);
  }
}
