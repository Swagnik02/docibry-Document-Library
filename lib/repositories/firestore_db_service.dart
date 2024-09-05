import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/models/document_model.dart';

class FirestoreDbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch documents from Firestore for a specific user
  Future<List<DocModel>> getDocumentFromFirestore(String userUid) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection(DbCollections.users).doc(userUid.toString());
      QuerySnapshot querySnapshot =
          await userDocRef.collection(DbCollections.docs).get();

      return querySnapshot.docs.map((doc) {
        return DocModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (error) {
      log('${ErrorMessages.failedToFetchDoc} Firebase: $error');
      return [];
    }
  }

  // Add a new document to Firestore
  Future<void> addDocumentFromFirestore(String userUid, DocModel doc) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection(DbCollections.users).doc(userUid.toString());
      await userDocRef
          .collection(DbCollections.docs)
          .doc(doc.uid)
          .set(doc.toMap());
    } catch (error) {
      log('${ErrorMessages.failedToAddDoc} Firebase: $error');
    }
  }

  // Update an existing document in Firestore
  Future<void> updateDocumentFromFirestore(String userUid, DocModel doc) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection(DbCollections.users).doc(userUid.toString());
      await userDocRef
          .collection(DbCollections.docs)
          .doc(doc.uid)
          .update(doc.toMap());
    } catch (error) {
      log('${ErrorMessages.failedToUpdateDoc} Firebase: $error');
    }
  }

  // Delete a document from Firestore
  Future<void> deleteDocumentFromFirestore(
      String userUid, String docUid) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection(DbCollections.users).doc(userUid.toString());
      await userDocRef.collection(DbCollections.docs).doc(docUid).delete();
    } catch (error) {
      log('${ErrorMessages.failedToDeleteDoc} Firebase: $error');
    }
  }
}
