import 'package:db2_ubuntu_app/screens/queries/query_widget.dart';
import 'package:flutter/material.dart';

class ComplexQueryScreen extends StatelessWidget {
  var query = "SELECT c.customerid, c.name, c.address AS customer_name\n" +
  "FROM customers c\n" +
  "JOIN orders o ON c.customerid = o.customerid\n" +
  "JOIN orderitems oi ON o.orderid = oi.orderid\n" +
  "JOIN items i ON oi.itemid = i.itemid\n" +
  "WHERE c.name != @param and i.name IN  (\n" +
  "    SELECT i2.name\n" +
  "    FROM customers c2\n" +
  "    JOIN orders o2 ON c2.customerid = o2.customerid\n" +
  "    JOIN orderitems oi2 ON o2.orderid = oi2.orderid\n" +
  "    JOIN items i2 ON oi2.itemid = i2.itemid\n" +
  "    WHERE c2.name = @param\n" +
  ")\n" +
  "GROUP BY o.orderid, c.customerid, c.name\n" +
  "HAVING COUNT(DISTINCT i.itemid) >= (\n" +
  "    SELECT COUNT(DISTINCT i2.itemid)\n" +
  "    FROM customers c2\n" +
  "    JOIN orders o2 ON c2.customerid = o2.customerid\n" +
  "    JOIN orderitems oi2 ON o2.orderid = oi2.orderid\n" +
  "    JOIN items i2 ON oi2.itemid = i2.itemid\n" +
  "    WHERE c2.name = @param\n" +
  ")";

  var query2 =  "WITH john_employees AS (\n" +
      "  SELECT employeeid\n" +
      "  FROM orders\n" +
      "  WHERE customerid = (\n" +
      "    SELECT customerid\n" +
      "    FROM customers\n" +
      "    WHERE name = @param\n" +
      "  )\n" +
      "), customer_employees AS (\n" +
      "  SELECT customerid, employeeid\n" +
      "  FROM orders\n" +
      "  WHERE employeeid IN (SELECT employeeid FROM john_employees)\n" +
      "  GROUP BY customerid, employeeid\n" +
      ")\n" +
      "SELECT DISTINCT c.customerid, c.name, c.address\n" +
      "FROM customers c\n" +
      "JOIN customer_employees ce ON ce.customerid = c.customerid\n" +
      "WHERE c.name != @param";

  var query3 = "SELECT DISTINCT c2. customerid, c2.name, c2.address\n" +
      "FROM customers c1\n" +
      "JOIN orders o1 ON c1.customerid = o1.customerid\n" +
      "JOIN employees e ON o1.employeeid = e.employeeid\n" +
      "JOIN orders o2 ON e.employeeid = o2.employeeid\n" +
      "JOIN customers c2 ON o2.customerid = c2.customerid\n" +
      "WHERE c1.name = @param and c2.name != @param\n" +
      "AND NOT EXISTS (\n" +
      "  SELECT 1\n" +
      "  FROM orders o3\n" +
      "  JOIN employees e2 ON o3.employeeid = e2.employeeid\n" +
      "  WHERE o3.customerid = c2.customerid\n" +
      "  AND e2.employeeid NOT IN (\n" +
      "    SELECT o4.employeeid\n" +
      "    FROM orders o4\n" +
      "    JOIN customers c3 ON o4.customerid = c3.customerid\n" +
      "    WHERE c3.customerid = c1.customerid\n" +
      "  ))\n";

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
            _buildQueryButton(context, 'Query 1', QueryWidget(query: query, description: 'Показати клієнтів що замовляли принаймні ті ж товари що і клієнт імя якого увів користувач', parametrName: 'param')),
            _buildQueryButton(context, 'Query 2', QueryWidget(query: query2, description: 'Знайти усіх клієнтів що обслуговувалися хоча б одним з працівників які обсуговували імя введеного користувача', parametrName: 'param')),
            _buildQueryButton(context, 'Query 3', QueryWidget(query: query3, description: 'Знайти клієнстів що обслуговувалися тими і тільки тими ж працівниками що і клієнт з введеним імям', parametrName: 'param'))
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
