import 'package:db2_ubuntu_app/database/database.dart';
import 'package:db2_ubuntu_app/screens/queries/choose_screen/complex_queries_screen.dart';
import 'package:db2_ubuntu_app/screens/queries/choose_screen/simple_queries_screen.dart';
import 'package:db2_ubuntu_app/screens/tables/customers_screen.dart';
import 'package:db2_ubuntu_app/screens/tables/employees.dart';
import 'package:db2_ubuntu_app/screens/tables/items.dart';
import 'package:db2_ubuntu_app/screens/tables/order_items.dart';
import 'package:db2_ubuntu_app/screens/tables/orders.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseConnection().connection;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Tables'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Customers'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CustomersScreen()));
              },
            ),
            ListTile(
              title: Text('Employees'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeesScreen()));
              },
            ),
            ListTile(
              title: Text('Items'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ItemsScreen()));
              },
            ),
            ListTile(
              title: Text('Order Items'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => OrderItemsScreen()));
              },
            ),
            ListTile(
              title: Text('Orders'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => OrdersScreen()));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ComplexQueryScreen()));
              },
              child: Text('Complex Queries'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SimpleQueryScreen()));
              },
              child: Text('Simple Queries'),
            ),
          ],
        ),
      ),
    );
  }
}