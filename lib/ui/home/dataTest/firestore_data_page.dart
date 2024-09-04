import 'package:docibry/repositories/local_db_service.dart';
import 'package:flutter/material.dart';

class LocalDatabasePage extends StatefulWidget {
  @override
  _LocalDatabasePageState createState() => _LocalDatabasePageState();
}

class _LocalDatabasePageState extends State<LocalDatabasePage> {
  Map<String, List<Map<String, dynamic>>> _databaseData = {};

  @override
  void initState() {
    super.initState();
    _loadDatabaseData();
  }

  Future<void> _loadDatabaseData() async {
    final dbService = LocalDbService();
    await dbService.initLocalDb();
    final tableNames = await dbService.getTableNamesLocalDb();

    Map<String, List<Map<String, dynamic>>> dbData = {};

    for (String tableName in tableNames) {
      final tableData = await dbService.getTableDataLocalDb(tableName);
      dbData[tableName] = tableData;
    }

    setState(() {
      _databaseData = dbData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Database Data'),
      ),
      body: _databaseData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: _databaseData.entries.map((entry) {
                final tableName = entry.key;
                final tableData = entry.value;

                return ExpansionTile(
                  title: Text(tableName),
                  children: tableData.map((data) {
                    return ListTile(
                      title: Text(data.toString()),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}
