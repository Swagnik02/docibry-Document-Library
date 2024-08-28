import 'package:docibry/services/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docibry/blocs/auth/auth_bloc.dart' as auth_bloc;
import 'package:docibry/blocs/auth/auth_events.dart' as auth_events;
import 'package:docibry/blocs/auth/auth_states.dart' as auth_states;
import 'package:docibry/constants/routes.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  final ValueNotifier<bool> _emailChecked = ValueNotifier(false);
  final ValueNotifier<bool> _emailExists = ValueNotifier(false);
  bool _checkingEmail = false;

  Future<void> _checkEmail() async {
    setState(() {
      _checkingEmail = true;
    });

    try {
      bool emailExists =
          await FirestoreHelper().checkEmailExists(_emailController.text);

      _emailExists.value = emailExists;
      _emailChecked.value = true;

      // Show SnackBar based on email existence
      final message = emailExists
          ? 'User exists. You can log in.'
          : 'User does not exist. Please register.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Show SnackBar in case of an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check email: $e')),
      );
    } finally {
      setState(() {
        _checkingEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login/Register')),
      body: BlocListener<auth_bloc.AuthBloc, auth_states.AuthState>(
        listener: (context, state) {
          if (state is auth_states.AuthLoggedIn) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(homeRoute, (route) => false);
          } else if (state is auth_states.AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _emailExists,
                builder: (context, emailExists, child) {
                  return TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    readOnly: emailExists,
                  );
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _checkingEmail ? null : _checkEmail,
                child: _checkingEmail
                    ? const CircularProgressIndicator()
                    : const Text('Check Email'),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: _emailChecked,
                builder: (context, emailChecked, child) {
                  if (!emailChecked) return const SizedBox.shrink();

                  return Column(
                    children: [
                      TextField(
                        controller: _userNameController,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: _emailExists,
                        builder: (context, emailExists, child) {
                          return ElevatedButton(
                            onPressed: () {
                              if (emailExists) {
                                context.read<auth_bloc.AuthBloc>().add(
                                      auth_events.AuthLoginRequested(
                                        email: _emailController.text,
                                        username: _userNameController.text,
                                      ),
                                    );
                              } else {
                                context.read<auth_bloc.AuthBloc>().add(
                                      auth_events.AuthRegisterRequested(
                                        email: _emailController.text,
                                        username: _userNameController.text,
                                      ),
                                    );
                              }
                            },
                            child: Text(emailExists ? 'Login' : 'Register'),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
