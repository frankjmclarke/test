import 'package:flutter/material.dart';
import 'package:shopping_lister/ui/storage/stored_list_ui.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controllers/category_controller.dart';
import '../models/category_model.dart';

class CategoryListUI extends StatelessWidget {
  final CategoryController categoryController = Get.put(CategoryController());

  void _showDeleteConfirmationDialog(CategoryModel category) {
    Get.dialog(//no context required
      AlertDialog(
        title: Text('Delete Category'),
        content: Text('Delete this category AND it\'s contents?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              categoryController.deleteCategory(category);
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      //The Obx widget wraps the ListView.builder, and it observes the categories
      //list from the CategoryController. Whenever the categories list changes,
      //the ListView.builder is automatically rebuilt with the updated data.
      body: Obx(() {
        final firestoreCategoryList = categoryController.firestoreCategoryList.value;
        if (firestoreCategoryList == null) {
          return CircularProgressIndicator(color:Colors.green);
        } else {
          return ListView.builder(
            itemCount: firestoreCategoryList.categories.length,
            itemBuilder: (context, index) {
              final CategoryModel catModel = firestoreCategoryList.categories[index];
              return _buildCategoryItem(catModel);
            },
          );
        }
      }),

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


  Widget _buildCategoryItem(CategoryModel catModel) {
    String imageUrl = catModel.imageUrl.isNotEmpty
        ? catModel.imageUrl
        : 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Feral_pigeon_%28Columba_livia_domestica%29%2C_2017-05-27.jpg/1024px-Feral_pigeon_%28Columba_livia_domestica%29%2C_2017-05-27.jpg';

    return Card(
      child: Stack(
        children: [
          Row(
            children: [
              SizedBox(
                height: 20.h,
                width: 20.w, // Set the width equal to the height of the card
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.0), // Adjust the border radius as needed
                    bottomLeft: Radius.circular(4.0), // Adjust the border radius as needed
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain, // large as possible while still containing the source entirely within the target box.
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  onTap: () {
                    categoryController.uidCurrent = catModel.uid;
                    Get.to(() => StoredListUI());//UrlListUI
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
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _showDeleteConfirmationDialog(catModel);
              },
              child: Icon(
                Icons.delete,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> insertCategoryName(String title) async {
    categoryController.insertCategoryName(title);
  }

}
