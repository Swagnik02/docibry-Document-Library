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

  Future<List<DocModel>> getDocuments(String userEmail) async {
    if (kIsWeb) {
      return await _firestoreDbService.getDocumentFromFirestore(userEmail);
    } else {
      return await _localDbService.getDocumentsLocalDb(userEmail);
    }
  }

  Future<void> addDocument(String userEmail, DocModel doc) async {
    if (kIsWeb) {
      await _firestoreDbService.addDocumentFromFirestore(userEmail, doc);
    } else {
      await _localDbService.addDocumentLocalDb(userEmail, doc);
      if (await _isInternetAvailable()) {
        await _firestoreDbService.addDocumentFromFirestore(userEmail, doc);
      }
    }
  }

  Future<void> updateDocument(String userEmail, DocModel doc) async {
    if (kIsWeb) {
      await _firestoreDbService.updateDocumentFromFirestore(userEmail, doc);
    } else {
      await _localDbService.updateDocumentLocalDb(userEmail, doc);
      if (await _isInternetAvailable()) {
        await _firestoreDbService.updateDocumentFromFirestore(userEmail, doc);
      }
    }
  }

  Future<void> deleteDocument(String userEmail, String uid) async {
    if (kIsWeb) {
      await _firestoreDbService.deleteDocumentFromFirestore(userEmail, uid);
    } else {
      await _localDbService.deleteDocumentLocalDb(userEmail, uid);
      if (await _isInternetAvailable()) {
        await _firestoreDbService.deleteDocumentFromFirestore(userEmail, uid);
      }
    }
  }

  Future<void> syncLocalWithFirestore(String userEmail) async {
    if (kIsWeb) return; // Syncing not applicable for web, implement if needed

    try {
      if (await _isInternetAvailable()) {
        final firestoreDocs =
            await _firestoreDbService.getDocumentFromFirestore(userEmail);
        final localDocs = await _localDbService.getDocumentsLocalDb(userEmail);

        // Add new documents to local storage
        final newDocs = firestoreDocs
            .where((doc) => !localDocs.any((local) => local.uid == doc.uid));
        for (var doc in newDocs) {
          await _localDbService.addDocumentLocalDb(userEmail, doc);
        }

        // Remove documents from local storage that are no longer in Firestore
        final removedDocs = localDocs.where((doc) =>
            !firestoreDocs.any((firestoreDoc) => firestoreDoc.uid == doc.uid));
        for (var doc in removedDocs) {
          await _localDbService.deleteDocumentLocalDb(userEmail, doc.uid);
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
