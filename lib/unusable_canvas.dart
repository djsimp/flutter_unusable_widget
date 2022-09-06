import 'package:flutter/material.dart';
import 'canvas_slider.dart';


class UnusableCanvas extends StatefulWidget {
  UnusableCanvas();
  @override
  _UnusableCanvasState createState() => _UnusableCanvasState();
}

typedef ValueChangedCallback = void Function(List newValues);

class _UnusableCanvasState extends State<UnusableCanvas> {
  List<DrawPoint> _drawPoints;
  Color _color;
  double _radius;
  bool _active;
  double _canvasHeight = 400;
  double _canvasWidth = 400;

  @override
  initState() {
    super.initState();
    _drawPoints = [];
    _color = Color.fromRGBO(0, 0, 0, 1.0);
    _radius = 1;
    _active = false;
  }

  void addPoint(event) {
    _drawPoints.add(new DrawPoint(
        event.localPosition,
        _color,_radius));
  }

  void addNullPoint(event) {
    _drawPoints.add(null);
  }

  void updateDrawValues(values) {
    _color = Color.fromRGBO(values[0].round(), values[1].round(), values[2].round(), values[3]);
    _radius = values[4];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget> [
          Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent;
            child: Listener(
              onPointerDown: addPoint,
              onPointerMove: addPoint,
              onPointerUp: addNullPoint,
              child: Container(
                height: _canvasHeight,
                width: _canvasWidth,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black
                  )
                ),
                child: CustomPaint(
                  painter: _MyCanvasPainter(_drawPoints, _active),
                ),
              ),
            ),
          ),
          Listener(
            child: MaterialButton(
              onPressed: () => setState(() => _active = true),
              child: Text("Preview")
            )
          ),
          CanvasSlider(
            onValueChanged: (List values) {
               updateDrawValues(values);
               setState(() => _active = false);
            }
          )
        ]
    );
  }
}

class _MyCanvasPainter extends CustomPainter {
  List<DrawPoint> _points;
  bool _active;

  _MyCanvasPainter(List<DrawPoint> points, bool active) {
    _points = points;
    _active = active;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if(_active && _points.length > 0) {
      final startPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = _points[0].color;
      canvas.drawCircle(
          _points[0].position,
          _points[0].radius,
          startPaint
      );
      for(var i = 1; i < _points.length; i++) {
        if(_points[i] != null) {
          if(_points[i-1] != null) {
            final linePaint = Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = _points[i].radius * 2
              ..color = _points[i].color;
            canvas.drawLine(
                _points[i - 1].position,
                _points[i].position,
                linePaint
            );
          }
          final paint = Paint()
            ..style = PaintingStyle.fill
            ..color = _points[i].color;
          canvas.drawCircle(
              _points[i].position,
              _points[i].radius,
              paint
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DrawPoint {
  Offset position;
  Color color;
  double radius;

  DrawPoint(Offset mPosition, Color mColor, double mRadius) {
    position = mPosition;
    color = mColor;
    radius = mRadius;
  }
}