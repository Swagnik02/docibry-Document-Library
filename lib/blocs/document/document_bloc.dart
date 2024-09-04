import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/repositories/database_service.dart';
import 'package:docibry/services/user_data_service.dart';

import 'package:flutter/foundation.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DatabaseService _databaseService = DatabaseService();
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
      } else {
        await _databaseService.init();
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
      final documents = await _databaseService.getDocuments(_userEmail!);
      emit(DocumentLoaded(documents: documents));

      if (!kIsWeb) {
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
      await _databaseService.addDocument(_userEmail!, doc);
      final documents = await _databaseService.getDocuments(_userEmail!);
      emit(DocumentLoaded(documents: documents));
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
      await _databaseService.updateDocument(_userEmail!, event.document);
      final documents = await _databaseService.getDocuments(_userEmail!);
      emit(DocumentLoaded(documents: documents));
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
      await _databaseService.deleteDocument(_userEmail!, event.uid);
      final documents = await _databaseService.getDocuments(_userEmail!);
      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _syncWithFirestoreInBackground() async {
    try {
      if (_userEmail != null) {
        await _databaseService.syncLocalWithFirestore(_userEmail!);
      }
    } catch (e) {
      log('Error syncing with Firestore: $e');
    }
  }
}
