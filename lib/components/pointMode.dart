import 'package:new_bluebyte/components/editView.dart';

import 'package:new_bluebyte/components/measurementDialog.dart';

import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/models/newImageModel.dart';
import 'package:new_bluebyte/models/pointsModel.dart';
import 'package:new_bluebyte/provider/editStream.dart';
import 'package:new_bluebyte/screens/ImageScreen/imageScreen.dart';
import 'package:new_bluebyte/utils/angleCalculator.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';

import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';

import 'package:flutter/material.dart';

import 'objectStackItem.dart';

enum PointMode {
  ///With this mode we measure lengths
  Length,

  ///With this mode we measure angles
  Angle
}

class PointCollector {
  PointCollector(this.pointMode, this.imageId, this.isFrench, this.settings,
      {@required this.objectId,
      @required this.objectName,
      @required this.image,
      @required this.imagePath,
      @required this.moduleName,
      @required this.editService,
      @required this.widgetState}) {
    this.counter = 0;
    this.points = [];
    this.objectStack = [];
    this.objectStackFinal = [];
    this.numberOfAddedItems = 0;
  }

  PointMode pointMode;
  PointMode lastAddedPointType;
  List<Offset> points;
  List<Widget> objectStack;
  List<ObjectStackItem> objectStackFinal;
  int imageId;
  bool isFrench;
  AppSettings settings;
  int counter;
  ImageScreenState widgetState;
  int numberOfAddedItems;
  final ObjectImage image;
  final String objectName;
  final String imagePath;
  final String moduleName;
  final int objectId;
  EditStreamService editService;

  ///This method sets the point mode to [newMode]
  ///if the mode is different from the current one its resets all the points we have
  setPointMode(PointMode newMode) {
    //if we move from one mode to the another we reset our points
    if (this.pointMode != newMode) {
      for (int i = 0; i < points.length; i++) {
        objectStackFinal.removeLast();
        print("last removed");
      }

      points = [];
      counter = 0;
      print("reinitialized");
    }
    pointMode = newMode;
  }

  Future<void> addPoint(
      Offset newPoint, BuildContext context, Color color, Color backgroundColor,
      {double lineWidth}) async {
    //if we are in the length mode and we have less than two points we can add another point
    if (pointMode == PointMode.Length) {
      counter++;

      if (this.counter == 1) {
        points.add(newPoint);
        objectStackFinal.add(new ObjectStackItem(
            actionAdded: true,
            newObject: true,
            objectType: ObjectStackItemType.Dot,
            dotOffset: newPoint));

        if (this.lastAddedPointType != PointMode.Length)
          this.lastAddedPointType = PointMode.Length;
        numberOfAddedItems++;
      }

      //after adding the point if we have 2 points already, we remove the two circles at the top of the stack
      //and add a line object rather after getting the value from the dialog
      else if (this.counter == 2) {
        points.add(newPoint);
        //we simultaneously add a circle to our object Stack

        objectStackFinal.add(new ObjectStackItem(
            actionAdded: true,
            newObject: true,
            objectType: ObjectStackItemType.Dot,
            dotOffset: newPoint));

        this.numberOfAddedItems++;
        String value;
        value = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                  shape: Border.all(
                    color: AppColors.purpleDark,
                    width: 10,
                  ),
                  content: MeasurementDialog(
                    myContext: context,
                    isFrench: isFrench,
                    unit: settings.preferedUnit.getValue() ?? "m",
                    pointMode: this.pointMode,
                  ),
                ));

        print("value is $value");

        if (value != null) {
          objectStackFinal.removeLast();
          this.numberOfAddedItems--;

          objectStackFinal.removeLast();
          this.numberOfAddedItems--;
          double val;
          try {
            val = double.parse(value);
          } catch (e) {
            val = 0;
          }

          await generateLine(context, val,
              color: color, backgroundColor: backgroundColor, width: lineWidth);

          this.numberOfAddedItems++;

          if (this.lastAddedPointType != PointMode.Length)
            this.lastAddedPointType = PointMode.Length;

          resetPoints();
        } else {
          //if no value was entered we just remove the point that was recently added
          points.removeLast();

          objectStackFinal.removeLast();
          this.numberOfAddedItems--;
          counter--;
        }
      }
    } else if (pointMode == PointMode.Angle) {
      counter++;

      if (counter == 1 || counter == 2) {
        points.add(newPoint);
        //we simultaneously add a circle to our object Stack

        objectStackFinal.add(new ObjectStackItem(
            actionAdded: false,
            newObject: true,
            objectType: ObjectStackItemType.Dot,
            dotOffset: newPoint));

        if (this.lastAddedPointType != PointMode.Angle)
          this.lastAddedPointType = PointMode.Angle;
        this.numberOfAddedItems++;
      }

      //after adding the point if we have 3 points already, we remove the two circles at the top of the stack
      //and add a line object rather after getting the value from the dialog
      else if (counter == 3) {
        points.add(newPoint);
        objectStackFinal.add(new ObjectStackItem(
            actionAdded: false,
            newObject: true,
            objectType: ObjectStackItemType.Dot,
            dotOffset: newPoint));

        this.numberOfAddedItems++;
        String value;
        value = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                  shape: Border.all(
                    color: AppColors.purpleDark,
                    width: 10,
                  ),
                  content: MeasurementDialog(
                    myContext: context,
                    isFrench: isFrench,
                    unit: settings.preferedUnit.getValue() ?? "°",
                    pointMode: this.pointMode,
                  ),
                ));

        print("value is $value");

        if (value != null) {
          this.numberOfAddedItems--;

          this.numberOfAddedItems--;

          this.numberOfAddedItems--;

          for (int i = 0; i < 3; i++) {
            this.objectStackFinal.removeLast();
          }
          double val;
          try {
            val = double.parse(value);
          } catch (e) {
            val = 0;
          }

          await generateAngle(context, val,
              color: color,
              backgroundColor: backgroundColor,
              width: lineWidth); //change this to generateAngle

          this.numberOfAddedItems++;

          if (this.lastAddedPointType != PointMode.Angle)
            this.lastAddedPointType = PointMode.Angle;

          resetPoints();
        } else {
          //if no value was entered we just remove the point that was recently added
          points.removeLast();

          objectStackFinal.removeLast();
          counter--;
          this.numberOfAddedItems--;
        }
      }
    }
  }

  /// if the list is not empty this method removes the last point added
  void removeLastPoint() {
    if (points.isNotEmpty) {
      points.removeLast();

      objectStackFinal.removeLast();
    } else
      print("no points to remove");
  }

  void removeLastItem() {
    if (objectStackFinal.isNotEmpty) //change this later

    {
      if (counter > 0) {
        points.removeLast();

        objectStackFinal.removeLast();
        counter--;
      } else if (counter == 0) {
        final removed = objectStack.removeLast();
        print('$removed was removed');
        objectStackFinal.removeLast();
      }

      this.numberOfAddedItems--;
    }
  }

  int get numberOfPoints => points.length;

  void editPoint(int index, Offset newValue) {
    if (index + 1 <= points.length)
      points.replaceRange(index, index + 1, [newValue]);
  }

  resetPoints() {
    print(points);

    // objectStack.removeRange(
    //     objectStack.length - points.length, objectStack.length);

    points = [];
    this.counter = 0;
  }

  get mode => pointMode;

  ///this method validates the currently drawn points and adds them to the database
  ///it returns a widget which has the line drawn on it
  Future<void> generateLine(BuildContext context, double length,
      {Color color, @required Color backgroundColor, double width}) async {
    if (points.length == 2 && pointMode == PointMode.Length) {
      var myLengthPoint = new LengthPoints(
          imageId: imageId,
          firstpointX: points[0].dx,
          firstpointY: points[0].dy,
          secondpointX: points[1].dx,
          secondpointY: points[1].dy,
          length: length,
          width: width,
          unit: settings.preferedUnit.getValue() ?? "m",
          backgroundColor: backgroundColor.toString(),
          color: color.toString());
      await DbOperations.addLengthPoints(myLengthPoint);

      final lengthPoints =
          await DbOperations.getLastRow(Config.lengthpoints, Config.pointsId);

      final measurement = new LengthPoints.fromMap(lengthPoints);
      objectStackFinal.add(new ObjectStackItem(
          actionAdded: false,
          newObject: true,
          objectType: ObjectStackItemType.Line,
          lineObject: measurement));
    }
  }

  ///this method validates the currently drawn points and adds them to the database
  ///it returns a widget which has the line drawn on it
  Future<void> generateAngle(BuildContext context, double angle,
      {Color color, @required Color backgroundColor, double width}) async {
    if (points.length == 3 && pointMode == PointMode.Angle) {
      await DbOperations.addAnglePoints(new AnglePoints(
          imageId: imageId,
          firstpointX: points[0].dx,
          firstpointY: points[0].dy,
          secondpointX: points[1].dx,
          secondpointY: points[1].dy,
          thirdpointX: points[2].dx,
          thirdpointY: points[2].dy,
          angle: angle,
          width: width,
          backgroundColor: backgroundColor.toString(),
          unit: "°",
          color: color.toString()));

      final anglePoints =
          await DbOperations.getLastRow(Config.anglepoints, Config.pointsId);

      final measurement = new AnglePoints.fromMap(
          anglePoints); //get the angle id from this variable

      objectStackFinal.add(new ObjectStackItem(
          actionAdded: false,
          newObject: true,
          objectType: ObjectStackItemType.Angle,
          angleObject: measurement));
    } else {
      return Container();
    }
  }

  Widget generateDot({Color color = const Color(0xff000066), radius = 5}) {
    if (points.isNotEmpty) {
      if ((points.length <= 2 && pointMode == PointMode.Length)) {
        return Positioned(
          left: points[points.length == 1 ? 0 : 1].dx,
          top: points[points.length == 1 ? 0 : 1].dy,
          child: Container(
            padding: EdgeInsets.all(radius),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        );
      } else if ((points.length <= 3 && pointMode == PointMode.Angle)) {
        return Positioned(
          left: points[points.length == 1
                  ? 0
                  : points.length == 2
                      ? 1
                      : 2]
              .dx,
          top: points[points.length == 1
                  ? 0
                  : points.length == 2
                      ? 1
                      : 2]
              .dy,
          child: Container(
            padding: EdgeInsets.all(radius),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        );
      }
    }

    return Container();
  }

  Future<void> removeLine(List<Offset> points) async {
    //implement code to delete any line
  }

  Future<void> loadPoints(BuildContext context) async {
    final lengthPoints = await DbOperations.getLengthPoints(imageId);
    final anglePoints = await DbOperations.getAnglePoints(imageId);

    // print(
    //     "There are ${lengthPoints.length} length points and ${anglePoints.length} angle points");

    points = [];
    // objectStack = [];
    counter = 0;
    objectStack = [];
    objectStackFinal = [];

    if (lengthPoints != [])
      lengthPoints.forEach((measurement) {
        objectStackFinal.add(new ObjectStackItem(
            actionAdded: false,
            newObject: false,
            objectType: ObjectStackItemType.Line,
            lineObject: measurement));

        print(lengthPoints);
      });

    if (anglePoints != [])
      anglePoints.forEach((measurement) {
        objectStackFinal.add(new ObjectStackItem(
            actionAdded: false,
            newObject: false,
            objectType: ObjectStackItemType.Angle,
            angleObject: measurement));
      });

    objectStackFinal.forEach((object) {
      if (object.objectType == ObjectStackItemType.Line) {
        final firstPoint = Offset(
            object.lineObject.firstpointX, object.lineObject.firstpointY);
        final secondPoint = Offset(
            object.lineObject.secondpointX, object.lineObject.secondpointY);

        //we add the tapable text lable for the line
        objectStack.add(Positioned(
          top: midPoint(firstPoint, secondPoint).dy - 10,
          left: midPoint(firstPoint, secondPoint).dx - 10,
          child: InkWell(
              onTap: () {
                print("line  was pressed");
              },
              onLongPress: () {
                showDialog(
                    context: widgetState != null
                        ? widgetState.scaffoldKey.currentContext
                        : null,
                    builder: (context) {
                      return new EditDialog(
                          widgetState.scaffoldKey.currentContext,
                          pointType: PointMode.Length,
                          isFrench: isFrench,
                          anglePoints: null,
                          controller: this,
                          lengthPoints: object.lineObject,
                          settings: settings,
                          state: widgetState,
                          lineOrAngleId: object.lineObject.pointsId);
                    });
                // print("result is $result");
                // if (result != null) {
                //   //dialog successfully closed
                // }
              },
              child: Text(
                object.lineObject.length.toString() + object.lineObject.unit ??
                    "value",
                style: TextStyle(
                    backgroundColor: AppColors.colorFromHexString(
                            object.lineObject.backgroundColor) ??
                        AppColors.purpleNormal.withOpacity(.6)),
              )),
        ));
      } else if (object.objectType == ObjectStackItemType.Angle) {
        final firstPoint = Offset(
            object.angleObject.firstpointX, object.angleObject.firstpointY);
        final secondPoint = Offset(
            object.angleObject.secondpointX, object.angleObject.secondpointY);
        final thirdPoint = Offset(
            object.angleObject.thirdpointX, object.angleObject.thirdpointY);

        Offset labMid1 = midPoint(firstPoint, thirdPoint);
        labMid1 = midPoint(secondPoint, labMid1);
        objectStack.add(Positioned(
          top: labMid1.dy,
          left: labMid1.dx,
          child: InkWell(
              onTap: () {
                print("angle  was pressed");
              },
              onLongPress: () {
                //implement angle edit dialog
                showDialog(
                    context: widgetState != null
                        ? widgetState.scaffoldKey.currentContext
                        : null,
                    builder: (context) {
                      return EditDialog(widgetState.scaffoldKey.currentContext,
                          pointType: PointMode.Angle,
                          isFrench: isFrench,
                          anglePoints: object.angleObject,
                          controller: this,
                          lengthPoints: null,
                          settings: settings,
                          state: widgetState,
                          lineOrAngleId: object.angleObject.pointsId);
                    });
              },
              child: Text(
                object.angleObject.angle.toString() + "°" ?? "value",
                style: TextStyle(
                    backgroundColor: AppColors.colorFromHexString(
                            object.angleObject.backgroundColor) ??
                        AppColors.purpleNormal.withOpacity(.6)),
              )),
        ));
      }
    });
  }
}

///this defines how we want to edit the selected measurement
enum EditMode {
  ///This represents a simple edit mode for the measurements
  Edit,

  ///this represents the mode in which we can delete the measurement
  Delete
}

class EditDialog extends StatefulWidget {
  const EditDialog(this.superContext,
      {Key key,
      @required this.isFrench,
      @required this.controller,
      @required this.state,
      @required this.settings,
      @required this.lengthPoints,
      @required this.anglePoints,
      @required this.pointType,
      @required this.lineOrAngleId})
      : super(key: key);

  final bool isFrench;
  final LengthPoints lengthPoints;
  final AnglePoints anglePoints;
  final int lineOrAngleId;
  final PointMode pointType;
  final State state;
  final BuildContext superContext;

  final AppSettings settings;

  final PointCollector controller;

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  EditMode mode;
  TextEditingController valueController;
  TextEditingController widthController;

  @override
  void initState() {
    // mode = EditMode.Edit;
    valueController = new TextEditingController(
        text: widget.pointType == PointMode.Length
            ? widget.lengthPoints.length.toString()
            : widget.anglePoints.angle.toString());
    widthController = new TextEditingController(
        text: widget.pointType == PointMode.Length
            ? widget.lengthPoints.width.toString()
            : widget.anglePoints.width.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (mode != EditMode.Edit) {
                        setState(() {
                          mode = EditMode.Edit;
                        });
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      color: AppColors.purpleNormal,
                      child: Text(
                        Languages.edit[widget.isFrench ? Config.fr : Config.en],
                        style: Styles.whiteTextLarge,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  color: Colors.white,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      //implement object delete here
                      if (mode != EditMode.Delete) {
                        setState(() {
                          mode = EditMode.Delete;
                        });
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      color: AppColors.purpleNormal,
                      child: Text(
                        Languages
                            .delete[widget.isFrench ? Config.fr : Config.en],
                        style: Styles.whiteTextLarge,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            mode == EditMode.Edit
                ? EditView(
                    widget: widget,
                    pointType: widget.pointType == PointMode.Length
                        ? PointMode.Length
                        : PointMode.Angle,
                    lineColor: AppColors.colorFromHexString(
                        widget.pointType == PointMode.Length
                            ? widget.lengthPoints.color
                            : widget.anglePoints.color),
                    superContext: context,
                    initialValue: widget.pointType == PointMode.Length
                        ? widget.lengthPoints.length.toString()
                        : widget.anglePoints.angle.toString(),
                    valueController: valueController,
                    initialWidth: widget.pointType == PointMode.Length
                        ? widget.lengthPoints.width.toString()
                        : widget.anglePoints.width.toString(),
                    widthController: widthController,
                    backgroundColor: AppColors.colorFromHexString(
                        widget.pointType == PointMode.Length
                            ? widget.lengthPoints.backgroundColor
                            : widget.anglePoints.backgroundColor))
                : mode == EditMode.Delete
                    ? deleteView(widget.pointType)
                    : Container()
          ],
        ),
      ),
    );
  }

  Widget deleteView(PointMode pointType) {
    return SingleChildScrollView(
      child: Container(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Text(
            widget.pointType == PointMode.Length
                ? Languages.deleteLine[widget.isFrench ? Config.fr : Config.en]
                : Languages
                    .deleteAngle[widget.isFrench ? Config.fr : Config.en],
            style: Styles.purpleTextNormal,
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PurpleButton(
                label: Languages.yes[widget.isFrench ? Config.fr : Config.en],
                onPressed: () async {
                  //implement line or angle deletion
                  await DbOperations.deletepoints(
                      pointType == PointMode.Length
                          ? Config.lengthpoints
                          : Config.anglepoints,
                      widget.lineOrAngleId);
                  widget.controller.numberOfAddedItems--;
                  await widget.controller.loadPoints(context);

                  if (widget.state.mounted) widget.state.setState(() {});
                  print("points deleted");
                  Navigator.of(context).pop(true);
                },
              ),
              SizedBox(width: 20),
              PurpleButton(
                label: Languages.no[widget.isFrench ? Config.fr : Config.en],
                onPressed: () {
                  setState(() {
                    mode = null;
                  });
                },
              )
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      )),
    );
  }
}
