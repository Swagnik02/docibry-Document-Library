import 'package:docibry/services/database_helper.dart';
import 'package:flutter/material.dart';

class DbViewPage extends StatefulWidget {
  const DbViewPage({super.key});

  @override
  DbViewPageState createState() => DbViewPageState();
}

class DbViewPageState extends State<DbViewPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<String>> _tableNames;

  @override
  void initState() {
    super.initState();
    _tableNames = _dbHelper.getTableNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer'),
      ),
      body: FutureBuilder<List<String>>(
        future: _tableNames,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tables found.'));
          } else {
            final tables = snapshot.data!;

            return ListView.builder(
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final tableName = tables[index];
                return ListTile(
                  title: Text(tableName),
                  onTap: () => _navigateToTableData(context, tableName),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToTableData(BuildContext context, String tableName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TableDataPage(tableName: tableName, dbHelper: _dbHelper),
      ),
    );
  }
}

class TableDataPage extends StatefulWidget {
  final String tableName;
  final DatabaseHelper dbHelper;

  const TableDataPage(
      {super.key, required this.tableName, required this.dbHelper});

  @override
  TableDataPageState createState() => TableDataPageState();
}

class TableDataPageState extends State<TableDataPage> {
  late Future<List<Map<String, dynamic>>> _tableData;

  @override
  void initState() {
    super.initState();
    _tableData = widget.dbHelper.getTableData(widget.tableName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tableData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          } else {
            final data = snapshot.data!;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final row = data[index];
                return ListTile(
                  title: Text(row.toString()),
                );
              },
            );
          }
        },
      ),
    );
  }
}
