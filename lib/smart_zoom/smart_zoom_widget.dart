import 'package:flutter/material.dart';

import 'extension.dart';
import 'painter.dart';

class SmartZoomWidget extends StatefulWidget {
  final double maxZoom;
  final double minZoom;
  final Function(double value) onValueUpdate;
  const SmartZoomWidget({
    super.key,
    required this.onValueUpdate,
    required this.maxZoom,
    required this.minZoom,
  });

  @override
  State<SmartZoomWidget> createState() => _SmartZoomWidgetState();
}

class _SmartZoomWidgetState extends State<SmartZoomWidget> {
  double _zoom = 1.0;
  double _currentPosition = 0;
  late final _controller = ValueNotifier(_getZoomDegree(_zoom));
  late final _zoomValueController = ValueNotifier(_zoom);

  @override
  void dispose() {
    _controller.dispose();
    _zoomValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _size,
      child: Stack(
        children: [
          PositionedDirectional(
            bottom: -_size * .6,
            child: _buildCircle(context),
          ),
          Align(
            alignment: const Alignment(0, .25),
            child: _buildPointer(context),
          ),
          Align(
            alignment: const Alignment(0, .5),
            child: _buildCurrentZoomValue(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(BuildContext context) => GestureDetector(
        onHorizontalDragStart: (details) {
          _currentPosition = details.localPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          final def = details.localPosition.dx - _currentPosition;
          _currentPosition = details.localPosition.dx;
          _zoom = (_zoom - (def * _kZoomFactor)).clamp(widget.minZoom, widget.maxZoom);
          widget.onValueUpdate(_zoom);
          _zoomValueController.value = _zoom;
          _controller.value = _getZoomDegree(_zoom);
        },
        child: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, child) => Transform.rotate(angle: value, child: child),
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(.25),
            ),
            child: _paint(context),
          ),
        ),
      );

  Widget _paint(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: ValueListenableBuilder(
          valueListenable: _zoomValueController,
          builder: (context, value, child) => CustomPaint(
            painter: DialPainter(
              currentValue: value,
              color: Theme.of(context).colorScheme.surface,
              activeColor: Theme.of(context).colorScheme.primary,
              numbers: _numbers,
              valueBuilder: (value) => TextSpan(
                text: value.toString(),
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.surface),
              ),
            ),
          ),
        ),
      );

  Widget _buildPointer(BuildContext context) => Transform.rotate(
        angle: -.5,
        child: Icon(
          Icons.play_arrow_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      );

  Widget _buildCurrentZoomValue(BuildContext context) => ValueListenableBuilder(
        valueListenable: _zoomValueController,
        builder: (context, value, child) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${value.getCleanDouble()}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'x',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  double get _size => 300;
  double get _kZoomFactor => .01;

  double _getZoomDegree(double zoom) => -(_numbers.indexOf(_numbers.getNearestValue(_zoom)) * 2.5).toRadians();

  List<double> get _numbers {
    final isMinRounded = widget.minZoom.ceil() == widget.minZoom;
    final isMaxRounded = widget.maxZoom.floor() == widget.maxZoom;
    final length = ((widget.maxZoom.floor() - widget.minZoom.ceil()) * 10) + 1;
    double temp = widget.minZoom.ceilToDouble() - .1;
    final items = List.generate(length, (index) {
      final value = temp + .1;
      temp += .1;
      return value.getCleanDouble();
    });
    if (!isMinRounded) {
      final mLength = (widget.minZoom.ceil() - widget.minZoom) / .1;
      double start = widget.minZoom.ceilToDouble() - .1;
      for (int i = 0; i < mLength; i++) {
        items.insert(0, start.getCleanDouble());
        start -= .1;
      }
    }
    if (!isMaxRounded) {
      final mLength = (widget.maxZoom - widget.maxZoom.floor()) / .1;
      double start = widget.maxZoom.floorToDouble() + .1;
      for (int i = 0; i < mLength; i++) {
        items.add(start.getCleanDouble());
        start += .1;
      }
    }
    return items;
  }
}
