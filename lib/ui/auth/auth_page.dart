import 'dart:developer';

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
    final window = MediaQuery.of(context).size;
    final bool isLargeWebScreen = kIsWeb && window.width > 540;

    return Scaffold(
      body: isLargeWebScreen ? webBodyWidget(window) : _bodyBasedOnMode(),
    );
  }

  Widget _bodyBasedOnMode() {
    return AnimatedSwitcher(
      switchOutCurve: Curves.easeIn,
      duration: const Duration(milliseconds: 500),
      child: _isOnboarding
          ? smallScreenOnboardingBody(context)
          : smallScreenAuthBody(),
    );
  }

  bool get _isOnboarding => _currentPage < 4;

  Widget webBodyWidget(Size window) {
    final bool isWide = window.width > 1050;
    final double formWidth = window.width < 622 ? 320 : 420;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (isWide)
            Expanded(
              child: window.width < 1260
                  ? GridView.count(
                      crossAxisCount: 2,
                      children: infoPages,
                    )
                  : Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: infoPages,
                      ),
                    ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: infoPages,
            ),
          SizedBox(
            width: formWidth,
            child: Card(child: _mainWebAuthBody()),
          ),
        ],
      ),
    );
  }

  List<Widget> get infoPages => [
        _pageForWeb(
          imageUrl: 'assets/manage.png',
          title: 'Manage Documents Easily',
        ),
        _pageForWeb(
          imageUrl: 'assets/share.png',
          title: 'Share Files Effortlessly',
        ),
        _pageForWeb(
          imageUrl: 'assets/web.png',
          title: 'Cross-Platform Access',
        ),
      ];

  Widget _pageForWeb({
    required String imageUrl,
    required String title,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenWidth > 1440
        ? 250
        : screenWidth > 1260
            ? 150
            : screenWidth > 1050
                ? 100
                : 90;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Image.asset(imageUrl, height: imageHeight),
        const SizedBox(height: 20),
        Text(
          title,
          style: screenWidth < 750
              ? Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).colorScheme.primary)
              : Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _mainWebAuthBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _authLogoSection(),
          _authFields(),
          _authActionButtons(),
        ],
      ),
    );
  }

  Widget _authLogoSection() {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: 20),
          Image.asset('assets/logo.png', height: 150),
          const SizedBox(height: 20),
          Text(
            AppStrings.appFullName,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _authFields() {
    return Column(
      children: [
        !_isLogin
            ? _buildTextField(
                controller: _usernameController, labelText: 'Username')
            : Container(),
        _buildTextField(controller: _emailController, labelText: 'Email'),
        _buildTextField(
          controller: _passwordController,
          labelText: 'Password',
          isObscure: true,
        ),
      ],
    );
  }

  Widget _authActionButtons() {
    return kIsWeb
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _toggleAuthModeButton(),
              _isLoading ? const CircularProgressIndicator() : _authButton(),
            ],
          )
        : Column(
            children: [
              _isLoading ? const CircularProgressIndicator() : _authButton(),
              _toggleAuthModeButton(),
            ],
          );
  }

  Widget smallScreenAuthBody() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
        leading: IconButton(
          onPressed: () => _navigateToOnboarding(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _authFields(),
              const SizedBox(height: 20),
              _authActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      obscureText: isObscure,
    );
  }

  ElevatedButton _authButton() {
    return ElevatedButton(
      onPressed: _authenticate,
      child: Text(_isLogin ? 'Login' : 'Register'),
    );
  }

  TextButton _toggleAuthModeButton() {
    return TextButton(
      onPressed: () => setState(() {
        _isLogin = !_isLogin;
      }),
      child: Text(_isLogin ? 'Create an account' : 'Already have an account?'),
    );
  }

  List<Widget> get onboardPages => [
        _onboardPage(
          pageIndex: 0,
          imageUrl: 'assets/logo.png',
          title: AppStrings.appFullName,
          desc: '',
        ),
        _onboardPage(
          pageIndex: 1,
          imageUrl: 'assets/manage.png',
          title: 'Manage Documents Easily',
          desc: 'Upload, categorize, and manage your documents from anywhere.',
        ),
        _onboardPage(
          pageIndex: 2,
          imageUrl: 'assets/share.png',
          title: 'Share Files Effortlessly',
          desc:
              'Share documents instantly with a tap, download or save offline.',
        ),
        _onboardPage(
          pageIndex: 3,
          imageUrl: 'assets/web.png',
          title: 'Cross-Platform Access',
          desc:
              'Access files anytime via the docibry web-app: https://docibry.vercel.app',
        ),
      ];

  Stack smallScreenOnboardingBody(BuildContext context) {
    return Stack(
      key: const ValueKey('onboarding'),
      alignment: Alignment.center,
      children: [
        PageView(
          controller: pageController,
          onPageChanged: (value) => setState(() {
            _currentPage = value;
          }),
          children: onboardPages,
        ),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
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
    );
  }

  Widget _onboardPage({
    required int pageIndex,
    required String imageUrl,
    required String title,
    required String desc,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Image.asset(imageUrl, height: 250),
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
          child: _buildPageNavigationButtons(pageIndex),
        ),
      ],
    );
  }

  Widget _buildPageNavigationButtons(int pageIndex) {
    bool isLastPage = pageIndex == 3;
    return Row(
      mainAxisAlignment: kIsWeb
          ? MainAxisAlignment.spaceBetween
          : isLastPage
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
      children: [
        if (kIsWeb && pageIndex > 0)
          _buildNavigationButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () => pageController.previousPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.decelerate,
            ),
          ),
        if (!isLastPage) _buildSkipButton(),
        if (isLastPage)
          _buildGetStartedButton()
        else
          _buildNavigationButton(
            icon: Icons.arrow_forward_ios_rounded,
            onPressed: () => pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.decelerate,
            ),
          ),
      ],
    );
  }

  OutlinedButton _buildSkipButton() {
    return OutlinedButton(
      onPressed: _toAuth,
      child: const Text('Skip'),
    );
  }

  ElevatedButton _buildGetStartedButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: _toAuth,
      child: const Text(
        'Get Started',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  FilledButton _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
    );
  }

  void _navigateToOnboarding() {
    setState(() {
      _currentPage = 0;
    });
  }

  void _toAuth() {
    setState(() {
      _currentPage = 4;
    });
  }
}
