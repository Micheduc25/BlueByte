import 'package:new_bluebyte/components/objectStackItem.dart';
import 'package:new_bluebyte/components/pointMode.dart';
import 'package:new_bluebyte/models/newImageModel.dart';
import 'package:new_bluebyte/screens/ImageScreen/imageScreen.dart';
import 'package:new_bluebyte/utils/angleCalculator.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ObjectsPainter extends StatefulWidget {
  ObjectsPainter(
      {this.backgroundColor,
      @required this.strokeWidth,
      @required this.context,
      @required this.image,
      @required this.imagePath,
      @required this.isFrench,
      @required this.moduleName,
      @required this.objectId,
      @required this.objectName,
      @required this.pointControllerState,
      @required this.settings,
      @required this.state,
      @required this.objectsToPaint});
  final double strokeWidth;

  final bool isFrench;
  final State<StatefulWidget> state;
  final BuildContext context;
  final List<ObjectStackItem> objectsToPaint;

  final String imagePath;
  final AppSettings settings;
  final ObjectImage image;
  final String moduleName;
  final int objectId;
  final String objectName;
  final Color backgroundColor;
  final PointCollector pointControllerState;

  @override
  _ObjectsPainterState createState() => _ObjectsPainterState();
}

class _ObjectsPainterState extends State<ObjectsPainter> {
  @override
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        size: MediaQuery.of(context).size,
        painter: MyPainter(widget.pointControllerState.objectStack,
            backgroundColor: widget.backgroundColor,
            isFrench: widget.isFrench,
            state: widget.state,
            context: context,
            objectsToPaint: widget.objectsToPaint,
            imagePath: widget.imagePath,
            image: widget.image,
            objectId: widget.objectId,
            strokeWidth: widget.strokeWidth,
            moduleName: widget.moduleName,
            pointControllerState: widget.pointControllerState,
            objectName: widget.objectName,
            settings: widget.settings),
        child: Stack(
          children: widget.pointControllerState.objectStack,
        ));
  }
}

class MyPainter extends CustomPainter {
  MyPainter(
    this.actionsStackItems, {
    this.backgroundColor,
    this.strokeWidth,
    @required this.objectsToPaint,
    @required this.context,
    @required this.image,
    @required this.imagePath,
    @required this.isFrench,
    @required this.moduleName,
    @required this.objectId,
    @required this.objectName,
    @required this.pointControllerState,
    @required this.settings,
    @required this.state,
  }) {
    // this.objectsToPaint = this.pointControllerState.objectStackFinal;
  }

  List<ObjectStackItem> objectsToPaint;

  double strokeWidth;
  List<Widget> actionsStackItems;
  final bool isFrench;
  final State<StatefulWidget> state;
  final BuildContext context;

  final String imagePath;
  final AppSettings settings;
  final ObjectImage image;
  final String moduleName;
  final int objectId;
  final String objectName;
  final Color backgroundColor;
  final PointCollector pointControllerState;

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    if (objectsToPaint.isNotEmpty) if (objectsToPaint.last.newObject)
      return true;
    return false;
    // return oldDelegate.objectsToPaint != this.objectsToPaint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = ui.PointMode.polygon;

    objectsToPaint.forEach((object) {
      if (object.objectType == ObjectStackItemType.Line) {
        final paint = Paint()
          ..color = AppColors.colorFromHexString(object.lineObject.color) ??
              AppColors.purpleNormal
          ..strokeWidth = object.lineObject.width ?? strokeWidth ?? 3
          ..style = PaintingStyle.stroke;

        final circlePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = AppColors.colorFromHexString(object.lineObject.color) ??
              AppColors.purpleNormal;
        final firstPoint = Offset(
            object.lineObject.firstpointX, object.lineObject.firstpointY);
        final secondPoint = Offset(
            object.lineObject.secondpointX, object.lineObject.secondpointY);
        canvas.drawLine(firstPoint, secondPoint, paint);
        canvas.drawCircle(firstPoint, object.lineObject.width + 1, circlePaint);

        canvas.drawCircle(
            secondPoint, object.lineObject.width + 1, circlePaint);

        if (!object.actionAdded) {
          actionsStackItems.add(Positioned(
            top: midPoint(firstPoint, secondPoint).dy - 10,
            left: midPoint(firstPoint, secondPoint).dx - 10,
            child: InkWell(
                onTap: () {
                  print("line  was pressed");
                },
                onLongPress: () async {
                  var result = await showDialog(
                      context: context,
                      builder: (context) {
                        return new EditDialog(context,
                            pointType: PointMode.Length,
                            isFrench: isFrench,
                            anglePoints: null,
                            controller: pointControllerState,
                            lengthPoints: object.lineObject,
                            settings: settings,
                            state: state,
                            lineOrAngleId: object.lineObject.pointsId);
                      });
                  print("result is $result");
                  if (result != null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ImageScreen(
                              objectName: objectName,
                              objectId: objectId,
                              pointControllerState: this.pointControllerState,
                              image: image,
                              imagePath: imagePath,
                              settings: settings,
                              moduleName: moduleName,
                            )));
                  }
                },
                child: Text(
                  object.lineObject.length.toString() +
                          object.lineObject.unit ??
                      "value",
                  style: TextStyle(
                      backgroundColor: AppColors.colorFromHexString(
                              object.lineObject.backgroundColor) ??
                          AppColors.purpleNormal.withOpacity(.6)),
                )),
          ));

          object.actionAdded = true;
        }

        if (object.newObject) {
          Future.delayed(Duration.zero, () {
            if (state.mounted)
              state.setState(() {
                print("dangerous try oh");
              });

            object.newObject = false;
          });
        }
      } else if (object.objectType == ObjectStackItemType.Angle) {
        final firstPoint = Offset(
            object.angleObject.firstpointX, object.angleObject.firstpointY);
        final secondPoint = Offset(
            object.angleObject.secondpointX, object.angleObject.secondpointY);
        final thirdPoint = Offset(
            object.angleObject.thirdpointX, object.angleObject.thirdpointY);

        final paint = Paint()
          ..color = AppColors.colorFromHexString(object.angleObject.color) ??
              AppColors.purpleNormal
          ..strokeWidth = object.angleObject.width ?? strokeWidth
          ..style = PaintingStyle.stroke;

        final circlePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = AppColors.colorFromHexString(object.angleObject.color) ??
              AppColors.purpleNormal;

        canvas.drawPoints(
            pointMode, [firstPoint, secondPoint, thirdPoint], paint);

        canvas.drawCircle(
            firstPoint, object.angleObject.width + 1, circlePaint);

        canvas.drawCircle(
            secondPoint, object.angleObject.width + 1, circlePaint);

        canvas.drawCircle(
            thirdPoint, object.angleObject.width + 1, circlePaint);

        if (!object.actionAdded) {
          actionsStackItems.add(Positioned(
            top: midPoint(firstPoint, thirdPoint).dy - 10,
            left: midPoint(firstPoint, thirdPoint).dx - 10,
            child: InkWell(
                onTap: () {
                  print("line  was pressed");
                },
                onLongPress: () async {
                  //implement angle edit dialog here

                  var result = await showDialog(
                      context: context,
                      builder: (context) {
                        return new EditDialog(context,
                            pointType: PointMode.Angle,
                            isFrench: isFrench,
                            anglePoints: object.angleObject,
                            controller: pointControllerState,
                            lengthPoints: null,
                            settings: settings,
                            state: state,
                            lineOrAngleId: object.angleObject.pointsId);
                      });
                  // print("result is $result");
                  if (result != null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ImageScreen(
                              objectName: objectName,
                              objectId: objectId,
                              pointControllerState: this.pointControllerState,
                              image: image,
                              imagePath: imagePath,
                              settings: settings,
                              moduleName: moduleName,
                            )));
                  }
                },
                child: Text(
                  object.angleObject.angle.toString() + "°" ?? "value",
                  style: TextStyle(
                      backgroundColor: AppColors.colorFromHexString(
                              object.angleObject.backgroundColor) ??
                          AppColors.purpleNormal.withOpacity(.6)),
                )),
          ));

          object.actionAdded = true;
        }
        if (object.newObject) {
          Future.delayed(Duration.zero, () {
            if (state.mounted)
              state.setState(() {
                print("dangerous try oh");
              });

            object.newObject = false;
          });
        }
      } else if (object.objectType == ObjectStackItemType.Dot) {
        final circlePaint = Paint()
          ..style = PaintingStyle.fill
          ..color =
              AppColors.colorFromHexString(settings.lineColor.getValue()) ??
                  AppColors.purpleNormal;

        canvas.drawCircle(object.dotOffset, strokeWidth + 1, circlePaint);
        print("circle drawn");
      }
    });
  }
}
