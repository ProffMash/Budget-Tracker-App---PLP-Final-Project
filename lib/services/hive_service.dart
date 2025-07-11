import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Box<T> openBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  static Future<void> closeBox<T>(String boxName) async {
    await Hive.box<T>(boxName).close();
  }

  static Future<void> clearBox<T>(String boxName) async {
    await Hive.box<T>(boxName).clear();
  }
}
