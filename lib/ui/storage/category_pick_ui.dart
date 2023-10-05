import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_lister/controllers/cat_storage_controller.dart';
import 'package:shopping_lister/controllers/headerless.dart';
import 'package:shopping_lister/ui/storage/stored_list_ui.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/storage_controller.dart';
import '../../models/category_model.dart';

class CategoryPickUI extends StatelessWidget {
  final CatStorageController _categoryController =
      Get.put(CatStorageController());
  final StorageController _storageController = Get.put(StorageController());
  String log = 'CategoryPickUI';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Category'),
      ),
      //The Obx widget wraps the ListView.builder, and it observes the categories
      //list from the CategoryController. Whenever the categories list changes,
      //the ListView.builder is automatically rebuilt with the updated data.
      body: Obx(() => ListView.builder(
            itemCount: _categoryController.catList.length,
            itemBuilder: (context, index) {
              final catModel = _categoryController.catList[index];
              return _buildCategoryItem(catModel, context);
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              TextEditingController textController = TextEditingController();

              return AlertDialog(
                title: Text('New Category'),
                content: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      String title = textController.text;
                      insertCategoryName(title);
                      // categoryController.updateCategoryListInFirestore();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel catModel, BuildContext context) {
    String imageUrl = catModel.imageUrl.isNotEmpty
        ? catModel.imageUrl
        : 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Feral_pigeon_%28Columba_livia_domestica%29%2C_2017-05-27.jpg/1024px-Feral_pigeon_%28Columba_livia_domestica%29%2C_2017-05-27.jpg';
    /*   WidgetsBinding.instance.addPostFrameCallback((_) {
      if (needInsert){
       // doWebview( catModel);
      }
    });*/
    return Stack(
      children: [
        Card(
          child: Row(
            children: [
              SizedBox(
                height: 20.h,
                width: 20.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    bottomLeft: Radius.circular(4.0),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  onTap: () async {
                    /*String folderName = catModel.title;
                    String message = "Adding item to $folderName...";
                    ScaffoldMessenger.of(Get.context!).showSnackBar(
                      SnackBar(
                        content: Text(message),
                      ),
                    );*/
                    //OverlayLoadingProgress.start(context,
                    //   gifOrImagePath: 'assets/images/loading.gif',
                    //  );
                    insertUrlImages(catModel.uid);
                  },
                  title: Text(
                    catModel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  subtitle: Text(
                    catModel.numItems.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  trailing: Image.asset(
                    'assets/images/click_here.png',
                    width: 24, // Adjust the width as needed
                    height: 24, // Adjust the height as needed
                  ),
                ),
              ),
            ],
          ),
        ),
        /*   Opacity(
          opacity: 0.0,
          child: WebViewWidget(
            controller: controller,
          ),
        ),*/
      ],
    );
  }

  Future<void> insertUrlImages(String category) async {
    String url = Get.arguments?[0]['url'] ?? '';
    print('🟩 insertUrlImages message $url');
    Headerless hl = Headerless();
    print('🟩 $log  insertNewUrl : $url');
    bool success= await hl.insertUpdateUrlImages(url, category, newRecord: true);
    if (!success)
      await hl.insertUpdateUrlImages(url, category, newRecord: true);
    Get.off(() => StoredListUI(), arguments: [
      {"uid": category},
    ]);
  }

  Future<void> insertCategoryName(String title) async {
    _categoryController.insertCategoryName(title);
  }
}
