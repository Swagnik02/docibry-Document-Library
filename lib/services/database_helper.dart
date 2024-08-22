import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:docibry/models/document_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;
  final _store = intMapStoreFactory.store('documents');

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'documents.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> insertDocument(DocModel doc) async {
    final db = await database;
    await _store.add(db, doc.toMap());
  }

  Future<List<DocModel>> getDocuments() async {
    final db = await database;
    final finder = Finder(sortOrders: [SortOrder('uid')]);
    final recordSnapshots = await _store.find(db, finder: finder);

    return recordSnapshots.map((snapshot) {
      final doc = DocModel.fromMap(snapshot.value);
      return doc.copyWith(uid: snapshot.key);
    }).toList();
  }

  Future<void> updateDocument(DocModel doc) async {
    final db = await database;
    final finder = Finder(filter: Filter.byKey(doc.uid));
    await _store.update(db, doc.toMap(), finder: finder);
  }

  Future<void> deleteDocument(int uid) async {
    try {
      final db = await database;
      final finder = Finder(filter: Filter.byKey(uid));
      await _store.delete(db, finder: finder);
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // db viewer
  Future<List<String>> getTableNames() async {
    // sembast does not have traditional SQL tables,
    // so we can't list table names directly. This method is redundant.
    return ['documents']; // Just to simulate one store as table
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    if (tableName != 'documents') {
      throw Exception('Table $tableName does not exist.');
    }
    final db = await database;
    final recordSnapshots = await _store.find(db);
    return recordSnapshots.map((snapshot) => snapshot.value).toList();
  }
}
