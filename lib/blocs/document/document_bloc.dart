import 'package:bloc/bloc.dart';
import 'package:docibry/models/document_model.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  DocumentBloc() : super(DocumentInitial()) {
    on<FetchDocuments>(_onFetchDocuments);
    on<AddDocument>(_onAddDocument);
  }

  void _onFetchDocuments(
      FetchDocuments event, Emitter<DocumentState> emit) async {
    try {
      emit(DocumentLoading());
      final documents = [doc1, doc2, doc3]; // Mock data
      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      emit(DocumentError(error: e.toString()));
    }
  }

  void _onAddDocument(AddDocument event, Emitter<DocumentState> emit) {
    if (state is DocumentLoaded) {
      final updatedDocs =
          List<DocModel>.from((state as DocumentLoaded).documents)
            ..add(DocModel(
              uid: '004', // Generate UID
              docName: event.docName,
              docCategory: event.docCategory,
              docId: 'new_id', // Generate new ID
              holdersName: 'Swagnik',
              dateAdded: DateTime.now(),
              docFile: 'docFile',
            ));
      emit(DocumentLoaded(documents: updatedDocs));
    }
  }
}
