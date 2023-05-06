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
            _buildQueryButton(context, 'Query 1'),
            _buildQueryButton(context, 'Query 2'),
            _buildQueryButton(context, 'Query 3'),
            _buildQueryButton(context, 'Query 4'),
            _buildQueryButton(context, 'Query 5'),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryButton(BuildContext context, String queryName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // Do something when the button is pressed
        },
        child: Text(queryName),
      ),
    );
  }
}
