import 'package:docibry/constants/string_constants.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  // onboarding page
  final PageController pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserLoggedIn();
    });
    pageController.addListener(() {
      setState(() {
        _currentPage = pageController.page?.round() ?? 0;
      });
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
            .collection(DbCollections.users)
            .doc(userCredential.user!.uid)
            .set({
          'username': _usernameController.text,
          'email': _emailController.text,
        });
      }

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
      body: AnimatedSwitcher(
        switchOutCurve: Curves.easeIn,
        duration: const Duration(milliseconds: 500),
        child: _isOnboarding ? onboardingBody(context) : authBody(context),
      ),
    );
  }

  bool get _isOnboarding => _currentPage < 4;

  Stack onboardingBody(BuildContext context) {
    return Stack(
      key: const ValueKey('onboarding'),
      alignment: Alignment.center,
      children: [
        PageView(
          controller: pageController,
          onPageChanged: (value) {
            setState(() {
              _currentPage = value;
            });
          },
          children: [
            _page(
              context: context,
              pageIndex: 0,
              imageUrl: 'assets/logo.png',
              title: AppStrings.appFullName,
              desc: '',
            ),
            _page(
              context: context,
              pageIndex: 1,
              imageUrl: 'assets/manage.png',
              title: 'Manage Documents Easily',
              desc:
                  'Upload, categorize, and manage your documents from anywhere, anytime with seamless access.',
            ),
            _page(
              context: context,
              pageIndex: 2,
              imageUrl: 'assets/share.png',
              title: 'Share Files Effortlessly',
              desc:
                  'Share documents instantly with a tap, download them in JPG or PDF, or save them offline.',
            ),
            _page(
              context: context,
              pageIndex: 3,
              imageUrl: 'assets/web.png',
              title: 'Cross-Platform Access',
              desc:
                  'Access your files anytime from the docibry web-app \n https://docibry.vercel.app',
            ),
          ],
        ),
        Positioned(
          bottom: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _currentPage == index ? 30 : 8,
                height: 8,
                margin: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget authBody(BuildContext context) {
    return Scaffold(
      key: const ValueKey('authbody'),
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
        leading: IconButton(
            onPressed: () {
              setState(() {
                _currentPage = 0;
              });
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
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

  Widget _page({
    required int pageIndex,
    required String imageUrl,
    required String title,
    required String desc,
    required BuildContext context,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Image.asset(
          imageUrl,
          height: 250,
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            desc,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: pageIndex == 3
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: pageIndex != 3,
                child: OutlinedButton(
                  onPressed: () => _toAuth(),
                  child: const Text(
                    'Skip',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              pageIndex == 3
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        _toAuth();
                      },
                      child: const Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : FilledButton(
                      onPressed: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.decelerate,
                        );
                      },
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _toAuth() {
    return setState(() {
      _currentPage = 4;
    });
  }
}
