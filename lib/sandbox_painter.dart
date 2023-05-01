import 'package:flutter/material.dart';

import 'RenderNodes/single_render_node.dart';
import 'RenderNodes/single_render_node_group.dart';

class SandBoxPainter extends CustomPainter {
  int unitSize;
  ValueNotifier<Offset> positionChanged;
  List<SingleRenderNode> thing;
  RenderNodeConnections connections;
  SandBoxPainter({
    required this.unitSize,
    required this.positionChanged,
    required this.thing,
    required this.connections,
  }) : super(repaint: positionChanged);

  @override
  void paint(Canvas canvas, Size size) {
    /// print grid first as background
    paintGrid(canvas, size);
    paintOutterRect(canvas, size);

    /// rest of painting operations
    for (var t in thing) {
      t.drawNode(canvas);
    }

    connections.drawConnectedThreads(canvas);

    for (var t in thing) {
      if (t.isTurnstileHeld) {
        if (t.threadPosition == Offset.zero) break;
        Paint threadPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          t.turnstilePosition ?? t.threadPosition,
          // t.threadPosition == Offset.zero? positionChanged.value :
          t.threadPosition,
          threadPaint,
        );
      }
    }
  }

  paintOutterRect(Canvas canvas, Size size) {
    Paint border = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(
        Rect.fromPoints(
          Offset(0, 0),
          Offset(size.width, size.height),
        ),
        border);
  }

  paintGrid(Canvas canvas, Size size) {
    Paint grid = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < size.height; i += unitSize) {
      canvas.drawLine(
          Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), grid);
    }
    for (var i = 0; i < size.width; i += unitSize) {
      canvas.drawLine(
          Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), grid);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
