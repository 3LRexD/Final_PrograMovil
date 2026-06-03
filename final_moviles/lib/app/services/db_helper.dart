import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'offline_rag.db');

    final exists = await databaseExists(path);
    
    if (!exists) {
      try {
        ByteData data = await rootBundle.load('assets/offline_rag.db');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception('Error copiando la base de datos: $e');
      }
    }
    
    return await openDatabase(path);
  }
}