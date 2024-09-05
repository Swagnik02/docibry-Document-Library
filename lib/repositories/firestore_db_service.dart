
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docibry/models/document_model.dart';

class FirestoreDbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch documents from Firestore for a specific user
  Future<List<DocModel>> getDocumentFromFirestore(String userUid) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('users').doc(userUid.toString());
      QuerySnapshot querySnapshot = await userDocRef.collection('docs').get();

      return querySnapshot.docs.map((doc) {
        return DocModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (error) {
      print('Failed to fetch documents from Firestore: $error');
      return [];
    }
  }

  // Add a new document to Firestore
  Future<void> addDocumentFromFirestore(String userUid, DocModel doc) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('users').doc(userUid.toString());
      await userDocRef.collection('docs').doc(doc.uid).set(doc.toMap());
    } catch (error) {
      print('Failed to add document to Firestore: $error');
    }
  }

  // Update an existing document in Firestore
  Future<void> updateDocumentFromFirestore(String userUid, DocModel doc) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('users').doc(userUid.toString());
      await userDocRef.collection('docs').doc(doc.uid).update(doc.toMap());
    } catch (error) {
      print('Failed to update document in Firestore: $error');
    }
  }

  // Delete a document from Firestore
  Future<void> deleteDocumentFromFirestore(
      String userUid, String docUid) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('users').doc(userUid.toString());
      await userDocRef.collection('docs').doc(docUid).delete();
    } catch (error) {
      print('Failed to delete document from Firestore: $error');
    }
  }
}
