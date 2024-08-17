import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/services/database_helper.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  DocumentBloc() : super(DocumentInitial()) {
    on<FetchDocuments>(_onFetchDocuments);
    on<AddDocument>(_onAddDocument);
  }

  Future<void> _onFetchDocuments(
      FetchDocuments event, Emitter<DocumentState> emit) async {
    try {
      emit(DocumentLoading());
      final List<DocModel> documents = await _dbHelper.getDocuments();
      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      log('Error fetching documents: $e');
      emit(DocumentError(error: e.toString()));
    }
  }

  Future<void> _onAddDocument(
      AddDocument event, Emitter<DocumentState> emit) async {
    try {
      if (state is DocumentLoaded) {
        final doc = DocModel(
          uid: DateTime.now().millisecondsSinceEpoch,
          docName: event.docName,
          docCategory: event.docCategory,
          docId: event.docId,
          holdersName: event.holdersName,
          dateAdded: DateTime.now(),
          docFile: event.filePath,
        );

        await _dbHelper.insertDocument(doc);

        final documents = await _dbHelper.getDocuments();
        emit(DocumentLoaded(documents: documents));

        log('Document added successfully');
      } else {
        log('Document state is not loaded');
      }
    } catch (e) {
      log('Error adding document: $e');
      emit(DocumentError(error: e.toString()));
    }
  }

  // Add other event handlers (e.g., UpdateDocument, DeleteDocument) as needed
}
