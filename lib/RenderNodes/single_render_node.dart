import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class SingleRenderNode {
  int get id => hashCode;

  double radius = 0;
  Offset size = const Offset(130, 130);
  Offset nodePosition = Offset.zero;
  Offset threadPosition = Offset.zero;
  bool holdingNode = false;
  Offset? holdOffset;
  Color? color;
  Rect get rect => Rect.fromPoints(nodePosition, nodePosition + size);

  // Turnstile information
  TurnstileSelected holdingTurnstile = TurnstileSelected.none;
  bool get isTurnstileHeld => holdingTurnstile != TurnstileSelected.none;
  Offset get inputPosition =>
      Offset(nodePosition.dx, nodePosition.dy + size.dy / 2);
  Offset get outputPosition =>
      Offset(nodePosition.dx + size.dx, nodePosition.dy + size.dy / 2);
  Rect get inputTurnstile => Rect.fromCircle(center: inputPosition, radius: 10);
  Rect get outputTurnstile =>
      Rect.fromCircle(center: outputPosition, radius: 10);
  Offset? get turnstilePosition {
    switch (holdingTurnstile) {
      case TurnstileSelected.none:
        return null;
      case TurnstileSelected.input:
        return inputPosition;
      case TurnstileSelected.output:
        return outputPosition;
    }
  }

  SingleRenderNode({
    this.color,
  });

  void drawNode(Canvas canvas) {
    Paint rectPaint = Paint()
      ..color = color ?? Colors.red // .withOpacity(0.8)
      ..style = PaintingStyle.fill;
    Paint pointPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;
    if (holdingNode) {
      Path path = Path()
        ..moveTo(nodePosition.dx, nodePosition.dy)
        ..lineTo((nodePosition.dx + size.dx), (nodePosition.dy))
        ..lineTo((nodePosition.dx + size.dx), (nodePosition.dy + size.dy))
        ..lineTo((nodePosition.dx), (nodePosition.dy + size.dy));
      canvas.drawShadow(path, Colors.blue, 10, true);
    }
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)), rectPaint);
    canvas.drawRect(inputTurnstile, pointPaint);
    canvas.drawRect(outputTurnstile, pointPaint);

    ParagraphBuilder parabuilder = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 1,
    ))
      ..addText(id.toString());
    final Paragraph para = parabuilder.build()
      ..layout(ParagraphConstraints(width: rect.width));
    canvas.drawParagraph(
        para,
        Offset(
            rect.center.dx - para.width / 2, rect.center.dy - para.height / 2));
  }

  void updateNodePosition(Offset position) {
    Offset pos = position - (holdOffset ?? Offset.zero);
    nodePosition =
        Offset(pos.dx.clamp(0, 700 - size.dx), pos.dy.clamp(0, 700 - size.dy));
  }

  void updateThreadPosition(Offset position) => threadPosition = position;

  bool clickedOnRect(Offset inside) => rect.contains(inside);

  TurnstileSelected clickedOnTurnstile(Offset inside) {
    if (inputTurnstile.contains(inside)) return TurnstileSelected.input;
    if (outputTurnstile.contains(inside)) return TurnstileSelected.output;
    return TurnstileSelected.none;
  }

  void hold(Offset click) {
    holdingTurnstile = clickedOnTurnstile(click);
    if (holdingTurnstile != TurnstileSelected.none) {
      return;
    }

    holdingNode = clickedOnRect(click);
    if (holdingNode) holdOffset = click - nodePosition;
  }

  void drop() {
    holdOffset = null;
    holdingNode = false;
    holdingTurnstile = TurnstileSelected.none;
    threadPosition = Offset.zero;
  }
}

enum TurnstileSelected { none, input, output }
