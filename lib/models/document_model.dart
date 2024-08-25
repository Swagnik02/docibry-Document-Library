import 'dart:math';

class DocModel {
  final String uid;
  final String docName;
  final String docCategory;
  final String docId;
  final String holdersName;
  final DateTime dateAdded;
  final String docFile;

  DocModel({
    String? uid,
    required this.docName,
    required this.docCategory,
    required this.docId,
    required this.holdersName,
    required this.dateAdded,
    required this.docFile,
  }) : uid = uid ?? generateAutoUid();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'docName': docName,
      'docCategory': docCategory,
      'docId': docId,
      'holdersName': holdersName,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'docFile': docFile,
    };
  }

  factory DocModel.fromMap(Map<String, dynamic> map) {
    return DocModel(
      uid: map['uid'].toString(),
      docName: map['docName'].toString(),
      docCategory: map['docCategory'].toString(),
      docId: map['docId'].toString(),
      holdersName: map['holdersName'].toString(),
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
      docFile: map['docFile'].toString(),
    );
  }

  DocModel copyWith({
    String? uid,
    String? docName,
    String? docCategory,
    String? docId,
    String? holdersName,
    DateTime? dateAdded,
    String? docFile,
  }) {
    return DocModel(
      uid: uid ?? this.uid,
      docName: docName ?? this.docName,
      docCategory: docCategory ?? this.docCategory,
      docId: docId ?? this.docId,
      holdersName: holdersName ?? this.holdersName,
      dateAdded: dateAdded ?? this.dateAdded,
      docFile: docFile ?? this.docFile,
    );
  }

  static String generateAutoUid() {
    final Random random = Random();
    final int length = 20; // Length of the UID

    const int lowerCaseStart = 97; // ASCII code for 'a'
    const int lowerCaseEnd = 122; // ASCII code for 'z'
    const int upperCaseStart = 65; // ASCII code for 'A'
    const int upperCaseEnd = 90; // ASCII code for 'Z'
    const int digitStart = 48; // ASCII code for '0'
    const int digitEnd = 57; // ASCII code for '9'

    final List<int> charCodes = [];

    // Add digits '0-9'
    charCodes.addAll(
        List.generate(digitEnd - digitStart + 1, (i) => digitStart + i));
    // Add uppercase 'A-Z'
    charCodes.addAll(List.generate(
        upperCaseEnd - upperCaseStart + 1, (i) => upperCaseStart + i));
    // Add lowercase 'a-z'
    charCodes.addAll(List.generate(
        lowerCaseEnd - lowerCaseStart + 1, (i) => lowerCaseStart + i));

    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => charCodes[random.nextInt(charCodes.length)],
    ));
  }
}
