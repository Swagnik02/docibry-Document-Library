import 'package:docibry/constants/string_constants.dart';
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
              // Navigate to profile page
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
                    borderRadius: BorderRadius.all(Radius.circular(25))),
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
      const DocCard(
        docCategory: StringDocCategory.identity,
        docName: 'Aadhaar',
      ),
      const DocCard(
        docCategory: StringDocCategory.education,
        docName: 'Marksheet',
      ),
      const DocCard(
        docCategory: StringDocCategory.health,
        docName: 'Health Card',
      ),
      // Add more documents here
    ];

    if (selectedCategory == StringDocCategory.allCategory) {
      return allDocs;
    } else {
      return allDocs
          .where((doc) => doc.docCategory == selectedCategory)
          .toList();
    }
  }
}

class DocCategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final ValueChanged<String> onSelected;

  const DocCategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.isDisabled = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        showCheckmark: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(35)),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isDisabled
                ? Colors.grey
                : (isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.black),
          ),
        ),
        selected: isSelected,
        backgroundColor: isDisabled ? Colors.grey.shade200 : Colors.transparent,
        selectedColor: Theme.of(context).colorScheme.primary,
        onSelected: isDisabled ? null : (_) => onSelected(label),
      ),
    );
  }
}

class DocCard extends StatelessWidget {
  final String docCategory;
  final String docName;

  const DocCard({
    super.key,
    required this.docCategory,
    required this.docName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16, right: 16, left: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(25),
      ),
      width: double.infinity,
      child: Text(
        docName,
        style: const TextStyle(color: Colors.black, fontSize: 30),
      ),
    );
  }
}
