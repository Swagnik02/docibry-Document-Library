import 'package:flutter/material.dart';

class TabScaffold extends StatefulWidget {
  final String title;
  final List<String> tabNames;
  final List<Widget> tabContents;
  final Color backgroundColor;
  final Color tabColor;
  final Color selectedTabColor;
  final Color unselectedTabColor;
  final TextStyle labelStyle;
  final TextStyle unselectedLabelStyle;

  const TabScaffold({
    super.key,
    required this.title,
    required this.tabNames,
    required this.tabContents,
    this.backgroundColor = Colors.white,
    this.tabColor = const Color(0xFFFFd0c8),
    this.selectedTabColor = Colors.black,
    this.unselectedTabColor = Colors.black,
    this.labelStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.unselectedLabelStyle = const TextStyle(fontWeight: FontWeight.bold),
  }) : assert(tabNames.length == tabContents.length);

  @override
  _TabScaffoldState createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<TabScaffold>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabNames.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TabBarView(
          controller: _tabController,
          children: widget.tabContents,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
          decoration: BoxDecoration(
            color: widget.tabColor,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: widget.selectedTabColor,
              borderRadius: BorderRadius.circular(25),
            ),
            labelColor: widget.tabColor,
            unselectedLabelColor: widget.unselectedTabColor,
            labelStyle: widget.labelStyle,
            unselectedLabelStyle: widget.unselectedLabelStyle,
            tabs: widget.tabNames.map((name) => Tab(text: name)).toList(),
          ),
        ),
      ],
    );
  }
}
