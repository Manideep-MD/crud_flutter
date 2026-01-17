import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class HiveHelper {
  static const String boxName = 'crudOperationBox';

  // initialization hive
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  // get box
  static Box get box => Hive.box(boxName);

  // To set the particular data from the box
  static Future<void> setData(String key, dynamic val) async {
    await box.put(key, val);
  }

  // To get the particular data from the box
  static String getData(String key) {
    return box.get(key);
  }

  // To delete the particular data from the box
  static Future<void> deleteData(String key) async {
    await box.delete(key);
  }

  // To clear the complete box data
  static Future<void> clearAllData() async {
    await box.clear();
  }
}
