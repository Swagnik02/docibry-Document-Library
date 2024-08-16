import 'package:equatable/equatable.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class FetchDocuments extends DocumentEvent {}

class AddDocument extends DocumentEvent {
  final String docName;
  final String docCategory;
  final String docId;
  final String holdersName;

  const AddDocument({
    required this.docName,
    required this.docCategory,
    required this.docId,
    required this.holdersName,
  });

  @override
  List<Object?> get props => [docName, docCategory, docId, holdersName];
}
