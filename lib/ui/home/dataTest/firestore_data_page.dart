// import 'package:docibry/models/document_model.dart';
// import 'package:docibry/models/user_model.dart';

// import 'package:docibry/services/firestore_helper.dart';
// import 'package:docibry/ui/home/doc_card.dart';
// import 'package:flutter/material.dart';
// import 'package:docibry/constants/string_constants.dart';

// class FirestoreDataPage extends StatefulWidget {
//   const FirestoreDataPage({super.key});

//   @override
//   _FirestoreDataPageState createState() => _FirestoreDataPageState();
// }

// class _FirestoreDataPageState extends State<FirestoreDataPage> {
//   List<DocModel> documents = [];
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDocuments();
//   }

//   void _fetchDocuments() async {
//     try {
//       documents = await FirestoreDbService.getDocument(loggedInUserId);
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = e.toString();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Firestore Data',
//           style: Theme.of(context).textTheme.headlineLarge,
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : errorMessage != null
//               ? Center(child: Text('Error: $errorMessage'))
//               : _docs(documents),
//     );
//   }

//   Expanded _docs(List<DocModel> filteredDocs) {
//     return Expanded(
//       child: filteredDocs.isEmpty
//           ? const Center(
//               child: Text(StringConstants.stringNoDataFound),
//             )
//           : ListView.builder(
//               itemCount: filteredDocs.length,
//               itemBuilder: (context, index) {
//                 return DocCard(docModel: filteredDocs[index]);
//               },
//             ),
//     );
//   }
// }
