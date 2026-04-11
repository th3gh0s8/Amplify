import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'YOU HAVE PUSHED THE BUTTON THIS MANY TIMES:',
              textAlign: TextAlign.center,
              style: TextStyle(letterSpacing: 1.2, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: Text(
                '$_counter',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        label: const Text('ADD'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
