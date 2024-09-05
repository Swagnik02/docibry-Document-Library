import 'package:docibry/repositories/local_db_service.dart';
import 'package:docibry/ui/home/home_page.dart';
import 'package:docibry/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController =
      TextEditingController(text: 'swagnik1234@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password02');
  final TextEditingController _usernameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserLoggedIn();
    });
  }

  Future<void> _checkUserLoggedIn() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential;
      if (_isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _usernameController.text,
          'email': _emailController.text,
        });
      }

      // Initialize local database service and save user details
      if (!kIsWeb) {
        final localDbService = LocalDbService();
        await localDbService.initLocalDb();
        await localDbService.saveLoggedInUser(
          UserModel(
            userEmail: _emailController.text,
            userId: userCredential.user!.uid,
            username: _usernameController.text,
          ),
        );
      }

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              if (!_isLogin)
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _authenticate,
                      child: Text(_isLogin ? 'Login' : 'Register'),
                    ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin
                    ? 'Create an account'
                    : 'Already have an account?'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
