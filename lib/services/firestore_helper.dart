import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docibry/models/document_model.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch documents from Firestore for a specific user
  Future<List<DocModel>> fetchDocumentsForUser(String userId) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);
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
  Future<void> addDocument(String userId, DocModel doc) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);
      await userDocRef.collection('docs').doc(doc.uid).set(doc.toMap());
    } catch (error) {
      print('Failed to add document to Firestore: $error');
    }
  }

  // Update an existing document in Firestore
  Future<void> updateDocument(String userId, DocModel doc) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);
      await userDocRef.collection('docs').doc(doc.uid).update(doc.toMap());
    } catch (error) {
      print('Failed to update document in Firestore: $error');
    }
  }

  // Delete a document from Firestore
  Future<void> deleteDocument(String userId, String uid) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);
      await userDocRef.collection('docs').doc(uid).delete();
    } catch (error) {
      print('Failed to delete document from Firestore: $error');
    }
  }

  // user Management

  Future<void> printAllUserEmails() async {
    try {
      final QuerySnapshot result = await _firestore.collection('users').get();

      log('Number of documents retrieved: ${result.docs.length}');

      for (var doc in result.docs) {
        final email = doc.id;
        log('User Email: $email');
      }
    } catch (error) {
      log('Error retrieving user emails: $error');
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final DocumentReference documentRef =
          _firestore.collection('users').doc(email);
      final DocumentSnapshot documentSnapshot = await documentRef.get();
      return documentSnapshot.exists;
    } catch (error) {
      log('Error checking email existence: $error');
      return false;
    }
  }

  Future<bool> checkUsernameExists(String email, String username) async {
    try {
      final DocumentReference documentRef =
          _firestore.collection('users').doc(email);

      final DocumentSnapshot documentSnapshot = await documentRef.get();

      final data = documentSnapshot.data() as Map<String, dynamic>;
      final storedUsername = data['username'] as String?;

      final exists = storedUsername == username;

      return exists;
    } catch (error) {
      log('Error checking username existence: $error');
      return false;
    }
  }

  Future<void> databaseLogin(String email, String username) async {
    final bool doesMatch = await checkUsernameExists(email, username);

    if (doesMatch) {
      log('Login successful');
    } else {
      log('Login failed');
    }
  }

  Future<void> databaseRegister(String email, String username) async {
    try {
      final DocumentReference documentRef =
          _firestore.collection('users').doc(email);

      final userData = {
        'username': username,
      };

      await documentRef.set(userData);

      log('User registered successfully with email: $email');
    } catch (error) {
      log('Error during user registration: $error');
      throw Exception('Failed to register user: $error');
    }
  }
}
