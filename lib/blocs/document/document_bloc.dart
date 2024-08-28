import 'dart:developer';
import 'package:bloc/bloc.dart';

import 'package:docibry/models/document_model.dart';
import 'package:docibry/services/database_helper.dart';
import 'package:docibry/services/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  String? _userEmail;

  DocumentBloc() : super(DocumentInitial()) {
    // Initialize _userEmail from FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    _userEmail = user?.email;

    on<FetchDocuments>(_onFetchDocuments);
    on<AddDocument>(_onAddDocument);
    on<UpdateDocument>(_onUpdateDocument);
    on<DeleteDocument>(_onDeleteDocument);
    // on<UserLoggedIn>(_onUserLoggedIn);
  }

  Future<void> _onFetchDocuments(
      FetchDocuments event, Emitter<DocumentState> emit) async {
    if (_userEmail == null) {
      emit(DocumentError(error: 'No user email provided.'));
      return;
    }

    try {
      emit(DocumentLoading());

      if (kIsWeb) {
        log('Fetching documents on Web');
        final documents =
            await _firestoreHelper.fetchDocumentsForUser(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      } else {
        // Load local documents first
        final documents = await _dbHelper.getDocuments(_userEmail!);
        emit(DocumentLoaded(documents: documents));

        // Start background sync with Firestore
        _syncWithFirestoreInBackground();
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
        await _firestoreHelper.addDocument(_userEmail!, doc);
        final documents =
            await _firestoreHelper.fetchDocumentsForUser(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      } else {
        // Insert document into local database
        await _dbHelper.insertDocument(_userEmail!, doc);

        // Check for internet connectivity and add to Firestore if available
        if (await _isInternetAvailable()) {
          await _firestoreHelper.addDocument(_userEmail!, doc);
        }
        final documents = await _dbHelper.getDocuments(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      }

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
        await _firestoreHelper.updateDocument(_userEmail!, doc);
        final documents =
            await _firestoreHelper.fetchDocumentsForUser(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      } else {
        await _dbHelper.updateDocument(_userEmail!, doc);
        if (await _isInternetAvailable()) {
          await _firestoreHelper.updateDocument(_userEmail!, doc);
        }
        final documents = await _dbHelper.getDocuments(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      }

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
        await _firestoreHelper.deleteDocument(_userEmail!, event.uid);
        final documents =
            await _firestoreHelper.fetchDocumentsForUser(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      } else {
        await _dbHelper.deleteDocument(_userEmail!, event.uid);
        if (await _isInternetAvailable()) {
          await _firestoreHelper.deleteDocument(_userEmail!, event.uid);
        }
        final documents = await _dbHelper.getDocuments(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      }

      log('Document deleted successfully');
    } catch (e) {
      log('Error deleting document: $e');
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<bool> _isInternetAvailable() async {
    // Implement your internet connectivity check here
    return true;
  }

  Future<void> _syncWithFirestoreInBackground() async {
    try {
      if (await _isInternetAvailable()) {
        final firestoreDocs =
            await _firestoreHelper.fetchDocumentsForUser(_userEmail!);
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

    final localDocs = await _dbHelper.getDocuments(_userEmail!);

    // Add new documents to local storage
    for (var doc in firestoreDocs) {
      await _dbHelper.insertDocument(_userEmail!, doc);
    }

    // Remove documents from local storage that are no longer in Firestore
    for (var doc in localDocs) {
      if (!firestoreDocs.any((d) => d.uid == doc.uid)) {
        await _dbHelper.deleteDocument(_userEmail!, doc.uid);
      }
    }

    final updatedDocuments = await _dbHelper.getDocuments(_userEmail!);
    emit(DocumentLoaded(documents: updatedDocuments));
  }
}
