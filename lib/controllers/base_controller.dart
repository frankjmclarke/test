import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import '../models/base_model.dart';

class BaseController<T extends BaseModel> extends GetxController {
  final box = GetStorage();
  final RxList<T> urlList = <T>[].obs;
  RxBool isDataLoaded = false.obs;
  String categoryFilter = '';
  final String ALL_ITEMS = '1';
  final String STORAGE_NAME = 'baseshoppermodel';

  bool get isEmpty => urlList.isEmpty;

  int get length => urlList.length;

  RxList<T> filteredDataList = <T>[].obs; //we never save this
  int get lengthFiltered => filteredDataList.length;

  bool filtered() => (categoryFilter.isNotEmpty && categoryFilter != ALL_ITEMS);

  @override
  void onInit() {
    super.onInit();
    readListAll();
  }

  Future<void> saveData() async {
    box.write(STORAGE_NAME, urlList.toList());
  }


  String readFirstNWords(String text, int max) {
    List<String> words = text.trim().split(' ');
    return words.length <= max ? words.join(' ') : words.sublist(0, max).join(
        ' ');
  }

  T? readUrlFiltered(int index) {
    if (index >= 0 && index < filteredDataList.length) {
      T url = filteredDataList[index];
      return url;
    }
    print('!!BASE!!!!!Invalid index');
    return null;
  }

  T? readUrlUnFiltered(int index) {
    if (index >= 0 && index < urlList.length) {
      T url = urlList[index];
      return url;
    }
    print('!!BASE!!readUrlUnFiltered!!!Invalid index');
    return null;
  }

  void deleteAllUrls() async {
    urlList.clear();
    filteredDataList.clear();
    await saveData();
  }

  void readListAll() {
    filteredDataList.value = urlList;
    isDataLoaded.value = true;
  }

}
