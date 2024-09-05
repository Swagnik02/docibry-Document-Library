import 'dart:math';
import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/constants/routes.dart';
import 'package:docibry/ui/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/models/document_model.dart';
import 'widgets/doc_card.dart';
import 'widgets/doc_category_filter_chip.dart';
import 'widgets/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String selectedFilter = StringDocCategory.allCategory;
  String searchQuery = '';

  void _onCategorySelected(String category) {
    setState(() {
      selectedFilter = category;
    });
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<DocumentBloc>().add(GetDocument());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DocumentLoaded) {
          List<DocModel> documents = state.documents;

          List<DocModel> filteredDocs = documents
              .where((doc) =>
                  (selectedFilter == StringDocCategory.allCategory ||
                      doc.docCategory == selectedFilter) &&
                  doc.docName.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return Scaffold(
            appBar: AppBar(
              title:
                  CustomSearchBar(onSearchQueryChanged: _onSearchQueryChanged),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                _categoryFilters(),
                _docs(filteredDocs),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, addDocRoute),
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                StringConstants.appName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.person),
                ),
              ],
            ),
            body: const Center(child: Text(StringConstants.stringNoDataFound)),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, addDocRoute),
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }

  Expanded _docs(List<DocModel> filteredDocs) {
    final currentCount = (MediaQuery.of(context).size.width ~/ 200).toInt();

    return Expanded(
      child: filteredDocs.isEmpty
          ? const Center(
              child: Text(StringConstants.stringNoDataFound),
            )
          : MediaQuery.of(context).size.width > 395
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: max(currentCount, 2),
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    return DocCard(docModel: filteredDocs[index]);
                  },
                )
              : ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    return DocCard(docModel: filteredDocs[index]);
                  },
                ),
    );
  }

  SingleChildScrollView _categoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DocCategoryFilterChip(
              label: StringDocCategory.allCategory,
              isSelected: selectedFilter == StringDocCategory.allCategory,
              onSelected: _onCategorySelected,
            ),
            ...StringDocCategory.categoryList
                .where((category) => category != StringDocCategory.allCategory)
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
    );
  }
}
