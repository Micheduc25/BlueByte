import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:flutter/material.dart';
// import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vector;

class MovingHand extends StatefulWidget {
  MovingHand(
      {this.play = true,
      @required this.initialPosition,
      @required this.finalPosition,
      this.rotationAngle = 0});

  final bool play;
  final Offset initialPosition;
  final Offset finalPosition;
  final double rotationAngle;
  @override
  _MovingHandState createState() => _MovingHandState();
}

class _MovingHandState extends State<MovingHand>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    if (widget.play) _animationController.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.initialPosition.dx,
      top: widget.initialPosition.dy,
      child: Transform(
        transform: Matrix4.translation(vector.Vector3(
            _animationController.value * widget.finalPosition.dx,
            _animationController.value * widget.finalPosition.dy,
            0)),
        child: Transform.rotate(
            angle: widget.rotationAngle,
            child: Container(
                color: AppColors.purpleNormal.withOpacity(.3),
                child: Icon(Icons.touch_app, size: 40))),
      ),
    );
  }
}
