import 'package:docibry/constants/string_constants.dart';

class DocModel {
  final String uid;
  final String docName;
  final String docCategory;
  final String docId;
  final String holdersName;
  final DateTime dateAdded;
  final String docFile;

  DocModel({
    required this.uid,
    required this.docName,
    required this.docCategory,
    required this.docId,
    required this.holdersName,
    required this.dateAdded,
    required this.docFile,
  });

  factory DocModel.fromMap(Map<String, dynamic> map) {
    return DocModel(
      uid: map['uid'] ?? '',
      docName: map['docName'] ?? '',
      docCategory: map['docCategory'] ?? '',
      docId: map['docId'] ?? '',
      holdersName: map['holdersName'] ?? '',
      dateAdded: DateTime.parse(map['dateAdded'] ?? DateTime.now().toString()),
      docFile: map['docFile'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'docName': docName,
      'docCategory': docCategory,
      'docId': docId,
      'holdersName': holdersName,
      'dateAdded': dateAdded.toIso8601String(),
      'docFile': docFile,
    };
  }
}

// Sample documents for testing
DocModel doc1 = DocModel(
  uid: '001',
  docName: 'Aadhaar',
  docCategory: StringDocCategory.identity,
  docId: '123456',
  holdersName: 'Swagnik',
  dateAdded: DateTime(2024, 1, 15),
  docFile: 'docFile',
);

DocModel doc2 = DocModel(
  uid: '002',
  docName: 'Marksheet',
  docCategory: StringDocCategory.education,
  docId: '12',
  holdersName: 'Swagnik',
  dateAdded: DateTime(2023, 12, 22),
  docFile: 'docFile',
);

DocModel doc3 = DocModel(
  uid: '003',
  docName: 'Health Card',
  docCategory: StringDocCategory.health,
  docId: '12',
  holdersName: 'Swagnik',
  dateAdded: DateTime(2024, 2, 5),
  docFile: 'docFile',
);
