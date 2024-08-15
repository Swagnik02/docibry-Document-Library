import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/ui/document/add_document_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/document/document_bloc.dart';
import 'ui/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Docibry: Document Library',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: BlocProvider(
        create: (_) => DocumentBloc()..add(FetchDocuments()),
        child: const AddDocumentPage(),
      ),
    );
  }
}
