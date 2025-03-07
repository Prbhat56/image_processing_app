import 'dart:isolate';

import 'package:flutter/material.dart';

class IsolateExamplePage extends StatefulWidget {
  const IsolateExamplePage({super.key});

  @override
  _IsolateExamplePageState createState() => _IsolateExamplePageState();
}

class _IsolateExamplePageState extends State<IsolateExamplePage> {
  String _result = 'Press the button to start computation';

  Future<void> _startComputation() async {
    // Simulate a heavy computation (e.g., JSON parsing)
    setState(() {
      _result = 'Computing...';
    });

    // Use Isolate.run to offload the task
    final result = await Isolate.run(() {
      // Simulate a heavy computation
      final jsonData = '{"name": "John", "age": 30}';
      final parsedData = _parseJson(jsonData);
      return parsedData;
    });

    // Update the UI with the result
    setState(() {
      _result = 'Result: $result';
    });
  }

  // Simulate JSON parsing
  Map<String, dynamic> _parseJson(String jsonString) {
    // Simulate a time-consuming task
    for (var i = 0; i < 100000000; i++) {} // Dummy loop
    return {'name': 'John', 'age': 30};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Isolate.run Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startComputation,
              child: Text('Start Computation'),
            ),
          ],
        ),
      ),
    );
  }
}