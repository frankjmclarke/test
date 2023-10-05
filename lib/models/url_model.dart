import '../helpers/string_util.dart';
import 'base_model.dart';

class UrlModel extends BaseModel {
  late String? uid;
  final String email;
  final String name;
  final String url;
   String imageUrl0;
   String imageUrl1;
   String imageUrl2;
   String imageUrl3;
   String imageUrl4;
  final String address;
    int quality;
  final int distance;
  final int value;
  final int size;
  final String note;
  final String features;
  final String phoneNumber;
  final String price;
  final String category;

  UrlModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.url,
    required this.imageUrl0,
    required this.imageUrl1,
    required this.imageUrl2,
    required this.imageUrl3,
    required this.imageUrl4,
    required this.address,
    required this.quality,
    required this.distance,
    required this.value,
    required this.size,
    required this.note,
    required this.features,
    required this.phoneNumber,
    required this.price,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'url': url,
      'imageUrl0': imageUrl0,
      'imageUrl1': imageUrl1,
      'imageUrl2': imageUrl2,
      'imageUrl3': imageUrl3,
      'imageUrl4': imageUrl4,
      'address': address,
      'quality': quality,
      'distance': distance,
      'value': value,
      'size': size,
      'note': note,
      'features': features,
      'phoneNumber': phoneNumber,
      'price': price,
      'category': category,
    };
  }

  // Omitted copyWith, fromJson, fromMap, toJson for brevity

  static T fromJson<T extends UrlModel>(Map<String, dynamic> json) {
    return UrlModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      url: json['url'],
      imageUrl0: json['imageUrl0'],
      imageUrl1: json['imageUrl1'],
      imageUrl2: json['imageUrl2'],
      imageUrl3: json['imageUrl3'],
      imageUrl4: json['imageUrl4'],
      address: json['address'],
      quality: json['quality'],
      distance: json['distance'],
      value: json['value'],
      size: json['size'],
      note: json['note'],
      features: json['features'],
      phoneNumber: json['phoneNumber'],
      price: json['price'],
      category: json['category'],
    ) as T;
  }

  static T fromMap<T extends UrlModel>(Map<String, dynamic> data) {
    return UrlModel(
      uid: data['uid'] ?? StringUtil.generateUid(),
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      url: data['url'] ?? '',
      imageUrl0: data['imageUrl0'] ?? '',
      imageUrl1: data['imageUrl1'] ?? '',
      imageUrl2: data['imageUrl2'] ?? '',
      imageUrl3: data['imageUrl3'] ?? '',
      imageUrl4: data['imageUrl4'] ?? '',
      address: data['address'] ?? '',
      quality: data['quality'] ?? 0,
      distance: data['distance'] ?? 0,
      value: data['value'] ?? 0,
      size: data['size'] ?? 0,
      note: data['note'] ?? '',
      features: data['features'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      price: data['price'] ?? '',
      category: data['category'] ?? '',
    ) as T;
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "email": email,
    "name": name,
    "url": url,
    "imageUrl0": imageUrl0,
    "imageUrl1": imageUrl1,
    "imageUrl2": imageUrl2,
    "imageUrl3": imageUrl3,
    "imageUrl4": imageUrl4,
    "address": address,
    "quality": quality,
    "distance": distance,
    "value": value,
    "size": size,
    "note": note,
    "features": features,
    "phoneNumber": phoneNumber,
    "price": price,
    "category": category,
  };

  void rotateImageUrls() {
    String lastImageUrl = imageUrl4;
    imageUrl4 = imageUrl3;
    imageUrl3 = imageUrl2;
    imageUrl2 = imageUrl1;
    imageUrl1 = imageUrl0;
    imageUrl0 = lastImageUrl;
  }
}

class UrlModelList<T extends UrlModel> {
  final List<T> urls;

  UrlModelList({required this.urls});

  int get length => urls.length; // Getter for the length of the list
/*
  factory UrlModelList.fromList(List<Map<String, dynamic>>? dataList) {
    List<T> urlModels = [];
    if (dataList != null) {
      urlModels = dataList.map((data) => UrlModel.fromMap(data) as T).toList();
    }
    return UrlModelList<T>(urls: urlModels);
  }
*/
  List<Map<String, dynamic>> toJson() =>
      urls.map((urlModel) => urlModel.toJson()).toList();

  Map<String, dynamic> toMap() {
    return {
      'urls': urls.map((urlModel) => urlModel.toMap()).toList(),
    };
  }

  bool get isNotEmpty => urls.isNotEmpty;

  T? get first => urls.isNotEmpty ? urls[0] : null;

  void add(T urlModel) {
    urls.add(urlModel);
  }
/*
  factory UrlModelList.fromMap(Map<String, dynamic> map) {
    final List<Map<String, dynamic>> urlMaps =
    (map['urls'] as List<dynamic>).cast<Map<String, dynamic>>();
    List<T> urlModels =
    urlMaps.map((data) => UrlModel.fromMap(data) as T).toList(growable: false);
    return UrlModelList<T>(urls: urlModels);
  }*/
}
