import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shopping_lister/helpers/html_util.dart';
import '../models/url_model.dart';
import '../ui/storage/category_pick_ui.dart';

class UrlController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Rxn<UrlModel> firebaseUrl = Rxn<UrlModel>();
  final Rxn<UrlModelList> firestoreUrlList = Rxn<UrlModelList>();
  StreamSubscription<String>? _textStreamSubscription;
  final RxBool admin = false.obs;

  static UrlController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    fetchUrlList();
    _textStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String text) {
      addUrl(text);
    });
    ReceiveSharingIntent.getInitialText().then((String? text) {
      if (text != null) {
        addUrl(text);
      }
    });
  }

  String extractLastWord(String text) {
    if (text.isEmpty) return '';

    final words = text.trim().split(' '); // Split the string into words
    return words.last; // Return the last word
  }

  void addUrl(String urlString) {
    if (!HtmlUtil.isValidURL(urlString)) {
      //   "ECOVACS DEEBOT X1 Omni Robot Vacuum Obstacle Avoidance https://a.co/d/1tCrwY0"
      urlString = (extractLastWord(urlString));
    }

    if (HtmlUtil.isValidURL(urlString))
      Get.to(() => CategoryPickUI(), arguments: [
        {'url': urlString},
      ]);
  }

  @override
  void onReady() async {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  bool containsText(String text) {
    final List<UrlModel>? urlList = firestoreUrlList.value?.urls;
    if (urlList != null) {
      return urlList.any((urlModel) => urlModel.url == text);
    }
    return false;
  }

/*
  Future<void> addTextToListIfUnique(String cat) async {
    if (!containsText(_sharedText)) {
      List<String> result = await HtmlUtil.fetchHtmlText(_sharedText);
      String name = result[0];
      String imageUrl = result[1];
      final currentList = firestoreUrlList.value ?? UrlModelList(urls: []);
      final newUrlModel = UrlModel(
        uid: '',
        email: '',
        name: name,
        url: _sharedText,
        imageUrl: imageUrl,
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
      currentList.urls.add(newUrlModel);
      firestoreUrlList.value = currentList;
      insertUrl(newUrlModel);
    }
  }
*/
  Future<void> fetchUrlList() async {
    try {
      final snapshot = await _db.collection('urls').get();
      final urls =
          snapshot.docs.map((doc) => UrlModel.fromMap(doc.data())).toList();
      firestoreUrlList.value = UrlModelList(urls: urls); //Rxn

      _db.collection('urls').snapshots().listen((snapshot) {
        final urls =
            snapshot.docs.map((doc) => UrlModel.fromMap(doc.data())).toList();
        firestoreUrlList.value = UrlModelList(urls: urls);
        print("Firestore collection updated");
      });

      print("fetchUrlList SUCCESS ");
    } catch (error) {
      print("🟥Error fetching url list: $error");
    }
  }

  Future<void> signOut() async {}

/*
  Future<void> insertUrl(UrlModel testUrl) async {
    try {
      // Convert the UrlModel to a JSON map
      Map<String, dynamic> jsonData = testUrl.toJson();

      final collectionRef = _db.collection('urls');
      final docRef = collectionRef.doc();
      print("FFFFFFFFFFFFFFFF"+docRef.id);
      testUrl.uid = docRef.id;

      // Insert the test UrlModel into Firestore
      await _db.collection('urls').doc(testUrl.uid).set(jsonData);
      //update();
      print('Test URL inserted successfully');
    } catch (error) {
      print('Error inserting test URL: $error');
    }
  }
*/
  Future<void> deleteUrl(UrlModel urlModel) async {
    try {
      // Delete the UrlModel from Firestore
      await _db.collection('urls').doc(urlModel.uid).delete();
      print('UrlModel deleted successfully');
    } catch (error) {
      print('🟥Error deleting UrlModel: $error');
    }
    //update();
  }

  Future<void> deleteUrlByCategory(String category) async {
    try {
      final urlsSnapshot = await _db
          .collection('urls')
          .where('category', isEqualTo: category)
          .get();

      for (final doc in urlsSnapshot.docs) {
        final urlModel = UrlModel.fromMap(doc.data());
        await deleteUrl(urlModel);
      }

      print('Urls deleted successfully for category: ${category}');
    } catch (error) {
      print('🟥Error deleting urls for category: ${category}, $error');
    }
  }

  Future<void> updateUrl(UrlModel updatedUrl) async {
    try {
      // Convert the updated UrlModel to a JSON map
      final jsonData = updatedUrl.toJson();

      // Update the URL document in Firestore
      await _db.collection('urls').doc(updatedUrl.uid).update(jsonData);

      print('URL updated successfully');
    } catch (error) {
      print('🟥Error updating URL: $error');
    }
  }

/*
  void updateUrl2(UrlModel updatedUrlModel) async {
    final index = firestoreUrlList.value!.urls
        .indexWhere((url) => url.uid == updatedUrlModel.uid);

    if (index != -1) {
      firestoreUrlList.value!.urls[index] = updatedUrlModel;

      // Convert the UrlModelList to a JSON representation
      final jsonData = firestoreUrlList.value!.toJson();

      try {
        // Save the updated list to Firestore
        await FirebaseFirestore.instance
            .collection('urls')
            .doc(StringUtil.generateRandomId(12))
            .update(jsonData as Map<Object, Object?>);

        // Refresh the UI
        firestoreUrlList.refresh();
      } catch (error) {
        // Handle any errors that occur during the Firestore operation
        print('Error updating URL: $error');
      }
    }
//    update();
  }
*/
  bool saveChanges(UrlModel updatedUrlModel) {
    if (updatedUrlModel.url.isEmpty) {
      // Display an error message or show a snackbar indicating missing fields
      return false;
    }
    updateUrl(updatedUrlModel);
    return true;
  }

  void saverChanges(UrlModel updatedUrlModel) async {
    try {
      // Convert the updated UrlModel to a JSON map
      final jsonData = updatedUrlModel.toJson();

      // Update the URL document in Firestore
      await _db.collection('urls').doc(updatedUrlModel.uid).update(jsonData);
      //update();
      print('URL updated successfully');
    } catch (error) {
      print('🟥Error updating URL: $error');
    }
  }
}
