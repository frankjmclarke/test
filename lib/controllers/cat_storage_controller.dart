import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopping_lister/models/category_model.dart';
import '../helpers/string_util.dart';

class CatStorageController extends GetxController {
  final box = GetStorage();
  final RxList<CategoryModel> catList = <CategoryModel>[].obs;
  static const String _CAT_FILE_NAME = 'shoppercatmodel';

  Future<void> initStorage() async {
    await GetStorage.init();
  }

  void addCat(CategoryModel cat) {
    catList.add(cat);
    _storeCatModelList();
  }

  void updateCat(int index, CategoryModel newCat) {
    if (index >= 0 && index < catList.length) {
      catList[index] = newCat;
      _storeCatModelList();
    }
  }

  void deleteCat(int index) {
    if (index >= 0 && index < catList.length) {
      catList.removeAt(index);
      _storeCatModelList();
    }
  }

  void deleteCatByUri(String uri) {
    final index = catList.indexWhere((cat) => cat.imageUrl == uri);
    if (index != -1) {
      catList.removeAt(index);
      _storeCatModelList();
    }
  }

  CategoryModel getCat(int index) {
    if (index >= 0 && index < catList.length) {
      return catList[index];
    }
    throw Exception('Invalid index');
  }

  CategoryModel getCatByUri(String uid) {
    final index = catList.indexWhere((cat) => cat.uid == uid);
    CategoryModel cm = getCat(index);
    return cm;
  }

  void emptyList() {
    catList.clear();
    _storeCatModelList();
  }

  void callUpdate() {
    update();
  }

////////////////////////////////
  List<Map<String, String>> getCategories() {
    return catList
        .map((category) => {'title': category.title, 'uid': category.uid})
        .toList();
  }

  void storeCatModel(CategoryModel model) {
    box.write(_CAT_FILE_NAME, model.toMap());
  }

  bool get isEmpty => catList.isEmpty;

  int get length => catList.length;

  void addUrlModel(CategoryModel model) {
    addCat(model);
    _storeCatModelList();
  }

  void _storeCatModelListGeneric(RxList<CategoryModel> catLists) {
    List<Map<String, dynamic>> dataToSave =
        catLists.map((cat) => cat.toMap()).toList();
    box.write(_CAT_FILE_NAME, dataToSave);
    update();
  }

  void _storeCatModelList() {
    _storeCatModelListGeneric(catList);
  }

  void restoreModel() {
    final data = box.read<List<dynamic>>(_CAT_FILE_NAME);
    if (data != null) {
      final restoredList = data
          .map((data) => CategoryModel.fromMap(data as Map<String, dynamic>))
          .toList();
      catList.assignAll(restoredList);
    }
    update();
  }

  Future<void> insertCategoryName(String title) async {
    try {
      CategoryModel category = CategoryModel(
        uid: StringUtil.generateRandomId(15),
        title: title,
        parent: '07hVeZyY2PM7VK8DC5QX',
        icon: 1,
        color: 1,
        flag: 1,
        imageUrl: 'https://cdn.onlinewebfonts.com/svg/img_259453.png',
        numItems: 0,
      );
      addCat(category);
      print('New category inserted successfully');
    } catch (error) {
      print('🟥Error inserting new category: $error');
    }
  }

  /////////////TEST////////////////
  void createAndStoreTestData() {
    // Create test UrlModel objects
    CategoryModel categoryModel1 = CategoryModel(
      uid: '1',
      title: 'Everything',
      imageUrl:
          'https://icons.iconarchive.com/icons/paomedia/small-n-flat/128/folder-house-icon.png',
      parent: '07hVeZyY2PM7VK8DC5QX',
      icon: 0,
      color: 2,
      flag: 3,
      numItems: 5,
    );
    CategoryModel categoryModel2 = CategoryModel(
      uid: '2',
      title: 'Les Paul',
      imageUrl:
          'https://icons.iconarchive.com/icons/paomedia/small-n-flat/256/folder-document-icon.png',
      parent: '07hVeZyY2PM7VK8DC5QX',
      icon: 0,
      color: 2,
      flag: 3,
      numItems: 4,
    );
    CategoryModel categoryModel3 = CategoryModel(
      uid: '3',
      title: 'Cat3',
      imageUrl:
          'https://icons.iconarchive.com/icons/paomedia/small-n-flat/256/folder-document-icon.png',
      parent: '07hVeZyY2PM7VK8DC5QX',
      icon: 0,
      color: 2,
      flag: 3,
      numItems: 3,
    );

    // Create CategoryModelList with test data
    final RxList<CategoryModel> testDataList =
        RxList<CategoryModel>([categoryModel1, categoryModel2, categoryModel3]);

    // Store the UrlModelList
    _storeCatModelListGeneric(testDataList);
  }
}
