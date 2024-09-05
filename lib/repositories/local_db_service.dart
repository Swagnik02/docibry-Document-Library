import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/models/user_model.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Database? _database;

  Future<void> initLocalDb() async {
    _database = await _initDatabaseLocalDb();
  }

  Future<Database> _initDatabaseLocalDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'documents.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<Database> get _db async {
    _database ??= await _initDatabaseLocalDb();
    return _database!;
  }

  Future<StoreRef<String, Map<String, dynamic>>> _getDocsStore() async {
    final db = await _db;
    return stringMapStoreFactory.store('docs');
  }

  Future<void> addDocumentLocalDb(DocModel doc) async {
    final docsStore = await _getDocsStore();
    final db = await _db;
    await docsStore.record(doc.uid).put(db, doc.toMap());
  }

  Future<List<DocModel>> getDocumentsLocalDb() async {
    final docsStore = await _getDocsStore();
    final db = await _db;
    final finder = Finder(sortOrders: [SortOrder('uid')]);
    final recordSnapshots = await docsStore.find(db, finder: finder);

    return recordSnapshots.map(
      (snapshot) {
        final doc = DocModel.fromMap(snapshot.value);
        return doc.copyWith(uid: snapshot.key);
      },
    ).toList();
  }

  Future<void> updateDocumentLocalDb(DocModel doc) async {
    final docsStore = await _getDocsStore();
    final db = await _db;
    await docsStore.record(doc.uid).put(db, doc.toMap());
  }

  Future<void> deleteDocumentLocalDb(String uid) async {
    final docsStore = await _getDocsStore();
    final db = await _db;
    await docsStore.record(uid).delete(db);
  }

  Future<StoreRef<int, Map<String, dynamic>>> _getLoggedInUserStore() async {
    final db = await _db;
    return intMapStoreFactory.store('loggedInUserData');
  }

  Future<void> saveLoggedInUser(UserModel user) async {
    final store = await _getLoggedInUserStore();
    final db = await _db;
    final existingUser = await store.findFirst(db);
    if (existingUser == null) {
      await store.add(db, user.toMap());
    } else {
      await store.update(db, user.toMap(),
          finder: Finder(filter: Filter.byKey(existingUser.key)));
    }
  }

  Future<UserModel?> getLoggedInUser() async {
    try {
      final store = await _getLoggedInUserStore();
      final db = await _db;
      final recordSnapshots = await store.find(db);
      if (recordSnapshots.isNotEmpty) {
        return UserModel.fromMap(recordSnapshots.first.value);
      } else {
        return null;
      }
    } catch (e) {
      log('Error retrieving logged-in user from offline database: $e');
      return null;
    }
  }

  Future<void> deleteLoggedInUser() async {
    final store = await _getLoggedInUserStore();
    final db = await _db;
    final existingUser = await store.findFirst(db);
    if (existingUser != null) {
      await store.delete(db,
          finder: Finder(filter: Filter.byKey(existingUser.key)));
    }
  }

  Future<List<String>> getTableNamesLocalDb() async {
    return ['docs', 'loggedInUserData'];
  }

  Future<List<Map<String, dynamic>>> getTableDataLocalDb(
      String tableName) async {
    if (tableName != 'docs' && tableName != 'loggedInUserData') {
      throw Exception('Table $tableName does not exist.');
    }
    final db = await _db;
    final store = tableName == 'docs'
        ? stringMapStoreFactory.store(tableName)
        : intMapStoreFactory.store(tableName);
    final recordSnapshots = await store.find(db);
    return recordSnapshots.map((snapshot) => snapshot.value).toList();
  }

  Future<void> logout(String userUid, String uid) async {
    try {
      deleteDatabaseFile();
      log('Data cleared successfully during logout');
    } catch (e) {
      log('Error during logout and clearing local database: $e');
    }
  }

  Future<void> saveDbFileToDownloads() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = join(dir.path, 'documents.db');
      final dbFile = File(dbPath);
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final downloadFilePath = join(downloadsDir.path, 'documents.db');
      await dbFile.copy(downloadFilePath);
      log('Database file copied to Downloads folder');
    } catch (e) {
      log('Error copying database file: $e');
    }
  }

  Future<void> deleteDatabaseFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = join(dir.path, 'documents.db');
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
        log('Database file deleted successfully');
      } else {
        log('Database file does not exist');
      }
    } catch (e) {
      log('Error deleting database file: $e');
    }
  }
}
