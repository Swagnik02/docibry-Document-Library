import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/services/database_helper.dart';
import 'package:docibry/services/firestore_helper.dart'; // Ensure you have a FirestoreHelper class
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  final String userId;

  DocumentBloc({required this.userId}) : super(DocumentInitial()) {
    if (!kIsWeb) _dbHelper.init();
    on<FetchDocuments>(_onFetchDocuments);
    on<AddDocument>(_onAddDocument);
    on<UpdateDocument>(_onUpdateDocument);
    on<DeleteDocument>(_onDeleteDocument);
  }

  Future<void> _onFetchDocuments(
      FetchDocuments event, Emitter<DocumentState> emit) async {
    try {
      emit(DocumentLoading());

      List<DocModel> documents;

      // Load local documents first
      if (!kIsWeb) {
        documents = await _dbHelper.getDocuments(userId);
        emit(DocumentLoaded(documents: documents));

        // Start background sync with Firestore
        _syncWithFirestoreInBackground();
      } else {
        // Web-specific logic to fetch documents
        log('Fetching documents on Web');
        documents = await _firestoreHelper.fetchDocumentsForUser(userId);
        emit(DocumentLoaded(documents: documents));
      }
    } catch (e) {
      log('Error fetching documents: $e');
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _onAddDocument(
      AddDocument event, Emitter<DocumentState> emit) async {
    try {
      final doc = DocModel(
        docName: event.docName,
        docCategory: event.docCategory,
        docId: event.docId.isNotEmpty ? event.docId : ' ',
        holdersName: event.holdersName.isNotEmpty ? event.holdersName : ' ',
        dateAdded: DateTime.now(),
        docFile: event.filePath,
      );

      if (kIsWeb) {
        log('Adding document on Web');
        await _firestoreHelper.addDocument(userId, doc);
      } else {
        // Insert document into local database (this should only be used on mobile/desktop)
        await _dbHelper.insertDocument(userId, doc);

        // Check for internet connectivity and add to Firestore if available
        if (await _isInternetAvailable()) {
          await _firestoreHelper.addDocument(userId, doc);
        }
      }

      // Refresh the documents to reflect the latest state
      final documents = await _dbHelper.getDocuments(userId);
      emit(DocumentLoaded(documents: documents));

      log('Document added successfully');
    } catch (e) {
      log('Error adding document: $e');
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _onUpdateDocument(
      UpdateDocument event, Emitter<DocumentState> emit) async {
    try {
      final doc = event.document;

      if (kIsWeb) {
        log('Updating document on Web');
        await _firestoreHelper.updateDocument(userId, doc);
      } else {
        await _dbHelper.updateDocument(userId, doc);
        if (await _isInternetAvailable()) {
          await _firestoreHelper.updateDocument(userId, doc);
        }
      }

      // Refresh the documents to reflect the latest state
      final documents = await _dbHelper.getDocuments(userId);
      emit(DocumentLoaded(documents: documents));

      log('Document updated successfully');
    } catch (e) {
      log('Error updating document: $e');
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _onDeleteDocument(
      DeleteDocument event, Emitter<DocumentState> emit) async {
    try {
      if (kIsWeb) {
        log('Deleting document on Web');
        await _firestoreHelper.deleteDocument(userId, event.uid);
      } else {
        await _dbHelper.deleteDocument(userId, event.uid);
        if (await _isInternetAvailable()) {
          await _firestoreHelper.deleteDocument(userId, event.uid);
        }
      }

      // Refresh the documents to reflect the latest state
      final documents = await _dbHelper.getDocuments(userId);
      emit(DocumentLoaded(documents: documents));

      log('Document deleted successfully');
    } catch (e) {
      log('Error deleting document: $e');
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<bool> _isInternetAvailable() async {
    return true;
  }

  Future<void> _syncWithFirestoreInBackground() async {
    try {
      if (await _isInternetAvailable()) {
        final firestoreDocs =
            await _firestoreHelper.fetchDocumentsForUser(userId);
        await _syncLocalWithFirestore(firestoreDocs);
      }
    } catch (e) {
      log('Error syncing with Firestore: $e');
    }
  }

  Future<void> _syncLocalWithFirestore(List<DocModel> firestoreDocs) async {
    if (kIsWeb) {
      // Syncing not applicable for web, implement if needed
      return;
    }

    final localDocs = await _dbHelper.getDocuments(userId);

    // Add new documents to local storage
    for (var doc in firestoreDocs) {
      await _dbHelper.insertDocument(userId, doc);
    }

    // Remove documents from local storage that are no longer in Firestore
    for (var doc in localDocs) {
      if (!firestoreDocs.any((d) => d.uid == doc.uid)) {
        await _dbHelper.deleteDocument(userId, doc.uid);
      }
    }

    final updatedDocuments = await _dbHelper.getDocuments(userId);
    emit(DocumentLoaded(documents: updatedDocuments));
  }
}
