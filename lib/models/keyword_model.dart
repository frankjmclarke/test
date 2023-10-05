import 'base_model.dart';

class KeywordModel extends BaseModel {
  late String? uid;
  final String category;
  final String name;
  int upVotes;
  int downVotes;

  KeywordModel({
    required this.uid,
    required this.category,
    required this.name,
    required this.upVotes,
    required this.downVotes,    
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'category': category,
      'upVotes': upVotes,
      'downVotes': downVotes,
    };
  }

  factory KeywordModel.fromMap(Map<String, dynamic> map) {
    return KeywordModel(
      uid: map['uid'],
      name: map['name'],
      category: map['category'],
      upVotes: map['upVotes'],
      downVotes: map['downVotes'],
    );
  }
}

class KeywordModelList<T extends KeywordModel> {
  final List<T> urls;

  KeywordModelList({required this.urls});

  int get length => urls.length; // Getter for the length of the list

  bool get isNotEmpty => urls.isNotEmpty;

  T? get first => urls.isNotEmpty ? urls[0] : null;

  void add(T KeywordModel) {
    urls.add(KeywordModel);
  }

}
