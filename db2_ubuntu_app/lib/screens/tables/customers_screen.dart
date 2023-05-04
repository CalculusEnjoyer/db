import 'package:db2_ubuntu_app/constants.dart';
import 'package:db2_ubuntu_app/database/database.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class CustomersScreen extends StatefulWidget {
  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  PostgreSQLConnection? db;
  bool _isEditing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  var _customers = [];
  int? _idToEdit;

  final _controller = ScrollController(keepScrollOffset: true);
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _scrollKey = GlobalKey();
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _getCustomers();
  }

  Future<void> _getCustomers() async {
    // Set up a connection to the database
    db = await DatabaseConnection().connection;
    // Retrieve the data from the Customers table
    var result = await db!.query('SELECT * FROM Customers');
    _customers = result.toList();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Customers'),
      ),
      body: Column(children: [
    Expanded(
      child: SingleChildScrollView(
        key: _scrollKey,
        controller: _controller,
        child: FutureBuilder(
          future: _getCustomers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              _customers.sort((a, b) => a[0].compareTo(b[0]));
              return DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('')),
                ],
                rows: _customers
                    .map(
                      (customer) => DataRow(
                        color: customer[0] == _idToEdit? MaterialStateColor.resolveWith((states) => Colors.red): MaterialStateColor.resolveWith((states) => Colors.white),
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
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                  _idToEdit = customer[0];
                                  _nameController.text = customer[1];
                                  _addressController.text = customer[2];
                                  _phoneController.text = customer[3];
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
    ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Column(children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if ((value ?? "").isEmpty) {
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
                      if ((value ?? "").isEmpty) {
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
                      if ((value ?? "").isEmpty) {
                        return 'Please enter a phone number';
                      } else if (!Constants.PHONE_NUMBER_REGEX
                          .hasMatch(value ?? "")) {
                        return 'Please enter a phone number in format 0xx-xxx-xx-xx';
                      }
                      return null;
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 50.0),
                              child: ElevatedButton(
                                  child: _isEditing
                                      ? Text('Update Customer')
                                      : Text('Add Customer'),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (_isEditing) {
                                        // Update the selected record in the Customers table
                                        await db!.execute(
                                          'UPDATE Customers SET Name = @name, Address = @address, Phone = @phone WHERE CustomerID = @id',
                                          substitutionValues: {
                                            'id': _idToEdit,
                                            'name': _nameController.text,
                                            'address': _addressController.text,
                                            'phone': _phoneController.text,
                                          },
                                        );
                                        // Clear the form and exit edit mode
                                        setState(() {
                                          _isEditing = false;
                                          _nameController.clear();
                                          _addressController.clear();
                                          _phoneController.clear();
                                          _isEditing = false;
                                          _idToEdit = null;
                                        });
                                      } else {
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
                                      }
                                    }
                                  }),
                            ),
                            if (_isEditing)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                                child: ElevatedButton(
                                    child: const Text('Cancel'),
                                    style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red)),
                                    onPressed: () => setState(() {
                                          _isEditing = false;
                                          _idToEdit = null;
                                          _nameController.clear();
                                          _addressController.clear();
                                          _phoneController.clear();
                                        })),
                              ),
                          ],
                        ),
                      ))
                ]),
              ),
            )),
      ]),
    );
  }
}
