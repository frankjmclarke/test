class BaseModel {
  BaseModel();
}

class BaseModelList<T extends BaseModel> {
  final List<T> urls;

  BaseModelList({required this.urls});

  int get length => urls.length; // Getter for the length of the list

  bool get isNotEmpty => urls.isNotEmpty;

  T? get first => urls.isNotEmpty ? urls[0] : null;

  void add(T BaseModel) {
    urls.add(BaseModel);
  }
}
