import 'package:firebase_auth/firebase_auth.dart';
import 'package:docibry/repositories/local_db_service.dart';

class UserDataService {
  final LocalDbService _dbHelper = LocalDbService();

  Future<String?> getUserEmail() async {
    try {
      // Attempt to get the email from FirebaseAuth
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.email;
      } else {
        throw Exception('No user logged in via Firebase');
      }
    } catch (firebaseError) {
      // If an error occurs, fallback to retrieving from the offline database
      try {
        final offlineUser = await _dbHelper.getLoggedInUser();
        return offlineUser?.userEmail;
      } catch (dbError) {
        // Handle potential errors with the offline database as well
        return null;
      }
    }
  }
}
