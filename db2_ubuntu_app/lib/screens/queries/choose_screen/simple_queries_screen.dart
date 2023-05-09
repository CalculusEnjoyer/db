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
            _buildQueryButton(context, 'Query 1', QueryWidget(query: 'SELECT items.itemid, items.name, SUM(orderitems.quantity) AS total_ordered \nFROM items JOIN orderitems ON items.itemid = orderitems.itemid \nGROUP BY items.itemid \nHAVING SUM(orderitems.quantity) > @param', description: 'Показати позиції у меню що були замовлені більше разів ніж введений параметр.', parametrName: 'param')),
            _buildQueryButton(context, 'Query 2', QueryWidget(query: 'SELECT DISTINCT employees.* FROM employees \nJOIN orders ON employees.employeeid = orders.employeeid \nJOIN customers ON orders.customerid = customers.customerid \nWHERE customers.name = @param', description: 'Показати працівників закладу які колись готували замовлення відвідувачу з ім\'ям уведеним у поле', parametrName: 'param')),
            _buildQueryButton(context, 'Query 3', QueryWidget(query: 'SELECT employees.name, employees.position FROM employees \nJOIN orders ON employees.employeeid = orders.employeeid \nWHERE orders.orderid = @param', description: 'Знайти ім\'я працівника та посаду який підготував замовлення номер якого увів користувач:', parametrName: 'param')),
            _buildQueryButton(context, 'Query 4', QueryWidget(query: 'SELECT DISTINCT items.* FROM items \nJOIN orderitems ON items.itemid = orderitems.itemid \nJOIN orders ON orderitems.orderid = orders.orderid \nJOIN customers ON orders.customerid = customers.customerid \nWHERE customers.name = @param', description: 'Показати позиції у меню що замовляв клієнт з уведеним ім\'ям:', parametrName: 'param')),
            _buildQueryButton(context, 'Query 5', QueryWidget(query: 'SELECT DISTINCT customers.* FROM customers \nJOIN orders ON customers.customerid = orders.customerid \nJOIN orderitems ON orders.orderid = orderitems.orderid \nJOIN items ON orderitems.itemid = items.itemid \nWHERE items.price > @param;', description: 'Показати клієнтів що замовляли позицію що коштує дорожче за ввеедний параметр:', parametrName: 'param')),
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
