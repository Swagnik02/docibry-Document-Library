import 'package:docibry/models/document_model.dart';
import 'package:equatable/equatable.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class GetDocument extends DocumentEvent {}

class AddDocument extends DocumentEvent {
  final String docName;
  final String docCategory;
  final String docId;
  final String holdersName;
  final String filePath;

  const AddDocument({
    required this.docName,
    required this.docCategory,
    required this.docId,
    required this.holdersName,
    required this.filePath,
  });

  @override
  List<Object?> get props =>
      [docName, docCategory, docId, holdersName, filePath];
}

class UpdateDocument extends DocumentEvent {
  final DocModel document;

  const UpdateDocument({required this.document});

  @override
  List<Object?> get props => [document];
}

class DeleteDocument extends DocumentEvent {
  final String uid;

  const DeleteDocument({required this.uid});

  @override
  List<Object?> get props => [uid];
}
