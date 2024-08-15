// class DocModel {
//   final String uid;
//   final String docName;
//   final String docCategory;
//   final String docId;
//   final String holdersName;
//   final DateTime dateAdded;
//   final String docFile;

//   DocModel({
//     required this.uid,
//     required this.docName,
//     required this.docCategory,
//     required this.docId,
//     required this.holdersName,
//     required this.dateAdded,
//     required this.docFile,
//   });

//   // Example of a factory method to create a DocModel from a map (useful for deserialization)
//   factory DocModel.fromMap(Map<String, dynamic> map) {
//     return DocModel(
//       uid: map['uid'] ?? '',
//       docName: map['docName'] ?? '',
//       docCategory: map['docCategory'] ?? '',
//       docId: map['docId'] ?? '',
//       holdersName: map['holdersName'] ?? '',
//       dateAdded: DateTime.parse(map['dateAdded'] ?? DateTime.now().toString()),
//       docFile: map['docFile'] ?? '',
//     );
//   }

//   // Method to convert DocModel to a map (useful for serialization)
//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'docName': docName,
//       'docCategory': docCategory,
//       'docId': docId,
//       'holdersName': holdersName,
//       'dateAdded': dateAdded.toIso8601String(),
//       'docFile': docFile,
//     };
//   }
// }
