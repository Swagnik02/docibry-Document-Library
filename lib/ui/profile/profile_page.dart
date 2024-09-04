import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user from FirebaseAuth
    final User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is signed in
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

    // Display user information
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // context.read<AuthBloc>().add(AuthEventLogoutRequested());
            },
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
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              user.email ?? 'No email available',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16.0),
            Text(
              'User UID:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              user.uid,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Username:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              user.displayName ?? 'No username available',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
