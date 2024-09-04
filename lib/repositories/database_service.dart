import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/repositories/local_db_service.dart';
import 'package:docibry/repositories/firestore_db_service.dart';
import 'package:http/http.dart' as http;

class DatabaseService {
  final LocalDbService _localDbService = LocalDbService();
  final FirestoreDbService _firestoreDbService = FirestoreDbService();

  Future<void> init() async {
    if (!kIsWeb) {
      await _localDbService.initLocalDb();
    }
  }

  Future<List<DocModel>> getDocuments(String userUid) async {
    if (kIsWeb) {
      return await _firestoreDbService.getDocumentFromFirestore(userUid);
    } else {
      return await _localDbService.getDocumentsLocalDb(userUid);
    }
  }

  Future<void> addDocument(String userUid, DocModel doc) async {
    if (kIsWeb) {
      await _firestoreDbService.addDocumentFromFirestore(userUid, doc);
    } else {
      await _localDbService.addDocumentLocalDb(userUid, doc);
      if (await _isInternetAvailable()) {
        await _firestoreDbService.addDocumentFromFirestore(userUid, doc);
      }
    }
  }

  Future<void> updateDocument(String userUid, DocModel doc) async {
    if (kIsWeb) {
      await _firestoreDbService.updateDocumentFromFirestore(userUid, doc);
    } else {
      await _localDbService.updateDocumentLocalDb(userUid, doc);
      if (await _isInternetAvailable()) {
        await _firestoreDbService.updateDocumentFromFirestore(userUid, doc);
      }
    }
  }

  Future<void> deleteDocument(String userUid, String docUid) async {
    if (kIsWeb) {
      await _firestoreDbService.deleteDocumentFromFirestore(userUid, docUid);
    } else {
      await _localDbService.deleteDocumentLocalDb(userUid, docUid);
      if (await _isInternetAvailable()) {
        await _firestoreDbService.deleteDocumentFromFirestore(userUid, docUid);
      }
    }
  }

  Future<void> syncLocalWithFirestore(String userUid) async {
    if (kIsWeb) return;

    try {
      if (await _isInternetAvailable()) {
        final firestoreDocs =
            await _firestoreDbService.getDocumentFromFirestore(userUid);
        final localDocs = await _localDbService.getDocumentsLocalDb(userUid);

        final newDocs = firestoreDocs
            .where((doc) => !localDocs.any((local) => local.uid == doc.uid));
        for (var doc in newDocs) {
          await _localDbService.addDocumentLocalDb(userUid, doc);
        }

        final removedDocs = localDocs.where((doc) =>
            !firestoreDocs.any((firestoreDoc) => firestoreDoc.uid == doc.uid));
        for (var doc in removedDocs) {
          await _localDbService.deleteDocumentLocalDb(userUid, doc.uid);
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<bool> _isInternetAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
