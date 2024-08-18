import 'package:docibry/constants/routes.dart';
import 'package:docibry/services/db_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/constants/string_constants.dart';
import 'doc_card.dart';
import 'doc_category_filter_chip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String selectedFilter = StringDocCategory.allCategory;

  void _onCategorySelected(String category) {
    setState(() {
      selectedFilter = category;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<DocumentBloc>().add(FetchDocuments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          StringConstants.appName,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DbViewPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search documents...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Categories Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DocCategoryFilterChip(
                  label: StringDocCategory.allCategory,
                  isSelected: selectedFilter == StringDocCategory.allCategory,
                  onSelected: _onCategorySelected,
                ),
                ...StringDocCategory.categoryList
                    .where(
                        (category) => category != StringDocCategory.allCategory)
                    .map((category) {
                  return DocCategoryFilterChip(
                    label: category,
                    isSelected: selectedFilter == category,
                    onSelected: _onCategorySelected,
                  );
                }),
              ],
            ),
          ),
          // Document tiles
          Expanded(
            child: BlocBuilder<DocumentBloc, DocumentState>(
              builder: (context, state) {
                if (state is DocumentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DocumentLoaded) {
                  final filteredDocs = state.documents
                      .where((doc) =>
                          selectedFilter == StringDocCategory.allCategory ||
                          doc.docCategory == selectedFilter)
                      .toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text('No documents found'));
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      return DocCard(docModel: filteredDocs[index]);
                    },
                  );
                } else if (state is DocumentError) {
                  return Center(child: Text('Error: ${state.error}'));
                }
                return const Center(child: Text('No documents available'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, addDocRoute),
        child: const Icon(Icons.add),
      ),
    );
  }
}
