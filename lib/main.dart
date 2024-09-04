import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/constants/routes.dart';
import 'package:docibry/firebase_options.dart';
import 'package:docibry/repositories/local_db_service.dart';
import 'package:docibry/ui/auth/auth_page.dart';
import 'package:docibry/ui/document/manage_doc.dart';
import 'package:docibry/ui/shareDoc/share_doc_page.dart';
import 'package:docibry/ui/home/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize local database
  if (!kIsWeb) {
    final localDbService = LocalDbService();
    await localDbService.initLocalDb();
  }

  runApp(
    BlocProvider(
      create: (context) => DocumentBloc(),
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
      home: AuthPage(),
      routes: {
        homeRoute: (context) => const HomePage(),
        addDocRoute: (context) => const ManageDocumentPage(isAdd: true),
        viewDocRoute: (context) => const ManageDocumentPage(isAdd: false),
        shareDocRoute: (context) => const ShareDocumentPage(),
      },
    );
  }
}


// class AuthPage extends StatelessWidget {
//   const AuthPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     context.read<AuthBloc>().add(const AuthEventInitialize());

//     return BlocConsumer<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthStateLoading && state.isLoading) {
//           // Display a loading indicator or screen when loading
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(state.loadingText ?? 'Please wait a moment')),
//           );
//         }
//       },
//       builder: (context, state) {
//         if (state is AuthStateLoggedIn) {
//           return const HomePage();
//         } else if (state is AuthStateLoggedOut) {
//           return kIsWeb ? const LoginPage() : Onboarding();
//         } else if (state is AuthStateRegistering) {
//           return const LoginPage();
//         } else if (state is AuthStateLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else {
//           return ProfilePage();
//         }
//       },
//     );
//   }
// }
