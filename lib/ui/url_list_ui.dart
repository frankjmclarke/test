import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import 'package:get/get.dart';
import '../controllers/url_controller.dart';
import '../models/url_model.dart';
import 'components/url_list_item.dart';
import 'edit_url_ui.dart';

class UrlListUI extends StatelessWidget {
  final UrlController urlController = Get.put(UrlController());
  final CategoryController categoryController = Get.put(CategoryController());
  int urlsOnLoad = 0;

  @override
  Widget build(BuildContext context) {
    // Whenever the value of urlController.firestoreUrlList changes, the _updateCategoryTotal method is called.
    ever(urlController.firestoreUrlList, (_) => _updateCategoryTotal());
    return Scaffold(
      appBar: AppBar(
        title: Text('List'),
      ),
      body: Obx(
            () {
          //Inside the Obx widget, the current value of urlController.firestoreUrlList is checked.
          // If it is null, a CircularProgressIndicator is displayed
          if (urlController.firestoreUrlList.value == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final List<UrlModel> urls = urlController.firestoreUrlList.value!.urls;
            urlsOnLoad = urls.length;

            if (urls.isEmpty) {
              return Center(
                child: Text('No data available'),
              );
            } else {
              final filteredUrls = categoryController.uidCurrent == '07hVeZyY2PM7VK8DC5QX'
                  ? urls
                  : urls.where((urlModel) => urlModel.category == categoryController.uidCurrent).toList();

              if (filteredUrls.isEmpty) {
                return Center(
                  child: Text('No data available for the selected category'),
                );
              } else {
                return ListView.builder(
                  itemCount: filteredUrls.length,
                  itemBuilder: (context, index) {
                    UrlModel urlModel = filteredUrls[index];
                    return UrlListItem(
                      urlModel: urlModel,
                      index: index,
                      onEdit: _editUrlModel,
                      onDelete: () => _showDeleteConfirmation(context, urlModel),
                    );
                  },
                );
              }
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UrlModel urlModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteUrlModel(urlModel);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUrlModel(UrlModel urlModel) {
    urlController.deleteUrl(urlModel);
  }

  void _updateCategoryTotal() {
    categoryController.updateNumItems('07hVeZyY2PM7VK8DC5QX', urlsOnLoad);
  }

  void _editUrlModel(UrlModel urlModel) {
    Get.to(() => EditUrlScreen(urlModel: urlModel, urlController: urlController));
  }
}
