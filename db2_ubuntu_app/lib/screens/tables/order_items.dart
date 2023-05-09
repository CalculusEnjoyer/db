import 'dart:core';

import 'package:db2_ubuntu_app/constants.dart';
import 'package:db2_ubuntu_app/database/database.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class OrderItemsScreen extends StatefulWidget {
  @override
  _OrderItemsScreenState createState() => _OrderItemsScreenState();
}

class _OrderItemsScreenState extends State<OrderItemsScreen> {
  PostgreSQLConnection? db;
  bool _isEditing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _OrderIDController = TextEditingController();
  final _ItemIdController = TextEditingController();
  final _QuantityController = TextEditingController();
  var _OrderItems = [];
  int? _OrderIdToEdit;
  int? _ItemIdToEdit;

  final _controller = ScrollController(keepScrollOffset: true);
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _scrollKey = GlobalKey();
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _getOrderItems();
  }

  Future<void> _getOrderItems() async {
    // Set up a connection to the database
    db = await DatabaseConnection().connection;
    // Retrieve the data from the OrderItems table
    var result = await db!.query('SELECT * FROM OrderItems');
    _OrderItems = result.toList();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('OrderItems'),
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            key: _scrollKey,
            controller: _controller,
            child: FutureBuilder(
              future: _getOrderItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  _OrderItems.sort((a, b) => a[0].compareTo(b[0]));
                  return DataTable(
                    columns: [
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Item ID')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                    ],
                    rows: _OrderItems.map(
                      (OrderItem) => DataRow(
                        color: OrderItem[0] == _OrderIdToEdit &&
                                OrderItem[1] == _ItemIdToEdit
                            ? MaterialStateColor.resolveWith(
                                (states) => Colors.red)
                            : MaterialStateColor.resolveWith(
                                (states) => Colors.white),
                        cells: [
                          DataCell(Text(OrderItem[0].toString())),
                          DataCell(Text(OrderItem[1].toString())),
                          DataCell(Text(OrderItem[2].toString())),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                // Delete the selected record from the OrderItems table
                                await db!.execute(
                                    'DELETE FROM OrderItems WHERE OrderID = @Orderid and ItemID = @Itemid',
                                    substitutionValues: {
                                      'Orderid': OrderItem[0],
                                      'Itemid': OrderItem[1]
                                    });
                                // Refresh the data
                                setState(() {
                                  _OrderItems.remove(OrderItem);
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
                                  _OrderIdToEdit = OrderItem[0];
                                  _ItemIdToEdit = OrderItem[1];
                                  _OrderIDController.text =
                                      OrderItem[0].toString();
                                  _ItemIdController.text =
                                      OrderItem[1].toString();
                                  _QuantityController.text =
                                      OrderItem[2].toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ).toList(),
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
                    controller: _OrderIDController,
                    decoration: InputDecoration(
                      labelText: 'Order ID',
                    ),
                    validator: (value) {
                      if ((value ?? "").isEmpty) {
                        return 'Please enter an Order ID ';
                      } else if (!Constants.INT_REGEX.hasMatch(value!)) {
                        return 'Please enter INT as ID';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ItemIdController,
                    decoration: InputDecoration(
                      labelText: 'Item ID',
                    ),
                    validator: (value) {
                      if ((value ?? "").isEmpty) {
                        return 'Please enter an Item ID ';
                      } else if (!Constants.INT_REGEX.hasMatch(value!)) {
                        return 'Please enter INT as ID';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _QuantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50.0),
                              child: ElevatedButton(
                                  child: _isEditing
                                      ? Text('Update Order + Item')
                                      : Text('Add Order + Item'),
                                  onPressed: () async {
                                    try {
                                      if (_formKey.currentState!.validate()) {
                                        if (_isEditing) {
                                          // Update the selected record in the OrderItems table
                                          await db!.execute(
                                            'UPDATE OrderItems SET orderid = @orderidtoset, ItemID = @name, Quantity = @address WHERE OrderID = @Orderid and ItemID = @Itemid',
                                            substitutionValues: {
                                              'Orderid': _OrderIdToEdit,
                                              'Itemid': _ItemIdToEdit,
                                              'orderidtoset':
                                                  _OrderIDController.text,
                                              'name': _ItemIdController.text,
                                              'address':
                                                  _QuantityController.text,
                                            },
                                          );
                                          // Clear the form and exit edit mode
                                          setState(() {
                                            _isEditing = false;
                                            _ItemIdController.clear();
                                            _QuantityController.clear();
                                            _OrderIDController.clear();
                                            _isEditing = false;
                                            _OrderIdToEdit = null;
                                            _ItemIdToEdit = null;
                                          });
                                        } else {
                                          // Insert the new record into the OrderItems table
                                          await db!.execute(
                                            'INSERT INTO OrderItems (OrderId, ItemID, Quantity) VALUES (@orderid, @name, @address)',
                                            substitutionValues: {
                                              'orderid':
                                                  _OrderIDController.text,
                                              'name': _ItemIdController.text,
                                              'address':
                                                  _QuantityController.text,
                                            },
                                          );
                                          // Clear the form
                                          setState(() {
                                            _ItemIdController.clear();
                                            _QuantityController.clear();
                                            _OrderIDController.clear();
                                          });
                                        }
                                      }
                                    } catch (e) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Warning'),
                                            content: Text(e
                                                .toString()
                                                .substring(
                                                    e.toString().indexOf(':') +
                                                        2)),
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
                                  }),
                            ),
                            if (_isEditing)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50.0),
                                child: ElevatedButton(
                                    child: const Text('Cancel'),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.red)),
                                    onPressed: () => setState(() {
                                          _isEditing = false;
                                          _OrderIdToEdit = null;
                                          _ItemIdToEdit = null;
                                          _ItemIdController.clear();
                                          _QuantityController.clear();
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
