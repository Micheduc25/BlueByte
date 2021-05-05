import 'dart:async';

import 'package:new_bluebyte/components/pointMode.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:flutter/material.dart';

class DrawCanvas extends StatefulWidget {
  DrawCanvas({this.pointController, this.settings});

  final PointCollector pointController;
  final AppSettings settings;
  @override
  _DrawCanvasState createState() => _DrawCanvasState();
}

class _DrawCanvasState extends State<DrawCanvas> {
  StreamSubscription<String> lineColorSubs;
  StreamSubscription<String> bgColorSubs;
  Color lineColor;
  Color backgroundColor;
  @override
  void initState() {
    lineColor =
        AppColors.colorFromHexString(widget.settings.lineColor.getValue());
    lineColorSubs = widget.settings.lineColor.listen((val) {
      setState(() {
        lineColor = AppColors.colorFromHexString(val);
      });
    });

    bgColorSubs = widget.settings.backgroundColor.listen((val) {
      setState(() {
        backgroundColor = AppColors.colorFromHexString(val);
      });
    });
    Future.delayed(Duration.zero, () {
      widget.pointController.loadPoints(context).then((_) {
        setState(() {
          print("points loaded oh");
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    lineColorSubs.cancel();
    bgColorSubs.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (tapDetails) async {
        final position = tapDetails.localPosition;
        await widget.pointController
            .addPoint(position, context, lineColor, backgroundColor);
        setState(() {
          print("tapped");
        });
      },
      child: Container(
        child: Stack(
          fit: StackFit.expand,
          children: widget.pointController.objectStack,
        ),
      ),
    );
  }
}
