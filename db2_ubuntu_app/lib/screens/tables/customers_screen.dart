import 'dart:io';

import 'package:db2_ubuntu_app/database/database.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class CustomersScreen extends StatefulWidget {
  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  PostgreSQLConnection? db;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  var _customers = [];

  Future<void> _getCustomers() async {
    // Set up a connection to the database
    db = await DatabaseConnection().connection;

    // Retrieve the data from the Customers table
    var result = await db!.query('SELECT * FROM Customers');
    _customers = result.toList();
  }

  @override
  void initState() {
    super.initState();
    _getCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _getCustomers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return DataTable(
                    columns: [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: _customers
                        .map(
                          (customer) => DataRow(
                            cells: [
                              DataCell(Text(customer[0].toString())),
                              DataCell(Text(customer[1])),
                              DataCell(Text(customer[2])),
                              DataCell(Text(customer[3])),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    // Delete the selected record from the Customers table
                                    await db!.execute(
                                        'DELETE FROM Customers WHERE CustomerID = @id',
                                        substitutionValues: {
                                          'id': customer[0]
                                        });
                                    // Refresh the data
                                    setState(() {
                                      _customers.remove(customer);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if ((value??"").isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                    ),
                    validator: (value) {
                      if ((value??"").isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                    ),
                    validator: (value) {
                      if ((value??"").isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    child: Text('Add Customer'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Set up a connection to the databa
                        // Insert the new record into the Customers table
                        await db!.execute(
                          'INSERT INTO Customers (Name, Address, Phone) VALUES (@name, @address, @phone)',
                          substitutionValues: {
                            'name': _nameController.text,
                            'address': _addressController.text,
                            'phone': _phoneController.text,
                          },
                        );

                        // Clear the form
                        setState(() {
                          _nameController.clear();
                          _addressController.clear();
                          _phoneController.clear();
                        });

                        // Refresh the data
                        _getCustomers();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
