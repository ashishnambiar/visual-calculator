import 'package:flutter/painting.dart';
import 'package:visual_calculator/RenderNodes/single_render_node.dart';

class SingleRenderNodeGroup {
  List<SingleRenderNode> nodes;
  List<RenderNodeConnection> connections = [];
  SingleRenderNodeGroup({
    required this.nodes,
  });

  bool isHeld = false;
  bool isTurnstileHeld = false;
  bool connectionPending = false;

  void addNodes(List<SingleRenderNode> nodes) => nodes.addAll(nodes);

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

  bool dropAllHeld() {
    if (!isHeld && !isTurnstileHeld) return false;
    isTurnstileHeld = false;
    isHeld = false;
    for (var thing in nodes) {
      thing.drop();
    }
    return true;
  }

  // update position of node or thread depending on the held item
  bool updatePosition(Offset position) {
    // check if turnstile is held
    // if true update thread position
    if (nodes.last.isTurnstileHeld) {
      Offset _pos = position;
      for (var node in nodes.reversed) {
        if (node.isTurnstileHeld) continue;
        if (node.rect.contains(position)) {
          _pos = nodes.last.holdingTurnstile == TurnstileSelected.output
              ? node.inputPosition
              : node.outputPosition;
          connectionPending = true;
          break;
        }
      }
      connectionPending = false;
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
}

class RenderNodeConnection {
  List<SingleRenderNode> output;
  SingleRenderNode input;
  RenderNodeConnection(this.output, this.input);
}
