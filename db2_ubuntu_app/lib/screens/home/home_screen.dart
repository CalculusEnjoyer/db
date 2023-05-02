import 'package:db2_ubuntu_app/screens/tables/customers_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (_) => CustomersScreen()));
              },
            ),
            ListTile(
              title: Text('Employees'),
              onTap: () {
                // Handle option 2 tap
              },
            ),
            ListTile(
              title: Text('Items'),
              onTap: () {
                // Handle option 3 tap
              },
            ),
            ListTile(
              title: Text('Order Items'),
              onTap: () {
                // Handle option 4 tap
              },
            ),
            ListTile(
              title: Text('Orders'),
              onTap: () {
                // Handle option 5 tap
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
                // Handle complex query button press
              },
              child: Text('Complex Queries'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle simple queries button press
              },
              child: Text('Simple Queries'),
            ),
          ],
        ),
      ),
    );
  }
}