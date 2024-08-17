import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:docibry/models/document_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'documents.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents (
            uid INTEGER PRIMARY KEY,
            docName TEXT,
            docCategory TEXT,
            docId TEXT,
            holdersName TEXT,
            dateAdded INTEGER,
            docFile TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertDocument(DocModel doc) async {
    final db = await database;
    await db.insert(
      'documents',
      doc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DocModel>> getDocuments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('documents');
    return List.generate(maps.length, (i) {
      return DocModel(
        uid: maps[i]['uid'],
        docName: maps[i]['docName'],
        docCategory: maps[i]['docCategory'],
        docId: maps[i]['docId'],
        holdersName: maps[i]['holdersName'],
        dateAdded: DateTime.fromMillisecondsSinceEpoch(maps[i]['dateAdded']),
        docFile: maps[i]['docFile'],
      );
    });
  }

  // db viewer
  Future<List<String>> getTableNames() async {
    final db = await database;
    final List<Map<String, dynamic>> tables = await db.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table'
    ''');
    return tables.map((table) => table['name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }
}
