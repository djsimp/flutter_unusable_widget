import 'package:flutter/material.dart';
import 'math_util.dart';


class CanvasSlider extends StatefulWidget {
  CanvasSlider({ this.onValueChanged, this.onActivated, this.onDeactivated });
  final ValueChangedCallback onValueChanged;
  final VoidCallback onActivated;
  final VoidCallback onDeactivated;

  @override
  _CanvasSliderState createState() => _CanvasSliderState();
}

typedef ValueChangedCallback = void Function(List newValues);

class _CanvasSliderState extends State<CanvasSlider> {
  List _thumbs;
  static double _containerHeight = 100;
  static double _containerWidth = 400;
  Offset _sliderStart;
  Offset _sliderEnd;
  double _thumbRadius = 20;

  @override
  initState() {
    super.initState();
    _sliderStart = Offset(50, 50);
    _sliderEnd = Offset(350, 50);
    _thumbs = new List(5);
    _thumbs[0] = new Thumb(_thumbRadius, _sliderStart, 0, 255, _sliderStart, _sliderEnd); // R
    _thumbs[1] = new Thumb(_thumbRadius, _sliderStart, 0, 255, _sliderStart, _sliderEnd); // G
    _thumbs[2] = new Thumb(_thumbRadius, _sliderStart, 0, 255, _sliderStart, _sliderEnd); // B
    _thumbs[3] = new Thumb(_thumbRadius, _sliderEnd, 0, 1.0, _sliderStart, _sliderEnd); // A
    _thumbs[4] = new Thumb(_thumbRadius, _sliderStart, 1, 20, _sliderStart, _sliderEnd); // radius
  }

  void activateSlider(PointerDownEvent event) {
    for(var i = 0; i < _thumbs.length; i++) {
      if (_thumbs[i].didHitThumb(event.localPosition)) {
        setState(() {
          _thumbs[i].activate();
        });
        if (widget.onActivated != null) {
          widget.onActivated();
        }
        break;
      }
    }
  }

  void deactivateSlider(PointerUpEvent event) {
    for(var i = 0; i < _thumbs.length; i++) {
      if(_thumbs[i].isActive()) {
        setState(() {
          _thumbs[i].deactivate();
        });
        if (widget.onDeactivated != null) {
          widget.onDeactivated();
        }
      }
    }
  }

  Offset calculateNewSliderPosition(Offset position) {
    if(position.dx < _sliderStart.dx) {
      return _sliderStart;
    }
    if(position.dx > _sliderEnd.dx) {
      return _sliderEnd;
    }
    return Offset(position.dx, _sliderStart.dy);
  }

  void moveSlider(PointerMoveEvent event) {
    for(var i = 0; i < _thumbs.length; i++) {
      if (_thumbs[i].isActive()) {
        int oldSliderValue = _thumbs[i].getValue().round();
        Offset newPosition = calculateNewSliderPosition(event.localPosition);
        setState(() {
          _thumbs[i].moveThumb(newPosition);
        });
        if (_thumbs[i].getValue() != oldSliderValue && widget.onValueChanged != null) {
          widget.onValueChanged(getThumbValues());
        }
      }
    }
  }

  List getThumbValues() {
    List thumbValues = new List(_thumbs.length);
    for(var i = 0; i < _thumbs.length; i++) {
      thumbValues[i] = _thumbs[i].getValue();
    }
    return thumbValues;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget> [
          Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent;
            child: Listener(
              onPointerDown: activateSlider,
              onPointerMove: moveSlider,
              onPointerUp: deactivateSlider,
              child: Container(
                height: _containerHeight,
                width: _containerWidth,
                color: Color.fromRGBO(230, 230, 230, 1.0),
                child: CustomPaint(
                  painter: _MySliderPainter(_thumbs, _thumbRadius, _sliderStart, _sliderEnd),
                ),
              ),
            ),
          ),
        ]
    );
  }
}

class _MySliderPainter extends CustomPainter {
  List _thumbs;
  double _thumbRadius;
  Offset _sliderStartOffset;
  Offset _sliderEndOffset;

  _MySliderPainter(List thumbs, double thumbRadius, Offset sliderStartOffset, Offset sliderEndOffset) {
    _thumbs = thumbs;
    _thumbRadius = thumbRadius;
    _sliderStartOffset = sliderStartOffset;
    _sliderEndOffset = sliderEndOffset;
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawSlider(canvas);
    drawThumbs(canvas);
  }

  void drawSlider(Canvas canvas) {
    final sliderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    final sliderEndsPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(0, 0, 0, 1.0);
    canvas.drawLine(_sliderStartOffset,_sliderEndOffset,sliderPaint);
    canvas.drawCircle(_sliderStartOffset, 5, sliderEndsPaint);
    canvas.drawCircle(_sliderEndOffset, 5, sliderEndsPaint);
  }

  void drawThumbs(Canvas canvas) {
    for (int i = 0; i < _thumbs.length; i++) {
      if(!_thumbs[i].isActive()) {
        drawSimpleThumb(canvas, _thumbs[i]);
      }
    }
  }

  void drawSimpleThumb(Canvas canvas, Thumb thumb) {
    final thumbPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(100, 100, 100, 1.0);
    canvas.drawCircle(thumb.getPosition(), _thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Thumb {
  Offset _sliderStart;
  Offset _sliderEnd;
  double _radius;
  Offset _position;
  bool _active;
  double _lowValue;
  double _highValue;

  Thumb(double radius, Offset position, double lowValue, double highValue, Offset sliderStart, Offset sliderEnd) {
    _radius = radius;
    _position = position;
    _active = false;
    _lowValue = lowValue;
    _highValue = highValue;
    _sliderStart = sliderStart;
    _sliderEnd = sliderEnd;
  }

  bool didHitThumb(Offset hit) {
    return MathUtil.distanceBetween(_position, hit) <= _radius;
  }

  bool isActive() {
    return _active;
  }

  void moveThumb(Offset point) {
    if(_active) {
      _position = point;
    }
  }

  Offset getPosition() {
    return _position;
  }

  double getValue() {
    return (MathUtil.interpolate(
        _position.dx - _sliderStart.dx,
        _sliderEnd.dx - _sliderStart.dx,
        _highValue - _lowValue
    ) + _lowValue);
  }

  double getLowValue() {
    return _lowValue;
  }

  double getHighValue() {
    return _highValue;
  }

  void activate() {
    _active = true;
  }

  void deactivate() {
    _active = false;
  }
}