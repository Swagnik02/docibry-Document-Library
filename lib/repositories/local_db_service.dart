import 'package:docibry/models/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:docibry/models/document_model.dart';

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

  Future<StoreRef<int, Map<String, dynamic>>> _getUserDocsStoreLocalDb(
      String userEmail) async {
    final db = await _db;
    return intMapStoreFactory.store('users/$userEmail');
  }

  Future<void> addDocumentLocalDb(String userEmail, DocModel doc) async {
    final userStore = await _getUserDocsStoreLocalDb(userEmail);
    final db = await _db;

    final finder = Finder(filter: Filter.byKey(doc.uid));
    final existingDocs = await userStore.find(db, finder: finder);

    if (existingDocs.isEmpty) {
      await userStore.add(db, doc.toMap());
    } else {
      await userStore.update(db, doc.toMap(), finder: finder);
    }
  }

  Future<List<DocModel>> getDocumentsLocalDb(String userEmail) async {
    final userStore = await _getUserDocsStoreLocalDb(userEmail);
    final db = await _db;
    final finder = Finder(sortOrders: [SortOrder('uid')]);
    final recordSnapshots = await userStore.find(db, finder: finder);

    return recordSnapshots.map((snapshot) {
      final doc = DocModel.fromMap(snapshot.value);
      return doc.copyWith(uid: snapshot.key.toString());
    }).toList();
  }

  Future<void> updateDocumentLocalDb(String userEmail, DocModel doc) async {
    final userStore = await _getUserDocsStoreLocalDb(userEmail);
    final db = await _db;
    final finder = Finder(filter: Filter.byKey(doc.uid));
    await userStore.update(db, doc.toMap(), finder: finder);
  }

  Future<void> deleteDocumentLocalDb(String userEmail, String uid) async {
    final userStore = await _getUserDocsStoreLocalDb(userEmail);
    final db = await _db;
    final finder = Finder(filter: Filter.byKey(uid));
    await userStore.delete(db, finder: finder);
  }

  Future<List<String>> getTableNamesLocalDb() async {
    return ['users'];
  }

  Future<List<Map<String, dynamic>>> getTableDataLocalDb(
      String tableName) async {
    if (tableName != 'users') {
      throw Exception('Table $tableName does not exist.');
    }
    final db = await _db;
    final userStore = intMapStoreFactory.store('users');
    final recordSnapshots = await userStore.find(db);
    return recordSnapshots.map((snapshot) => snapshot.value).toList();
  }

  Future<UserModel?> getLoggedInUserLocalDb() async {
    try {
      final userStore = intMapStoreFactory.store('users');
      final db = await _db;

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
