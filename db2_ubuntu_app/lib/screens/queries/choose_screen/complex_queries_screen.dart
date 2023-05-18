import 'package:db2_ubuntu_app/screens/queries/query_widget.dart';
import 'package:flutter/material.dart';

class ComplexQueryScreen extends StatelessWidget {
  var query = "SELECT DISTINCT c.customerid, c.name, c.address, c.phone\n" +
      "    FROM customers c\n" +
      "    JOIN orders o ON c.customerid = o.customerid\n" +
      "    JOIN orderitems oi ON o.orderid = oi.orderid\n" +
      "    JOIN items i ON oi.itemid = i.itemid\n" +
      "    WHERE c.customerid != @param AND NOT EXISTS (\n" +
      "            SELECT 1\n" +
      "            FROM orderitems john_oi\n" +
      "            JOIN orders john_o ON john_oi.orderid = john_o.orderid\n" +
      "            WHERE john_o.customerid = @param\n" +
      "            AND NOT EXISTS (\n" +
      "            SELECT 1\n" +
      "            FROM orderitems john_oi2\n" +
      "            WHERE john_oi2.orderid = john_o.orderid\n" +
      "            AND john_oi2.itemid = i.itemid\n" +
      "    )\n" +
      ")\n" +
      "    AND NOT EXISTS (\n" +
      "            SELECT 1\n" +
      "            FROM orderitems other_oi\n" +
      "            WHERE other_oi.orderid = o.orderid\n" +
      "            AND NOT EXISTS (\n" +
      "            SELECT 1\n" +
      "            FROM orderitems john_oi3\n" +
      "            JOIN orders john_o2 ON john_oi3.orderid = john_o2.orderid\n" +
      "            WHERE john_o2.customerid = @param\n" +
      "            AND john_oi3.itemid = other_oi.itemid\n" +
      "    )\n" +
      ")";

  var query2 = "SELECT DISTINCT c.name, c.address, c.phone\n" +
      "FROM customers c\n" +
      "JOIN orders o ON c.customerid = o.customerid\n" +
      "WHERE c.name != @param AND NOT EXISTS (\n" +
      "  SELECT e.employeeid\n" +
      "  FROM employees e\n" +
      "  WHERE e.name = @param\n" +
      "    AND NOT EXISTS (\n" +
      "      SELECT *\n" +
      "      FROM orders o2\n" +
      "      WHERE o2.customerid = o.customerid\n" +
      "        AND o2.employeeid = e.employeeid\n" +
      "    )\n" +
      ")";

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
            _buildQueryButton(context, 'Query 1', QueryWidget(query: query, description: 'Показати клієнтів що замовляли лише ті товари (але не обовязково всі) що і клієнт ID якого увів користувач', parametrName: 'param')),
            _buildQueryButton(context, 'Query 2', QueryWidget(query: query2, description: 'Знайти усіх клієнтів що обслуговувалися принаймні тими ж  працівниками які обсуговували імя введеного користувача', parametrName: 'param')),
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
