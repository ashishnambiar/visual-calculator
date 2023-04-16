import 'dart:math';

import 'package:flutter/material.dart';

class SingleRenderNode {
  int get id => hashCode;
  double radius = 0;
  Offset size = const Offset(130, 130);
  Offset position = Offset.zero;
  bool holding = false;
  Offset? holdOffset;
  Color? color;
  Offset get inputPosition => Offset(position.dx, position.dy + size.dy / 2);
  Offset get outputPosition =>
      Offset(position.dx + size.dx, position.dy + size.dy / 2);
  Rect get rect => Rect.fromPoints(position, position + size);

  SingleRenderNode({
    this.color,
  });

  drawNode(Canvas canvas) {
    Paint rectPaint = Paint()
      ..color = this.color ?? Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    Paint pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    if (holding) {
      Path path = Path()
        ..moveTo(position.dx, position.dy)
        ..lineTo((position.dx + size.dx), (position.dy))
        ..lineTo((position.dx + size.dx), (position.dy + size.dy))
        ..lineTo((position.dx), (position.dy + size.dy));
      canvas.drawShadow(path, Colors.blue, 10, true);
    }
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)), rectPaint);
    canvas.drawArc(
      Rect.fromCircle(center: inputPosition, radius: 10),
      0,
      2 * pi,
      true,
      pointPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: outputPosition, radius: 10),
      0,
      2 * pi,
      true,
      pointPaint,
    );
  }

  updatePos(Offset position) {
    Offset pos = position - (holdOffset ?? Offset.zero);
    this.position =
        Offset(pos.dx.clamp(0, 700 - size.dx), pos.dy.clamp(0, 700 - size.dy));
  }

  bool clickedOnRect(Offset inside) => rect.contains(inside);
  hold(Offset click) {
    holding = clickedOnRect(click);
    if (holding) holdOffset = click - position;
  }

  drop() {
    holdOffset = null;
    holding = false;
  }
}
