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
      // Fetch documents from a data source (e.g., API, database)
      final List<DocModel> documents = []; // Explicitly define the type
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
              uid: 'new_uid', // Generate a new UID
              docName: event.docName,
              docCategory: event.docCategory,
              docId: event.docId,
              holdersName: event.holdersName,
              dateAdded: DateTime.now(),
              docFile: 'path_to_file', // Update with the actual file path
            ));
      emit(DocumentLoaded(documents: updatedDocs));
    }
  }
}
