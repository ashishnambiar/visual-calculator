import 'package:flutter/material.dart';
import 'package:visual_calculator/hex_test.dart';
import 'package:visual_calculator/sandbox.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

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

  double scale = 0;
  double rotate = 0;

  TransformationController _t = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: false
          ? TransformationsDemo()
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  RepaintBoundary(child: SandBox()),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("button"),
                  ),
                ],
              ),
            ),
    );
  }
}
