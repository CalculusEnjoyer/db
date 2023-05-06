import 'package:db2_ubuntu_app/screens/queries/query_widget.dart';
import 'package:flutter/material.dart';

class SimpleQueryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Query'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildQueryButton(context, 'Query 1', QueryWidget(query: 'Select * from Employees where salary > @param', description: 'Показати працівників зарплатня яких більша ніж введений параметр.', parametrName: 'param')),
            _buildQueryButton(context, 'Query 2', QueryWidget(query: 'Select * from Customers where name = @param', description: 'Показати користувачів із уведеним ім\'ям', parametrName: 'param')),
            _buildQueryButton(context, 'Query 3', QueryWidget(query: 'Select * from Employees where salary >= @param', description: 'Перевірка', parametrName: 'param')),
            _buildQueryButton(context, 'Query 4', QueryWidget(query: 'Select * from Employees where salary >= @param', description: 'Перевірка', parametrName: 'param')),
            _buildQueryButton(context, 'Query 5', QueryWidget(query: 'Select * from Employees where salary >= @param', description: 'Перевірка', parametrName: 'param')),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryButton(BuildContext context, String queryName, Widget nextScreen) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen)),
        child: Text(queryName),
      ),
    );
  }
}
