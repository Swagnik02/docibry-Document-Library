import 'package:docibry/models/user_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  late final Database _db;

  // Initialize the database and stores
  Future<void> init() async {
    if (!kIsWeb) {
      _db = await _initDatabase();
    }
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
          'Database operations are not supported on the web.');
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'documents.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (kIsWeb) {
      throw UnsupportedError(
          'Database operations are not supported on the web.');
    }
    _database = await _initDatabase();
    return _database!;
  }

  // Get the store for a specific user
  Future<StoreRef<int, Map<String, dynamic>>> _getUserDocsStore(
      String userEmail) async {
    if (kIsWeb) {
      throw UnsupportedError(
          'Database operations are not supported on the web.');
    }
    final db = await database;
    final userStore = intMapStoreFactory.store('users/$userEmail');
    return userStore;
  }

  Future<void> insertDocument(String userEmail, DocModel doc) async {
    final userStore = await _getUserDocsStore(userEmail);
    final db = await database;

    // Check if the document already exists
    final finder =
        Finder(filter: Filter.byKey(doc.uid)); // No conversion to int here
    final existingDocs = await userStore.find(db, finder: finder);

    if (existingDocs.isEmpty) {
      await userStore.add(db, doc.toMap());
    } else {
      // Optionally update if needed
      await userStore.update(db, doc.toMap(), finder: finder);
    }
  }

  Future<List<DocModel>> getDocuments(String userEmail) async {
    if (kIsWeb) {
      throw UnsupportedError(
          'Database operations are not supported on the web.');
    }
    final userStore = await _getUserDocsStore(userEmail);
    final db = await database;
    final finder = Finder(sortOrders: [SortOrder('uid')]);
    final recordSnapshots = await userStore.find(db, finder: finder);

    return recordSnapshots.map((snapshot) {
      final doc = DocModel.fromMap(snapshot.value);
      return doc.copyWith(uid: snapshot.key.toString());
    }).toList();
  }

  Future<void> updateDocument(String userEmail, DocModel doc) async {
    final userStore = await _getUserDocsStore(userEmail);
    final db = await database;
    final finder =
        Finder(filter: Filter.byKey(doc.uid)); // No conversion to int here
    await userStore.update(db, doc.toMap(), finder: finder);
  }

  Future<void> deleteDocument(String userEmail, String uid) async {
    final userStore = await _getUserDocsStore(userEmail);
    final db = await database;
    final finder =
        Finder(filter: Filter.byKey(uid)); // No conversion to int here
    await userStore.delete(db, finder: finder);
  }

  Future<List<String>> getTableNames() async {
    if (kIsWeb) {
      return ['users']; // Simulate primary store or handle differently for web
    }
    // In Sembast, we cannot list tables dynamically.
    return ['users']; // Simulate primary store
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    if (kIsWeb) {
      if (tableName != 'users') {
        throw Exception('Table $tableName does not exist.');
      }
      // For the web, simulate or handle differently
      return [];
    }
    if (tableName != 'users') {
      throw Exception('Table $tableName does not exist.');
    }
    final db = await database;
    final userStore = intMapStoreFactory.store('users');
    final recordSnapshots = await userStore.find(db);
    return recordSnapshots.map((snapshot) => snapshot.value).toList();
  }

  // Retrieve the logged-in user from the offline database
  Future<UserModel?> getLoggedInUser() async {
    try {
      final userStore = intMapStoreFactory.store('users');
      final db = await database;

      // Assuming there's only one user logged in at a time
      final recordSnapshots = await userStore.find(db);
      if (recordSnapshots.isNotEmpty) {
        return UserModel.fromMap(recordSnapshots.first.value);
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving logged-in user from offline database: $e');
      return null;
    }
  }
}
