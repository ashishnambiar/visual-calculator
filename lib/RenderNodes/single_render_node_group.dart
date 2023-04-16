import 'package:flutter/painting.dart';
import 'package:visual_calculator/RenderNodes/single_render_node.dart';

class SingleRenderNodeGroup {
  List<SingleRenderNode> nodes;
  List<RenderNodeConnection> connections = [];
  SingleRenderNodeGroup({
    required this.nodes,
  });

  bool isHeld = false;

  void addNodes(List<SingleRenderNode> nodes) => nodes.addAll(nodes);

  bool checkIfHeld(Offset position) {
    for (var thing in nodes.reversed) {
      thing.hold(position);
      print(
          "might have been clicked on: ${thing.id} : ${thing.clickedOnRect(position)}");
      if (thing.holding) {
        isHeld = true;
        nodes.removeWhere((element) => element.id == thing.id);
        nodes.add(thing);
        return true;
      }
    }
    return false;
  }

  bool dropAllHeld() {
    if (!isHeld) return false;
    isHeld = false;
    for (var thing in nodes) {
      thing.drop();
    }
    return true;
  }

  bool updatePosition(Offset position) {
    if (!isHeld) return false;
    for (var thing in nodes) {
      if (thing.holding) {
        thing.updatePos(position);
        return true;
      }
    }
    return false;
  }
}

class RenderNodeConnection {
  SingleRenderNode start;
  SingleRenderNode end;
  RenderNodeConnection(this.start, this.end);
}
