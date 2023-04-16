import 'package:flutter/material.dart';

import 'RenderNodes/single_render_node.dart';

class SandBoxPainter extends CustomPainter {
  int unitSize;
  ValueNotifier<Offset> positionChanged;
  List<SingleRenderNode> thing;
  SandBoxPainter({
    required this.unitSize,
    required this.positionChanged,
    required this.thing,
  }) : super(repaint: positionChanged);

  paintOutterRect(Canvas canvas, Size size) {
    Paint _border = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(
        Rect.fromPoints(
          Offset(0, 0),
          Offset(size.width, size.height),
        ),
        _border);
  }

  paintGrid(Canvas canvas, Size size) {
    Paint _grid = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < size.height; i += unitSize) {
      canvas.drawLine(
          Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), _grid);
    }
    for (var i = 0; i < size.width; i += unitSize) {
      canvas.drawLine(
          Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), _grid);
    }
  }

  // constants
  Offset thingSize = Offset(100, 150);

  // other values
  Offset get pos {
    Rect r1 = Rect.fromPoints(
      Offset(0, 0) + Offset(unitSize.toDouble(), unitSize.toDouble()),
      Offset(500, 500) - Offset(unitSize.toDouble(), unitSize.toDouble()),
    );
    if (r1.overlaps(Rect.fromPoints(
        positionChanged.value, positionChanged.value + thingSize))) {
      return positionChanged.value;
    }
    return Offset.zero;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // print grid first as background
    paintGrid(canvas, size);
    paintOutterRect(canvas, size);

    // rest of painting operations
    // drawThing(
    // canvas,
    // rect: Rect.fromPoints(pos, pos + thingSize),
    // pos: pos,
    // );

    for (var t in thing) {
      t.drawNode(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
