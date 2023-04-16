import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class CanvasArea extends StatelessWidget {
  CanvasArea({Key? key}) : super(key: key);

  ValueNotifier<Offset> currentPosition = ValueNotifier(Offset(0, 0));
  List<List<Offset>> lines = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        lines.add([]);
        lines.last.add(details.localPosition);
        currentPosition.value = details.localPosition;
      },
      onPanUpdate: (details) {
        var loc = details.localPosition;

        lines.last.last = Offset(
          loc.dx.clamp(0, 500),
          loc.dy.clamp(0, 500),
        );
        lines.last.add(
          Offset(
            loc.dx.clamp(0, 500),
            loc.dy.clamp(0, 500),
          ),
        );
        currentPosition.value = details.localPosition;
      },
      child: Container(
        height: 500,
        width: 500,
        child: CustomPaint(
          painter: CanvasPainter(
            offset: currentPosition,
            lines: lines,
          ),
        ),
      ),
    );
  }
}

class CanvasPainter extends CustomPainter {
  ValueNotifier<Offset> offset;
  List<List<Offset>> lines;
  CanvasPainter({
    required this.offset,
    required this.lines,
  }) : super(repaint: offset);

  @override
  void paint(Canvas canvas, Size size) {
    var line = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    var point = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2;
    var point1 = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    var _paint = Paint()..color = Colors.blue;
    int unitsize = 50;
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width,
          height: size.height),
      line,
    );

    for (var i = 0; i < size.height / unitsize; i++) {
      canvas.drawLine(Offset(0, (i * unitsize).toDouble()),
          Offset(size.width, (i * unitsize).toDouble()), line);
      canvas.drawLine(Offset((i * unitsize).toDouble(), 0),
          Offset((i * unitsize).toDouble(), size.height), line);
    }

    for (var l in lines) {
      Path p = Path();
      p.moveTo(l[0].dx, l[0].dy);
      for (var i = 1; i < l.length - 1; i = i + 1) {
        canvas.drawLine(l[i], l[i + 1], point);
      }
      canvas.drawPath(p, point1);
    }

    int count = 10;
    List<Offset> star = List.generate(count, (index) {
      double m = 2 * pi / count;
      return Offset(cos(m * index), sin(m * index)) *
          (index % 2 == 0 ? 50 : 25);
    });

    Offset starC = Offset(200, 200);

    List<Offset> vs = [
      starC,
      ...star.map((e) => e + starC).toList(),
    ];

    List<int> inds = [];
    for (var i = 1; i <= star.length; i++) {
      inds.addAll([0, i, (i % star.length) + 1]);
    }

    canvas.drawVertices(
      Vertices(
        VertexMode.triangles,
        vs,
        indices: inds,
      ),
      BlendMode.dst,
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
