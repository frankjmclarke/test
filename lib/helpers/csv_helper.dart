import 'dart:collection';
import 'package:serial_csv/serial_csv.dart';

class CsvHelper {
  List<List<dynamic>>? _decodedList;
  dynamic encodedItem;
  LinkedHashMap<String, int> fieldMap = LinkedHashMap.from({});

  void setFieldNames(List<String> fieldNames) {
    for (int i = 0; i < fieldNames.length; i++) {
      fieldMap[fieldNames[i]] = i;
    }
  }

  dynamic de_code(int rowIndex, String fieldName,   List<dynamic> list) {
    try {
      int key = fieldMap[fieldName]!;
      return list[rowIndex][key];
    }catch (e){
      return 0;
    }
  }

  dynamic decode(String name, int index) {
    if ((_decodedList == null || _decodedList!.isEmpty) &&
        (encodedItem != null && encodedItem!.isNotEmpty)) {
      _decodedList = SerialCsv.decode(encodedItem);
    }
    if (index < _decodedList!.length) {
      int key = fieldMap[name]!;
      return _decodedList![index][key];
    }
    return null;
  }

  dynamic encode(List<List<String>> rows) {
    encodedItem= SerialCsv.encodeStrings(rows);
    return encodedItem;
  }

  String listToCSV(List<dynamic> dataList) {
    String csvString = '';
    for (var data in dataList) {
      if (data is List<dynamic>) {
        csvString += listToCSV(data) + '\n';
      } else {
        csvString += '$data,';
      }
    }
    return csvString;
  }

  String mapToCSV(Map<String, dynamic> map) {
    List<dynamic> values = map.values.toList();
    String csvString = values.map((value) => '$value').join(',');
    return csvString;
  }

  String convertMapToCSV(Map<String, dynamic> amap) {
    String csvString = '';
    amap.forEach((key, value) {
      csvString += '$key,$value\n';
    });
    return csvString;
  }
}
