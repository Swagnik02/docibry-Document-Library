import 'package:docibry/blocs/auth/auth_bloc.dart';
import 'package:docibry/blocs/auth/auth_states.dart';
import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/blocs/onBoarding/onboarding_bloc.dart';
import 'package:docibry/constants/routes.dart';
import 'package:docibry/firebase_options.dart';
import 'package:docibry/models/user_model.dart';
import 'package:docibry/ui/Auth/auth_page.dart';
import 'package:docibry/ui/document/manage_doc.dart';
import 'package:docibry/ui/onBoarding/onboarding.dart';
import 'package:docibry/ui/shareDoc/share_doc_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ui/home/home_page.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<DocumentBloc>(
          create: (context) =>
              DocumentBloc(userId: loggedInUserId)..add(FetchDocuments()),
        ),
        if (!kIsWeb)
          BlocProvider<OnboardingBloc>(
            create: (context) => OnboardingBloc(),
          ),
      ],
      child: const DocibryApp(),
    ),
  );
}

class DocibryApp extends StatelessWidget {
  const DocibryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Docibry',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoggedIn) {
            return const HomePage();
          } else {
            return kIsWeb ? const AuthPage() : Onboarding();
          }
        },
      ),
      routes: {
        homeRoute: (context) => const HomePage(),
        addDocRoute: (context) => const ManageDocumentPage(isAdd: true),
        viewDocRoute: (context) => const ManageDocumentPage(isAdd: false),
        shareDocRoute: (context) => const ShareDocumentPage(),
      },
    );
  }
}
