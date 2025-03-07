import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

class HeavyComputationPage extends StatefulWidget {
  const HeavyComputationPage({super.key});

  @override
  State<HeavyComputationPage> createState() => _HeavyComputationPageState();
}

class _HeavyComputationPageState extends State<HeavyComputationPage> {
  // Function to simulate a heavy computation
  double _performHeavyComputation() {
    const int n = 1000000000; // 1 billion
    double sum = 0;

    for (int i = 1; i <= n; i++) {
      sum += i; // Add each number to the sum
    }

    return sum;
  }

  // Function to run heavy computation with isolates
  Future<void> _runHeavyComputationWithIsolate() async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _heavyComputationInIsolate,
      receivePort.sendPort,
    );

    // Listen for the result from the isolate
    await for (var message in receivePort) {
      if (message is double) {
        print('Heavy computation result (with isolate): $message');
        break;
      }
    }
  }

  // Function to run heavy computation without isolates
  Future<void> _runHeavyComputationWithoutIsolate() async {
    final result = _performHeavyComputation();
    print('Heavy computation result (without isolate): $result');
  }

  // Function to run heavy computation in an isolate
  static void _heavyComputationInIsolate(SendPort sendPort) {
    const int n = 1000000000; // 1 billion
    double sum = 0;

    for (int i = 1; i <= n; i++) {
      sum += i; // Add each number to the sum
    }

    // Send the result back to the main thread
    sendPort.send(sum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heavy Computation Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular progress indicator (always running)
            const CircularProgressIndicator(),

            const SizedBox(height: 20),

            // Button for heavy computation with isolates
            ElevatedButton(
              onPressed: () async {
                await _runHeavyComputationWithIsolate();
              },
              child: const Text('Run Heavy Computation with Isolate'),
            ),

            const SizedBox(height: 10),

            // Button for heavy computation without isolates
            ElevatedButton(
              onPressed: () async {
                await _runHeavyComputationWithoutIsolate();
              },
              child: const Text('Run Heavy Computation without Isolate'),
            ),
          ],
        ),
      ),
    );
  }
}