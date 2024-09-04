import 'package:docibry/repositories/local_db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize the username controller with the current user's display name
    _usernameController.text = _auth.currentUser?.displayName ?? '';
  }

  Future<void> _updateProfile() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updateProfile(displayName: _usernameController.text);
        await user.reload(); // Reload user data
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        // Handle update error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      LocalDbService().logout();
      Navigator.of(context).pushReplacementNamed('/auth/');
    } catch (e) {
      // Handle logout error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('No user is currently signed in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'User Email:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              user.email ?? 'No email available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'User UID:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              user.uid,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Username:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _isEditing
                ? TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _updateProfile(),
                  )
                : Text(
                    user.displayName ?? 'No username available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
            const SizedBox(height: 16.0),
            if (!_isEditing)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: const Text('Edit Username'),
              )
            else
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save Changes'),
              ),
          ],
        ),
      ),
    );
  }
}
