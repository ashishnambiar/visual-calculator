import 'dart:math';

import 'package:flutter/material.dart';
import 'package:visual_calculator/RenderNodes/single_render_node_group.dart';
import 'package:visual_calculator/sandbox_painter.dart';

import 'RenderNodes/single_render_node.dart';

class SandBox extends StatefulWidget {
  SandBox({Key? key}) : super(key: key);

  @override
  State<SandBox> createState() => _SandBoxState();
}

class _SandBoxState extends State<SandBox> {
  ValueNotifier<Offset> pos = ValueNotifier(Offset(0, 0));
  // SingleNode thing = SingleNode();

  SingleRenderNodeGroup nodeGroup = SingleRenderNodeGroup(
    nodes: List.generate(
      4,
      (index) => SingleRenderNode(
        color: Color.fromARGB(
          255,
          Random().nextInt(255),
          Random().nextInt(255),
          Random().nextInt(255),
        ),
      ),
    ),
  );

  final TransformationController _controller = TransformationController();
  double dx = 0;
  double dy = 0;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      onInteractionUpdate: (details) {
        // print(_controller.value);
      },
      child: GestureDetector(
        onTap: () {
          _controller.value = Matrix4.identity();
        },
        onPanStart: (details) {
          if (nodeGroup.checkIfHeld(details.localPosition)) {
            pos.value = details.localPosition;
          }
        },
        onPanUpdate: (details) {
          pos.value = details.localPosition;

          /// update node position
          /// if node position updated then ignore InteractiveViewer transformations
          if (nodeGroup.updatePosition(pos.value)) return;
          panByDelta(details.delta);
        },
        onPanEnd: (details) {
          nodeGroup.dropAllHeld();
          pos.value = Offset.zero;
        },
        child: SizedBox(
          width: 700,
          height: 700,
          child: CustomPaint(
            size: Size(700, 700),
            painter: SandBoxPainter(
              unitSize: 50,
              positionChanged: pos,
              thing: nodeGroup.nodes,
            ),
          ),
        ),
      ),
    );
  }

  panByDelta(Offset delta) {
    Matrix4 mat4 = _controller.value;
    double max = -(700 * mat4[0]) + 700;
    mat4[12] = mat4[12] + (delta.dx * mat4[0]);
    if (mat4.getTranslation().x > 0) mat4[12] = 0;
    if (mat4.getTranslation().x < max) mat4[12] = max;
    mat4[13] = mat4[13] + (delta.dy * mat4[0]);
    if (mat4.getTranslation().y > 0) mat4[13] = 0;
    if (mat4.getTranslation().y < max) mat4[13] = max;
    _controller.value = mat4;
    _controller.notifyListeners();
    mat4 = mat4 + Matrix4.zero()
      ..translate(0, delta.dy);
  }
}
