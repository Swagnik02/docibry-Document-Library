import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  // Fetch documents from Firestore for a specific user
  Future<List<DocModel>> fetchDocumentsForUser(String userEmail) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('users').doc(userEmail.toString());
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
  Future<void> addDocument(String userEmail, DocModel doc) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('users').doc(userEmail.toString());
      await userDocRef.collection('docs').doc(doc.uid).set(doc.toMap());
    } catch (error) {
      print('Failed to add document to Firestore: $error');
    }
  }

  // Update an existing document in Firestore
  Future<void> updateDocument(String userEmail, DocModel doc) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('users').doc(userEmail.toString());
      await userDocRef.collection('docs').doc(doc.uid).update(doc.toMap());
    } catch (error) {
      print('Failed to update document in Firestore: $error');
    }
  }

  // Delete a document from Firestore
  Future<void> deleteDocument(String userEmail, String uid) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('users').doc(userEmail.toString());
      await userDocRef.collection('docs').doc(uid).delete();
    } catch (error) {
      print('Failed to delete document from Firestore: $error');
    }
  }
}
