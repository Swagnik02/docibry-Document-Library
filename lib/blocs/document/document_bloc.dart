import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/services/database_helper.dart';
import 'package:docibry/services/firestore_helper.dart';
import 'package:docibry/services/user_data_service.dart';
import 'package:flutter/foundation.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final LocalDbService _dbHelper = LocalDbService();
  final FirestoreDbService _FirestoreDbService = FirestoreDbService();
  final UserDataService _userDataService = UserDataService();
  String? _userEmail;

  DocumentBloc() : super(DocumentInitial()) {
    _initializeUserEmail();

    on<GetDocument>(_handleGetDocument);
    on<AddDocument>(_handleAddDocument);
    on<UpdateDocument>(_handleUpdateDocument);
    on<DeleteDocument>(_handleDeleteDocument);
  }

  Future<void> _initializeUserEmail() async {
    try {
      _userEmail = await _userDataService.getUserEmail();
      if (_userEmail == null) {
        emit(DocumentError(error: 'No user email available.'));
      }
    } catch (e) {
      emit(DocumentError(
          error: 'Error initializing user email: ${e.toString()}'));
    }
  }

  Future<void> _handleGetDocument(
      GetDocument event, Emitter<DocumentState> emit) async {
    if (_userEmail == null) {
      emit(DocumentError(error: 'No user email provided.'));
      return;
    }

    emit(DocumentLoading());

    try {
      if (kIsWeb) {
        final documents =
            await _FirestoreDbService.getDocumentFromFirestore(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      } else {
        final documents = await _dbHelper.getDocuments(_userEmail!);
        emit(DocumentLoaded(documents: documents));
        _syncWithFirestoreInBackground();
      }
    } catch (e) {
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _handleAddDocument(
      AddDocument event, Emitter<DocumentState> emit) async {
    if (_userEmail == null) {
      emit(DocumentError(error: 'No user email provided.'));
      return;
    }

    final doc = DocModel(
      docName: event.docName,
      docCategory: event.docCategory,
      docId: event.docId.isNotEmpty ? event.docId : ' ',
      holdersName: event.holdersName.isNotEmpty ? event.holdersName : ' ',
      dateAdded: DateTime.now(),
      docFile: event.filePath,
    );

    try {
      if (kIsWeb) {
        await _FirestoreDbService.addDocumentFromFirestore(_userEmail!, doc);
        final documents =
            await _FirestoreDbService.getDocumentFromFirestore(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      } else {
        await _dbHelper.insertDocument(_userEmail!, doc);
        if (await _isInternetAvailable()) {
          await _FirestoreDbService.addDocumentFromFirestore(_userEmail!, doc);
        }
        final documents = await _dbHelper.getDocuments(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      }
    } catch (e) {
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _handleUpdateDocument(
      UpdateDocument event, Emitter<DocumentState> emit) async {
    if (_userEmail == null) {
      emit(DocumentError(error: 'No user email provided.'));
      return;
    }

    try {
      if (kIsWeb) {
        await _FirestoreDbService.updateDocumentFromFirestore(
            _userEmail!, event.document);
        final documents =
            await _FirestoreDbService.getDocumentFromFirestore(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      } else {
        await _dbHelper.updateDocument(_userEmail!, event.document);
        if (await _isInternetAvailable()) {
          await _FirestoreDbService.updateDocumentFromFirestore(
              _userEmail!, event.document);
        }
        final documents = await _dbHelper.getDocuments(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      }
    } catch (e) {
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _handleDeleteDocument(
      DeleteDocument event, Emitter<DocumentState> emit) async {
    if (_userEmail == null) {
      emit(DocumentError(error: 'No user email provided.'));
      return;
    }

    try {
      if (kIsWeb) {
        await _FirestoreDbService.deleteDocumentFromFirestore(
            _userEmail!, event.uid);
        final documents =
            await _FirestoreDbService.getDocumentFromFirestore(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      } else {
        await _dbHelper.deleteDocument(_userEmail!, event.uid);
        if (await _isInternetAvailable()) {
          await _FirestoreDbService.deleteDocumentFromFirestore(
              _userEmail!, event.uid);
        }
        final documents = await _dbHelper.getDocuments(_userEmail!);
        emit(DocumentLoaded(documents: documents));
      }
    } catch (e) {
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
            await _FirestoreDbService.getDocumentFromFirestore(_userEmail!);
        await _syncLocalWithFirestore(firestoreDocs);
      }
    } catch (e) {
      log('Error syncing with Firestore: $e');
    }
  }

  Future<void> _syncLocalWithFirestore(List<DocModel> firestoreDocs) async {
    if (kIsWeb) return; // Syncing not applicable for web, implement if needed

    final localDocs = await _dbHelper.getDocuments(_userEmail!);

    // Add new documents to local storage
    final newDocs = firestoreDocs
        .where((doc) => !localDocs.any((local) => local.uid == doc.uid));
    for (var doc in newDocs) {
      await _dbHelper.insertDocument(_userEmail!, doc);
    }

    // Remove documents from local storage that are no longer in Firestore
    final removedDocs = localDocs.where((doc) =>
        !firestoreDocs.any((firestoreDoc) => firestoreDoc.uid == doc.uid));
    for (var doc in removedDocs) {
      await _dbHelper.deleteDocument(_userEmail!, doc.uid);
    }

    final updatedDocuments = await _dbHelper.getDocuments(_userEmail!);
    emit(DocumentLoaded(documents: updatedDocuments));
  }
}
