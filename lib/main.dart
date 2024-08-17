import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/constants/routes.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/document/document_bloc.dart';
import 'ui/home/home_page.dart';
import 'ui/document/manage_doc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DocumentBloc()..add(FetchDocuments()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: StringConstants.appFullName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const HomePage(),
        routes: {
          homeRoute: (context) => const HomePage(),
          addDocRoute: (context) => const ManageDocumentPage(isAdd: true),
          viewDocRoute: (context) => const ManageDocumentPage(isAdd: false),
        },
      ),
    );
  }
}
