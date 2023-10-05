import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_loading_progress/overlay_loading_progress.dart';
import 'package:shopping_lister/helpers/string_util.dart';
import 'package:shopping_lister/ui/storage/stored_list_ui.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/cat_storage_controller.dart';
import '../../controllers/chatgpt_controller.dart';
import '../../controllers/storage_controller.dart';
import '../../models/category_model.dart';
import '../components/cat_list_item.dart';

class CatStorageListUI extends StatefulWidget {
  @override
  _StoredCatListUIState createState() => _StoredCatListUIState();
}

class _StoredCatListUIState extends State<CatStorageListUI> {
  final CatStorageController _catController = Get.find<CatStorageController>();
  final StorageController _storageController = Get.find<StorageController>();
  RxInt numItems = RxInt(0);
  String log = 'CatStorageListUI';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_storageController.length == 0) await _storageController.loadData();
    ever(_storageController.urlList, (_) => _storageController.updateItemCounts());
    _catController.callUpdate();
    print("CatStorageListUI");
    await getAI(); // Consider moving this call to a more appropriate place if needed
  }

  Future<void> getAI() async {
    try {
      await showLoadingOverlay();
      print('🟩 $log getAI():');
      await Get.find<ChatGPTController>().callAi();
    } catch (e) {
      print('Error in getAI: $e');
    } finally {
      OverlayLoadingProgress.stop();
    }
  }

  void newCategory(String title) {
    final List<String> existingUids =
        _catController.catList.map((cat) => cat.uid).toList();
    String uid = StringUtil.generateUniqueUid(existingUids);
    CategoryModel cat = CategoryModel(
      uid: uid,
      title: title,
      parent: '',
      icon: 1,
      color: 1,
      flag: 1,
      imageUrl:
          'https://icons.iconarchive.com/icons/paomedia/small-n-flat/128/folder-house-icon.png',
      numItems: 0,
    );
    _catController.addCat(cat);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Storage Categories'),
        ),
        body: FutureBuilder(
          future: _storageController.loadData(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _catController.restoreModel();
            });

            return Column(
              children: [
                Expanded(
                  child: GetBuilder<CatStorageController>(
                    builder: (catController) {
                      if (catController.isEmpty) {
                        return Center(
                          child: Text('No data stored'),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: catController.length,
                          itemBuilder: (context, index) => _buildCatListItem(context, catController, index),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCatListItem(BuildContext context, CatStorageController catController, int index) {
    CategoryModel catModel = catController.getCat(index);
    catModel.numItems = _storageController.getCounts(catModel.uid);
    numItems.value = catModel.numItems;

    return CatListItem(
      catModel: catModel,
      index: index,
      onEdit: (CategoryModel catModel) {
        Get.to(() => StoredListUI(), arguments: [
          {"uid": catModel.uid, "title": catModel.title},
        ]);
      },
      onDelete: () => _deleteUrlModel(context, index, catModel.uid),
    );
  }

  Future<void> _deleteUrlModel(
      BuildContext context, int index, String cat) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Delete this item and its contents?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      _catController.deleteCat(index);
      _storageController.deleteCatContents(cat);
      //_storageController.getCounts(cat); // Update item count after deletion
      _storageController.updateItemCounts();
      _catController.callUpdate();
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> showLoadingOverlay() async {
    await OverlayLoadingProgress.start(
      context,
      gifOrImagePath: 'assets/images/loading.gif',
      widget: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 19),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: CircleAvatar(
                radius: 290,
                backgroundImage: AssetImage('assets/images/aia_small.gif'),
              ),
            ),
            Text(
              'Connecting',
              style: TextStyle(
                  fontSize: 25.sp,
                  color: Colors.lightBlue,
                  letterSpacing: 1,
                  decorationStyle: TextDecorationStyle.double,
                  decorationColor: Colors.brown,
                  fontStyle: FontStyle.normal),
            ),
          ],
        ),
      ),
    );
  }
}
