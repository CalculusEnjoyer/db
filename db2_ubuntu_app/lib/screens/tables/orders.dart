import 'package:db2_ubuntu_app/constants.dart';
import 'package:db2_ubuntu_app/database/database.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  PostgreSQLConnection? db;
  bool _isEditing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  var _Orders = [];
  int? _idToEdit;

  final _controller = ScrollController(keepScrollOffset: true);
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _scrollKey = GlobalKey();
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _getOrders();
  }

  Future<void> _getOrders() async {
    // Set up a connection to the database
    db = await DatabaseConnection().connection;
    // Retrieve the data from the Orders table
    var result = await db!.query('SELECT * FROM Orders');
    _Orders = result.toList();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            key: _scrollKey,
            controller: _controller,
            child: FutureBuilder(
              future: _getOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  _Orders.sort((a, b) => a[0].compareTo(b[0]));
                  return DataTable(
                    columns: [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Customer ID')),
                      DataColumn(label: Text('Employee ID')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                    ],
                    rows: _Orders
                        .map(
                          (Order) => DataRow(
                        color: Order[0] == _idToEdit? MaterialStateColor.resolveWith((states) => Colors.red): MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(Text(Order[0].toString())),
                          DataCell(Text(Order[1].toString())),
                          DataCell(Text(Order[2].toString())),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                // Delete the selected record from the Orders table
                                await db!.execute(
                                    'DELETE FROM Orders WHERE OrderID = @id',
                                    substitutionValues: {
                                      'id': Order[0]
                                    });
                                // Refresh the data
                                setState(() {
                                  _Orders.remove(Order);
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
                                  _idToEdit = Order[0];
                                  _nameController.text = Order[1].toString();
                                  _addressController.text = Order[2].toString();
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
                      labelText: 'Customer ID',
                    ),
                    validator: (value) {
                      if ((value ?? "").isEmpty) {
                        return 'Please enter an item ID ';
                      } else if (!Constants.INT_REGEX.hasMatch(value!)) {
                        return 'Please enter INT as ID';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Employee ID',
                    ),
                    validator: (value) {
                      if ((value ?? "").isEmpty) {
                        return 'Please enter a quantity of item';
                      } else if (!Constants.INT_REGEX.hasMatch(value!)) {
                        return 'Please enter INT as ID';
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
                                      ? Text('Update Order')
                                      : Text('Add Order'),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (_isEditing) {
                                        // Update the selected record in the Orders table
                                        await db!.execute(
                                          'UPDATE Orders SET ItemID = @name, Quantity = @address WHERE OrderID = @id',
                                          substitutionValues: {
                                            'id': _idToEdit,
                                            'name': _nameController.text,
                                            'address': _addressController.text,
                                          },
                                        );
                                        // Clear the form and exit edit mode
                                        setState(() {
                                          _isEditing = false;
                                          _nameController.clear();
                                          _addressController.clear();
                                          _isEditing = false;
                                          _idToEdit = null;
                                        });
                                      } else {
                                        // Insert the new record into the Orders table
                                        await db!.execute(
                                          'INSERT INTO Orders (CustomerID, EmployeeID) VALUES (@name, @address)',
                                          substitutionValues: {
                                            'name': _nameController.text,
                                            'address': _addressController.text,
                                          },
                                        );
                                        // Clear the form
                                        setState(() {
                                          _nameController.clear();
                                          _addressController.clear();
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
