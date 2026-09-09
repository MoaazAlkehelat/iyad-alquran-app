import 'package:flutter/widgets.dart';

/// Two-finger pinch that maps to a numeric [scale] (e.g. reading font scale),
/// implemented with a raw [Listener] so it never enters the gesture arena and
/// therefore never steals single-finger drags from a surrounding scroll view.
///
/// [onScalePreview] fires on every move frame with the live absolute scale;
/// keep the handler cheap (a compositor-only transform), not a relayout.
/// [onScaleCommit] fires once when the gesture ends, carrying the final scale —
/// that is the moment to apply the real (relayout-triggering) change.
class PinchToScale extends StatefulWidget {
  final double scale;
  final double min;
  final double max;
  final ValueChanged<double> onScalePreview;
  final ValueChanged<double> onScaleCommit;
  final Widget child;

  const PinchToScale({
    super.key,
    required this.scale,
    required this.onScalePreview,
    required this.onScaleCommit,
    required this.child,
    this.min = 0.8,
    this.max = 1.8,
  });

  @override
  State<PinchToScale> createState() => _PinchToScaleState();
}

class _PinchToScaleState extends State<PinchToScale> {
  final Map<int, Offset> _pointers = {};
  double? _baseDistance;
  double _baseScale = 1.0;
  double _lastScale = 1.0;
  bool _active = false;

  double get _distance {
    final pts = _pointers.values.toList();
    return (pts[0] - pts[1]).distance;
  }

  void _onDown(PointerDownEvent e) {
    _pointers[e.pointer] = e.position;
    if (_pointers.length == 2) {
      _baseDistance = _distance;
      _baseScale = widget.scale;
      _lastScale = widget.scale;
      _active = true;
    }
  }

  void _onMove(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) return;
    _pointers[e.pointer] = e.position;
    if (_active && _pointers.length == 2 && _baseDistance != null && _baseDistance! > 0) {
      final factor = _distance / _baseDistance!;
      final next = (_baseScale * factor).clamp(widget.min, widget.max);
      _lastScale = next;
      widget.onScalePreview(next);
    }
  }

  void _onUp(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_pointers.length < 2 && _active) {
      _active = false;
      _baseDistance = null;
      widget.onScaleCommit(_lastScale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onUp,
      child: widget.child,
    );
  }
}
