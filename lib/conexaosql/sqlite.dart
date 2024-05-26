// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_Ffi.dart';

class DatabaseHelper {
  final String databaseName = "notes.db";
  final String userTable =
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrNome TEXT UNIQUE, usrContacto TEXT)";

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    // Inicializa o databaseFactoryFfi antes de abrir o banco de dados
    databaseFactory = databaseFactoryFfi;

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(userTable);
    });
  }

  Future<int> registerUser(String usrNome, String usrContacto) async {
    final Database db = await initDB();
    final Map<String, dynamic> userData = {
      'usrNome': usrNome,
      'usrContacto': usrContacto,
    };
    return db.insert('users', userData);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final Database db = await initDB();
    return db.query('users');
  }

  Future<int> updateUser(
      int usrId, String newUsrNome, String newUsrContacto) async {
    final Database db = await initDB();
    final Map<String, dynamic> updatedUserData = {
      'usrNome': newUsrNome,
      'usrContacto': newUsrContacto,
    };
    return db.update(
      'users',
      updatedUserData,
      where: 'usrId = ?',
      whereArgs: [usrId],
    );
  }
}
