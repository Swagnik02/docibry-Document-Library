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

  const AddDocument({required this.docName, required this.docCategory});

  @override
  List<Object?> get props => [docName, docCategory];
}
