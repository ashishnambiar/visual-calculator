import 'package:flutter/material.dart';
import 'package:visual_calculator/RenderNodes/single_render_node.dart';

class SingleRenderNodeGroup {
  List<SingleRenderNode> nodes;
  RenderNodeConnections connections = RenderNodeConnections();
  SingleRenderNodeGroup({
    required this.nodes,
  }) {
    connections.addNodes(nodes);
  }

  bool isHeld = false;
  bool isTurnstileHeld = false;
  IThreadConnector threadConnection =
      IThreadConnector(connectionPending: false, connectingNode: null);

  void addNodes(List<SingleRenderNode> nodes) {
    this.nodes.addAll(nodes);
    connections.addNodes(nodes);
  }

  void addNode(SingleRenderNode node) {
    nodes.add(node);
    connections.addNode(node);
  }

  bool checkIfHeld(Offset position) {
    for (var thing in nodes.reversed) {
      thing.hold(position);
      if (thing.holdingNode) {
        isHeld = true;

        /// holding node will be rendered on top
        nodes.removeWhere((element) => element.id == thing.id);
        nodes.add(thing);
        return true;
      }
      if (thing.holdingTurnstile != TurnstileSelected.none) {
        isTurnstileHeld = true;
        nodes.removeWhere((element) => element.id == thing.id);
        nodes.add(thing);
        return true;
      }
    }
    return false;
  }

  // update position of node or thread depending on the held item
  bool updatePosition(Offset position) {
    // check if turnstile is held
    // if true update thread position
    if (nodes.last.isTurnstileHeld) {
      Offset _pos = position;
      for (var node in nodes.reversed) {
        if (node.isTurnstileHeld) continue;
        threadConnection.connectionPending = false;
        threadConnection.connectingNode = null;
        if (node.rect.contains(position)) {
          _pos = nodes.last.holdingTurnstile == TurnstileSelected.output
              ? node.inputPosition
              : node.outputPosition;
          threadConnection.connectionPending = true;
          threadConnection.connectingNode = node;

          print("[${DateTime.now()}]ConnectionPending");
          break;
        }
      }
      nodes.last.updateThreadPosition(_pos);
      return true;
    }

    // check if node is held
    // if held then update position of node
    if (!isHeld) return false;
    if (nodes.last.holdingNode) {
      nodes.last.updateNodePosition(position);
      return true;
    }
    return false;
  }

  bool dropAllHeld() {
    if (!isHeld && !isTurnstileHeld) return false;
    if (threadConnection.connectionPending && nodes.last.isTurnstileHeld) {
      late SingleRenderNode input;
      late SingleRenderNode output;
      if (nodes.last.holdingTurnstile == TurnstileSelected.input) {
        input = nodes.last;
        output = threadConnection.connectingNode!;
      } else {
        input = threadConnection.connectingNode!;
        output = nodes.last;
      }
      connections.connect(input, output);
    }
    isTurnstileHeld = false;
    isHeld = false;
    for (var thing in nodes) {
      thing.drop();
    }
    return true;
  }
}

class RenderNodeConnections {
  Map<int, IConnections> connections = {};
  RenderNodeConnections();

  Paint threadPaint = Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round;

  void addNode(SingleRenderNode node) {
    if (connections.containsKey(node.id)) return;
    connections.addAll({
      node.id: IConnections(output: node, inputs: []),
    });
  }

  void addNodes(List<SingleRenderNode> nodes) {
    for (var node in nodes) {
      addNode(node);
    }
  }

  void connect(SingleRenderNode input, SingleRenderNode output) {
    final int id = output.id;
    print(connections);
    connections[id] = IConnections(output: connections[id]!.output, inputs: [
      // ...connections[output]!.inputs,
      input.id
    ]);
  }

  drawConnectedThreads(Canvas canvas) {
    for (var e in connections.keys) {
      final output = connections[e]!.output;
      for (var inp in connections[e]!.inputs) {
        final input = connections[inp]!.node;
        canvas.drawLine(
          input.inputPosition,
          output.outputPosition,
          threadPaint,
        );
      }
    }
  }

  // TODO: disconnect function to disconnect the connected thread

//   drawHangingThread(Canvas canvas) {
//     for (var key in connections.keys) {
//       try {
//         SingleRenderNode node = connections[key]!.output;
//
//         if (node.threadPosition == Offset.zero) return;
//         canvas.drawLine(
//           node.turnstilePosition ?? node.threadPosition,
//           node.threadPosition,
//           threadPaint,
//         );
//       } catch (e) {
//         log("Error At DrawNodes: $e");
//       }
//     }
//   }
}

class IConnections {
  List<int> inputs;
  SingleRenderNode output;
  IConnections({
    required this.output,
    required this.inputs,
  });
  SingleRenderNode get node => output;

  @override
  String toString() {
    return "\nInterface_Connection: {input: $inputs,output: $output}";
  }
}

class IThreadConnector {
  bool connectionPending;
  SingleRenderNode? connectingNode;
  IThreadConnector({
    required this.connectionPending,
    required this.connectingNode,
  });
}
