import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_lister/controllers/key_word_controller.dart';
import '../../controllers/cat_storage_controller.dart';
import '../../controllers/headerless.dart';
import '../../controllers/storage_controller.dart';
import '../../models/url_model.dart';
import '../webview/browser_ui.dart';
import '../components/url_list_item.dart';
import '../webview/webview_ui.dart';

class StoredListUI extends StatefulWidget {
  @override
  _StoredListUIState createState() => _StoredListUIState();
}

class _StoredListUIState extends State<StoredListUI> {
  final StorageController _storageController = Get.find<StorageController>();
  final Key_wordController _keywordsController = Get.find<Key_wordController>();
  String uid ='';
  String? title;
  String log = 'StoredListUI';

  @override
  void initState() {
    super.initState();
    var args = Get.arguments[0];
    CatStorageController _cc = Get.find<CatStorageController>();
    if (args != null) {
      uid = args['uid'] ?? "";
      title = _cc.getCatByUri(uid).title;
    } else {
      uid = "";
      title = "Folder contents";
    }
    print('$log🟩 initState uid $uid');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _storageController.loadData();
    _storageController.readListFiltered(uid);
  }

  void handleEdit(UrlModel urlModel, int index) {
    Get.to(() => WebviewUI(), arguments: [
      {'url': urlModel.url, 'index': index}
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {//Just Google, no FABs
                Get.to(() => BrowserUI(), arguments: [
                  {'url': 'http://www.google.com'},
                ]);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<StorageController>(
              builder: (controller) {
                //_storageController.readListFiltered(uid!); // Reload the stored data
                //_storageController.createAndStoreTestData();
                if (controller.isEmpty) {
                  //if (uid == _storageController.ALL_ITEMS)
                  return Center(
                    child: Text('No data stored.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: controller.lengthFiltered,
                    itemBuilder: (context, index) {
                      UrlModel? urlModel = controller.readUrlFiltered(index);
                      if (urlModel != null) {
                        return UrlListItem(
                          urlModel: urlModel,
                          index: index,
                          onEdit: (UrlModel urlModel) {
                            handleEdit(urlModel, index);
                          },
                          onDelete: () => _deleteUrlModel(index, urlModel),
                        );
                      } else {
                        return Container(); // Return an empty container if urlModel is null
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: GetX<Key_wordController>(
        builder: (controller) {
          return Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: controller.isButtonPressedRecently.value ? Colors.grey : null,
              child: Icon(Icons.add),
              onPressed: controller.isButtonPressedRecently.value
                  ? null
                  : () async {
                controller.isButtonPressedRecently.value = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  String url = await _keywordsController.generateSearchString(uid);
                  if (uid.isNotEmpty) {
                    Headerless hl = Headerless();
                    bool success = await hl.searchAndInsertUrlNoImages(url, uid);
                    if (!success)
                      await hl.searchAndInsertUrlNoImages(url, uid);
                  }
                });
                await Future.delayed(Duration(seconds: 10));
                controller.isButtonPressedRecently.value = false;
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteUrlModel(int index, UrlModel urlModel) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
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
      _storageController.deleteUid(urlModel.uid ?? "");
      //TODO delete  'shopaikey' + uid and 'shopnamelist' + uid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item deleted'),
        ),
      );
    }
  }
}

/* _keywordsController.generateSearchString(uid);hl.searchAndInsertUrlNoImages(url, uid)
🟩🟢 checkForNewNames 2 newNames Tune-o-matic bridge, Wireless technology,Grilling, Single cutaway,Stainless steel, P-90 pickup,Tremolo bridge, Musical instruments,Vintage style, Electric guitar,Classic, Gibson,Gibson, Guitar,Heritage, Cherry,Sunburst, Junior,Guitar, Electric,maple top, humbucker pickups,rich tone, rock music,electric guitar, precision craftsmanship,maple top, electric guitar,rock music, precision craftsmanship,guitar accessories, electric guitars,guitar accessories, guitar maintenance,guitar playing styles, guitar customization,electric guitars, guitar accessories,guitar accessories, vintage guitar models,Rosewood fretboard, Solid body,Solid body, P-90 pickups,Mahogany body and neck, Humbucker pickups,Solid body, Tune-o-matic bridge,Tune-o-matic bridge, Nitrocellulose finish,Tune-o-matic bridge, Cherry sunburst finish,Solid body guitar, Humbucker pickups,Mahogany body and neck, Electric guitar,Vintage style, Single cutaway,Mahogany body and neck, Tune-o-matic bridge,Heritage collection,
🟩🟢 Key_wordController  generateSearchString : https://www.google.com/search?q=Gibson Les Paul Classic LPCS00HSNH Heritage
🟩🟢 Headerless insertNewUrlNoImages onWebViewCreated: https://www.google.com/search?q=Gibson Les Paul Classic LPCS00HSNH Heritage
🟩🟢 Headerless insertNewUrlNoImages onLoadStop: https://www.google.com/search?q=Gibson%20Les%20Paul%20Classic%20LPCS00HSNH%20Heritage
🟩🟢 BrowserController  googleLink2Url : https://www.google.com/search?q=Gibson Les Paul Classic LPCS00HSNH Heritage
🟩🟢 BrowserController  productLinkToUrl : https://www.tomleemusic.ca/gibson-les-paul-classic-heritage-cherry-sunburst-electric-guitar-210453
🟩🟢 Headerless insertUpdateUrlImages onWebViewCreated: https://www.tomleemusic.ca/gibson-les-paul-classic-heritage-cherry-sunburst-electric-guitar-210453
🟩🟢 Headerless insertUpdateUrlImages onLoadStop: https://www.tomleemusic.ca/gibson-les-paul-classic-heritage-cherry-sunburst-electric-guitar-210453
🟩🟢  pre insertUrlWithImages
🟩🟢 Headerless insertNewUrlNoImages onLoadStop: https://www.google.com/search?q=Gibson%20Les%20Paul%20Classic%20LPCS00HSNH%20Heritage
🟩🟢  post insertUrlWithImages
 */
