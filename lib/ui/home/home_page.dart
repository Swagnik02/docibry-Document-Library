import 'dart:developer';

import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/ui/home/doc_category_filter_chip.dart';
import 'package:docibry/ui/home/doc_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = StringDocCategory.allCategory; // Default to 'All'

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'docibry',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              log('message');
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
                  isSelected: selectedCategory == StringDocCategory.allCategory,
                  onSelected: _onCategorySelected,
                ),
                ...StringDocCategory.categoryList
                    .where(
                        (category) => category != StringDocCategory.allCategory)
                    .map((category) {
                  return DocCategoryFilterChip(
                    label: category,
                    isSelected: selectedCategory == category,
                    onSelected: _onCategorySelected,
                  );
                }).toList(),
              ],
            ),
          ),
          // Document tiles
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                children: _buildFilteredDocs(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add document page
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildFilteredDocs() {
    final allDocs = [
      DocCard(docModel: doc1),
      DocCard(docModel: doc2),
      DocCard(docModel: doc3),
    ];

    if (selectedCategory == StringDocCategory.allCategory) {
      return allDocs;
    } else {
      return allDocs
          .where((doc) => doc.docModel.docCategory == selectedCategory)
          .toList();
    }
  }
}
