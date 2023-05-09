import 'package:db2_ubuntu_app/database/database.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class QueryWidget extends StatefulWidget {
  QueryWidget({
    Key? key,
    required this.query,
    required this.description,
    required this.parametrName,
  }) : super(key: key);

  String query;
  String description;
  String parametrName;
  @override
  _QueryWidgetState createState() => _QueryWidgetState();
}

class _QueryWidgetState extends State<QueryWidget> {
  late String _query;
  late String _description;
  late String _parametrName;
  PostgreSQLConnection? _db;
  PostgreSQLResult? _results;

  final _textEditingController = TextEditingController();



  @override
  void initState() {
    super.initState();
    _getDbConnection();
    _query = widget.query;
    _description = widget.description;
    _parametrName = widget.parametrName;
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
    final results = await _db!.query(
      _query,
      substitutionValues: {
        '${_parametrName}' : _textEditingController.text
      },);
    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQL Query'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(_description),
          ),

          Padding(
            padding: const EdgeInsets.all(0.0),
            child: SizedBox(
              height: (_results ?? []).length == 0 ? 270 : 120,
              child: SingleChildScrollView(
                child: Text(_query),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: _textEditingController,
                decoration:  InputDecoration(
                  hintText: 'Enter ${_parametrName}',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await _executeQuery();
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Warning'),
                        content: Text(e.toString().substring(e.toString().indexOf(':')+2)),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Execute Query'),
            ),
          ),
          if (_results != null)
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: _results!.columnDescriptions
                      .map((desc)=> DataColumn(label: Text(desc.columnName)))
                      .toList(),
                  rows: _results!
                      .map(
                        (row)=> DataRow(
                      cells: row.toColumnMap().values.map((value) => DataCell(Text(value.toString()))).toList()
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
