import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/blocs/onBoarding/onboarding_bloc.dart';
import 'package:docibry/constants/routes.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/services/database_helper.dart';
import 'package:docibry/ui/onBoarding/onboarding.dart';
import 'package:docibry/ui/shareDoc/share_doc_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/document/document_bloc.dart';
import 'ui/home/home_page.dart';
import 'ui/document/manage_doc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().getDocuments();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(
          create: (context) => OnboardingBloc(),
        ),
        BlocProvider<DocumentBloc>(
          create: (context) => DocumentBloc()..add(FetchDocuments()),
        ),
        // Add other BlocProviders here
      ],
      child: DocibryApp(),
    ),
  );
}

class DocibryApp extends StatelessWidget {
  const DocibryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConstants.appFullName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: Onboarding(),
      routes: {
        homeRoute: (context) => const HomePage(),
        addDocRoute: (context) => const ManageDocumentPage(isAdd: true),
        viewDocRoute: (context) => const ManageDocumentPage(isAdd: false),
        shareDocRoute: (context) => const ShareDocumentPage(),
      },
    );
  }
}
