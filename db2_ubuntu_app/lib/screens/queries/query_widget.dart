import 'package:db2_ubuntu_app/database/database.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:sqflite/sqflite.dart';

class QueryWidget extends StatefulWidget {
  const QueryWidget({Key? key}) : super(key: key);

  @override
  _QueryWidgetState createState() => _QueryWidgetState();
}

class _QueryWidgetState extends State<QueryWidget> {
  late String _query;
  PostgreSQLConnection? _db;
  List<Map<String, dynamic>>? _results;

  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDbConnection();
    _query = '';
    _results = null;
  }

  void _getDbConnection() async {
    _db = await DatabaseConnection().connection;
  }


  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _executeQuery() async {
    final List<Map<String, dynamic>> results = await database.rawQuery(_query);
    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Query'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              hintText: 'Enter SQL query',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: _executeQuery,
            child: const Text('Execute Query'),
          ),
          if (_results != null)
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: _results!.first.keys
                      .map((String key) => DataColumn(label: Text(key)))
                      .toList(),
                  rows: _results!
                      .map(
                        (Map<String, dynamic> row) => DataRow(
                      cells: row.values
                          .map(
                            (value) => DataCell(Text(value.toString())),
                      )
                          .toList(),
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
