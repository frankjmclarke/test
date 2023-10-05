import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:serial_csv/serial_csv.dart';

import '../helpers/csv_helper.dart';
/*
Load/Save a list of strings. If the strings are CSV strings they can be mapped to field names
 */
class StringListController extends GetxController {
  final box = GetStorage();
  List<String> _list=[];
  String _filename ='';
  CsvHelper csv = CsvHelper();

  int get length => _list.length;
  List<String> get() => _list;

  void saveStringList() {
    box.write(_filename, _list);
  }

  void csvAdd(String item) {
    csv.encodedItem = item;
    if (!_list.contains(item)) {
      _list.add(item);
      saveStringList();
    }
  }

  void initCSV(List<String> fieldNames){
    _filename = fieldNames[0];
    fieldNames.removeAt(0);
    csv.setFieldNames(fieldNames);//csv can now call decode
  }
/*
  dynamic csvGet(int index, String name){
    try {
      return csv.decode(name, index);
    } catch(e){
      return null;
    }
  }*/

  dynamic csvGetField(int rowIndex, String fieldName, List<dynamic> list){
    try {
      return csv.de_code(rowIndex, fieldName, list);
    } catch(e){
      return null;
    }
  }

/*  String csvGetByIndex(int index){
    try {
      return _list[index];
    } catch(e){
      return '';
    }
  }*/

  String csvGetter( int rowIndex, String fieldName){
    try {
      String csv= _list[rowIndex];
      List de_coded=de_code(csv);
      String str = csvGetField(rowIndex,fieldName,de_coded);
      return str;
    } catch(e){
      return '';
    }
  }

  List<List<dynamic>> de_code(String csv) {
    try {
      return SerialCsv.decodeStrings(csv);
    } catch (e) {
      print('🟥Error decoding CSV: $e');
      return [];
    }
  }

  loadStringList(String filename) {
    _filename = filename;
    _list = (box.read(filename) as List<dynamic>?)?.cast<String>() ?? [];
    return _list;
  }

  void mergeIn(List<String> newList) {
    Set<String> mergedSet = Set<String>.from(_list); // no duplicates
    mergedSet.addAll(newList);
    _list = mergedSet.toList();
  }

  void deleteFile() {
    _list = [];
    box.remove(_filename);
  }

  void emptyList() {
    _list=[];
  }
}