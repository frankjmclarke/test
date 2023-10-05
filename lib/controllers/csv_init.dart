import 'package:serial_csv/serial_csv.dart';

class CsvFiles {
//final StringListController _stringController = Get.find<StringListController>();
  static List<String> checksumInit() {
   return ['shopchecksum','checksum1','checksum2'];
  }

  static String checksumString(int checksum1, int checksum2){
    List<List<String>> rows = [[checksum1.toString(), checksum1.toString()]];
    return  SerialCsv.encodeStrings(rows);// a csv string
  }
}