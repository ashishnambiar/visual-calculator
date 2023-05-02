import 'dart:math';

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
      home: ColumnCalc(),
      //const MyHomePage(title: 'Flutter Demo Home Page'),
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
                  Expanded(child: RepaintBoundary(child: SandBox())),
                ],
              ),
            ),
    );
  }
}

class ColumnCalc extends StatefulWidget {
  ColumnCalc({Key? key}) : super(key: key);

  @override
  State<ColumnCalc> createState() => _ColumnCalcState();
}

class _ColumnCalcState extends State<ColumnCalc> {
  Stuff s = Stuff(
    things: [
      NodeThing(
        operation: Op.combine,
        contained: [5],
      ),
      NodeThing(
        operation: Op.combine,
        contained: [3, 10],
      ),
      NodeThing(operation: Op.sum),
      NodeThing(
        operation: Op.combine,
        contained: [3, 10],
      ),
      NodeThing(operation: Op.subtract),
    ],
  );

  addItem(Op operation) {
    setState(() {
      s.addNode(operation);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  final ScrollController _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => addItem(Op.combine),
            child: Icon(Icons.numbers),
          ),
          FloatingActionButton(
            onPressed: () => addItem(Op.sum),
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => addItem(Op.subtract),
            child: Icon(Icons.remove),
          ),
        ],
      ),
      appBar: AppBar(title: Text("Column Calculator")),
      body: SingleChildScrollView(
        controller: _scroll,
        child: s.widgetBuild(),
      ),
    );
  }
}

class Stuff {
  List<NodeThing> things;
  Stuff({
    required this.things,
  }) {
    calc();
  }
  List<double> get finalOutput => things.last.output;

  Widget widgetBuild() {
    return Column(
      children: [
        ...List.generate(things.length, (index) => things[index].widgtBuild()),
        Divider(
          thickness: 5,
        ),
        Text(
          "RESULT: $finalOutput",
          style: TextStyle(fontSize: 30),
        ),
      ],
    );
  }

  void addNode(Op operation) {
    if (operation == Op.combine) {
      things.add(
        NodeThing(
          operation: operation,
          contained: [(Random().nextDouble() * 20).roundToDouble()],
        ),
      );
    } else {
      things.add(NodeThing(operation: operation));
    }
    calc();
  }

  calc() {
    things[0].calc([]);
    for (var i = 1; i < things.length; i++) {
      things[i].calc(things[i - 1].output);
    }
  }
}

class NodeThing {
  List<double> input = [];
  List<double> output = [];
  List<double> contained;
  Op operation;
  NodeThing({
    required this.operation,
    this.contained = const [],
  }) {
    if (operation == Op.combine) assert(contained.isNotEmpty);
  }

  Widget widgtBuild() {
    return Text(
      "$input :: $contained :: $operation :: $output",
      style: TextStyle(fontSize: 30),
    );
  }

  calc(List<double> ins) {
    input = ins;
    print("$input , $operation ");
    switch (operation) {
      case Op.sum:
        if (input.isEmpty) break;
        output = [input[0]];
        for (int i = 1; i < input.length; i++) {
          output[0] = output[0] + input[i];
        }
        break;
      case Op.subtract:
        if (input.isEmpty) break;
        output = [input[0]];
        for (int i = 1; i < input.length; i++) {
          output[0] = output[0] - input[i];
        }
        break;
      case Op.combine:
        output = [
          ...input,
          ...contained,
        ];
        break;
    }
  }
}

enum Op {
  sum,
  subtract,
  combine,
}
