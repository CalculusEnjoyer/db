import 'package:db2_ubuntu_app/constants.dart';
import 'package:db2_ubuntu_app/database/database.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class ItemsScreen extends StatefulWidget {
  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  PostgreSQLConnection? db;
  bool _isEditing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  var _Items = [];
  int? _idToEdit;

  final _controller = ScrollController(keepScrollOffset: true);
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _scrollKey = GlobalKey();
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _getItems();
  }

  Future<void> _getItems() async {
    // Set up a connection to the database
    db = await DatabaseConnection().connection;
    // Retrieve the data from the Items table
    var result = await db!.query('SELECT * FROM Items');
    _Items = result.toList();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Items'),
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            key: _scrollKey,
            controller: _controller,
            child: FutureBuilder(
              future: _getItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  _Items.sort((a, b) => a[0].compareTo(b[0]));
                  return DataTable(
                    columns: [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                    ],
                    rows: _Items
                        .map(
                          (Item) => DataRow(
                        color: Item[0] == _idToEdit? MaterialStateColor.resolveWith((states) => Colors.red): MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(Text(Item[0].toString())),
                          DataCell(Text(Item[1])),
                          DataCell(Text(Item[2])),
                          DataCell(Text(Item[3])),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                // Delete the selected record from the Items table
                                await db!.execute(
                                    'DELETE FROM Items WHERE ItemID = @id',
                                    substitutionValues: {
                                      'id': Item[0]
                                    });
                                // Refresh the data
                                setState(() {
                                  _Items.remove(Item);
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
                                  _idToEdit = Item[0];
                                  _nameController.text = Item[1];
                                  _addressController.text = Item[2];
                                  _phoneController.text = Item[3];
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
                      labelText: 'Description',
                    ),
                    validator: (value) {
                      if ((value ?? "").isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                    ),
                    validator: (value) {
                      if ((value ?? "").isEmpty) {
                        return 'Please enter a price';
                      } else if (!Constants.DOUBLE_OR_INT_REGEX
                          .hasMatch(value ?? "")) {
                        return 'Please enter a valid price';
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
                                      ? Text('Update Item')
                                      : Text('Add Item'),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (_isEditing) {
                                        // Update the selected record in the Items table
                                        await db!.execute(
                                          'UPDATE Items SET Name = @name, Description = @address, Price = @phone WHERE ItemID = @id',
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
                                        // Insert the new record into the Items table
                                        await db!.execute(
                                          'INSERT INTO Items (Name, Description, Price) VALUES (@name, @address, @phone)',
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
