import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'catatan.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'catatan.db'),
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE catatan (
          id       INTEGER PRIMARY KEY AUTOINCREMENT,
          judul    TEXT    NOT NULL,
          isi      TEXT    NOT NULL,
          kategori TEXT    NOT NULL,
          dibuat_pada INTEGER NOT NULL
        )
      '''),
    );
  }

  Future<int> insert(Catatan catatan) async {
    final db = await database;
    return db.insert('catatan', catatan.toMap());
  }

  Future<List<Catatan>> getAll() async {
    final db = await database;
    final rows = await db.query('catatan', orderBy: 'dibuat_pada DESC');
    return rows.map(Catatan.fromMap).toList();
  }

  Future<int> update(Catatan catatan) async {
    final db = await database;
    return db.update(
      'catatan',
      catatan.toMap(),
      where: 'id = ?',
      whereArgs: [catatan.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }
}