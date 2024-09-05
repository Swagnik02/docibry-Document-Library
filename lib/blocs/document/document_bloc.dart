import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/repositories/database_service.dart';
import 'package:docibry/services/user_data_service.dart';
import 'package:flutter/foundation.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DatabaseService _databaseService = DatabaseService();
  final UserDataService _userDataService = UserDataService();
  String? _userUid;

  DocumentBloc() : super(DocumentInitial()) {
    _initializeUserUid();

    on<GetDocument>(_onGetDocument);
    on<AddDocument>(_onAddDocument);
    on<UpdateDocument>(_onUpdateDocument);
    on<DeleteDocument>(_onDeleteDocument);
  }

  Future<void> _initializeUserUid() async {
    try {
      _userUid = await _userDataService.getUserUid();

      log(_userUid.toString());
      if (_userUid == null) {
        emit(const DocumentError(error: 'No user email available.'));
      } else {
        await _databaseService.init();
      }
    } catch (e) {
      emit(DocumentError(
          error: 'Error initializing user email: ${e.toString()}'));
    }
  }

  Future<void> _onGetDocument(
      GetDocument event, Emitter<DocumentState> emit) async {
    if (_userUid == null) {
      emit(const DocumentError(error: 'No user uid provided.'));
      return;
    }

    emit(DocumentLoading());

    try {
      if (!kIsWeb) {
        await _syncWithFirestoreInBackground();
      }
      final documents = await _databaseService.getDocuments(_userUid!);

      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _onAddDocument(
      AddDocument event, Emitter<DocumentState> emit) async {
    if (_userUid == null) {
      emit(const DocumentError(error: 'No user email provided.'));
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
      await _databaseService.addDocument(_userUid!, doc);
      final documents = await _databaseService.getDocuments(_userUid!);
      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _onUpdateDocument(
      UpdateDocument event, Emitter<DocumentState> emit) async {
    if (_userUid == null) {
      emit(const DocumentError(error: 'No user email provided.'));
      return;
    }

    try {
      await _databaseService.updateDocument(_userUid!, event.document);
      final documents = await _databaseService.getDocuments(_userUid!);
      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _onDeleteDocument(
      DeleteDocument event, Emitter<DocumentState> emit) async {
    if (_userUid == null) {
      emit(const DocumentError(error: 'No user email provided.'));
      return;
    }

    try {
      await _databaseService.deleteDocument(_userUid!, event.uid);
      final documents = await _databaseService.getDocuments(_userUid!);
      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _syncWithFirestoreInBackground() async {
    try {
      if (_userUid != null) {
        await _databaseService.syncLocalWithFirestore(_userUid!);
      }
    } catch (e) {
      log('Error syncing with Firestore: $e');
    }
  }
}
