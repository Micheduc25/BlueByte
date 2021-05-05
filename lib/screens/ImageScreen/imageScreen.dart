import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:new_bluebyte/components/infoGetter.dart';

import 'package:new_bluebyte/components/objectsPainter.dart';
import 'package:new_bluebyte/components/pointMode.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/models/newImageModel.dart';

import 'package:new_bluebyte/screens/SettingsScreen/settings_image.dart';

import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class ImageScreen extends StatefulWidget {
  ImageScreen(
      {this.imagePath,
      this.settings,
      this.objectId,
      this.moduleName,
      @required this.objectName,
      this.pointControllerState,
      this.image});
  final String imagePath;

  final AppSettings settings;
  final ObjectImage image;
  final String moduleName;
  final int objectId;
  final String objectName;
  final PointCollector pointControllerState;

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  bool showActions;
  PointMode pointMode;
  TextEditingController nameController;
  bool isFrench;

  PointCollector pointController;

  StreamSubscription<String> lineColorSubs;

  Color lineColor;

  StreamSubscription<double> lineWidthSubs;

  double lineWidth;

  StreamSubscription<String> bgColorSubs;

  Color backgroundColor;
  TextEditingController screenshotController;
  bool canExport;
  GlobalKey paintKey = new GlobalKey();

  @override
  void initState() {
    showActions = true;
    canExport = false;

    SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
        .then((_) {
      print("Orientation set ohh");
    });
    screenshotController = new TextEditingController(text: widget.image.name);
    isFrench = widget.settings.globalLanguage.getValue() == Config.fr;
    pointMode = PointMode.Length;
    nameController = new TextEditingController();
    pointController = widget.pointControllerState ??
        new PointCollector(
            pointMode, widget.image.imageId, isFrench, widget.settings,
            objectId: widget.objectId,
            objectName: widget.objectName,
            imagePath: widget.imagePath,
            image: widget.image,
            moduleName: widget.moduleName,
            widgetState: this);

    lineWidth = widget.settings.lineWidth.getValue();

    lineColor =
        AppColors.colorFromHexString(widget.settings.lineColor.getValue());
    backgroundColor = AppColors.colorFromHexString(
        widget.settings.backgroundColor.getValue());

    lineWidthSubs = widget.settings.lineWidth.listen((value) {
      if (mounted)
        setState(() {
          lineWidth = value;
        });
    });
    lineColorSubs = widget.settings.lineColor.listen((val) async {
      if (mounted) {
        setState(() {
          lineColor = AppColors.colorFromHexString(val);
        });
      }
    });

    bgColorSubs = widget.settings.backgroundColor.listen((val) async {
      if (mounted) {
        setState(() {
          backgroundColor = AppColors.colorFromHexString(val);
        });
        print("bg color set to $val");
      }
    });

    Future.delayed(Duration.zero, () {
      pointController.loadPoints(context).then((_) {
        setState(() {
          print("points loaded oh");
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    lineWidthSubs.cancel();
    lineColorSubs.cancel();
    bgColorSubs.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = widget.settings.globalLanguage.getValue() == Config.fr;
    return RepaintBoundary(
      key: paintKey,
      child: Scaffold(
        // backgroundColor: AppColors.purpleNormal,
        resizeToAvoidBottomInset: false,

        body: SafeArea(
          top: canExport ? false : true,
          child: Center(
            child: GestureDetector(
              onDoubleTap: () async {
                setState(() {
                  showActions = !showActions;
                });
                // await removeLast();
              },
              child: Container(
                color: Colors.black, //can be modified later
                constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Hero(
                      tag: widget.image.name + widget.image.imageId.toString(),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain, //or contain
                      ),
                    ),
                    //here we put the widget which will contain all of our lines and angles

                    GestureDetector(
                      onTapDown: (tapDetails) async {
                        final position = tapDetails.localPosition;
                        await pointController.addPoint(
                            position, context, lineColor, backgroundColor,
                            lineWidth: lineWidth);
                        setState(() {
                          print("tapped");
                        });
                      },
                      child: ObjectsPainter(
                          context: context,
                          image: widget.image,
                          imagePath: widget.imagePath,
                          isFrench: isFrench,
                          moduleName: widget.moduleName,
                          objectId: widget.objectId,
                          objectName: widget.objectName,
                          pointControllerState: pointController,
                          settings: widget.settings,
                          state: this,
                          strokeWidth: lineWidth,
                          objectsToPaint: pointController.objectStackFinal),
                    ),
                    //canvas
                    showActions
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.5,
                                    ),
                                    padding: EdgeInsets.all(15),
                                    color:
                                        AppColors.purpleNormal.withOpacity(.5),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        widget.moduleName +
                                            "-" +
                                            widget.objectName +
                                            "-" +
                                            widget.image.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      PopupMenuButton(
                                          offset: Offset(100, 0),
                                          onSelected: (value) async {
                                            if (value == "export") {
                                              //implement export code here

                                              setState(() {
                                                showActions = false;
                                                canExport = true;
                                              });

                                              final filePath =
                                                  await takeScreenshot(context);
                                              setState(() {
                                                canExport = false;
                                              });
                                              if (filePath != null)
                                                await Share.shareFiles(
                                                    [filePath],
                                                    subject:
                                                        "${widget.moduleName} - ${widget.objectName} - ${widget.image.name}",
                                                    text:
                                                        "bluebyte export: ${widget.moduleName}/${widget.objectName}/${widget.image.name}");
                                            } else if (value == "list") {
                                              Navigator.of(context).pop();
                                            } else if (value == "settings") {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ImageSettingsScreen(
                                                            settings:
                                                                widget.settings,
                                                          )));
                                            }
                                          },
                                          icon: Icon(Icons.more_vert,
                                              color: Colors.white, size: 35),
                                          itemBuilder: (context) => [
                                                PopupMenuItem(
                                                    value: "export",
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons.share,
                                                        color: AppColors
                                                            .purpleNormal,
                                                      ),
                                                      title: Text(
                                                          Languages.export[
                                                              isFrench
                                                                  ? Config.fr
                                                                  : Config.en],
                                                          style: Styles
                                                              .purpleTextNormal),
                                                    )),
                                                PopupMenuItem(
                                                    value: "list",
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons.image,
                                                        color: AppColors
                                                            .purpleNormal,
                                                      ),
                                                      title: Text(
                                                          Languages.imageList[
                                                              isFrench
                                                                  ? Config.fr
                                                                  : Config.en],
                                                          style: Styles
                                                              .purpleTextNormal),
                                                    )),
                                                PopupMenuItem(
                                                    value: "settings",
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons.settings,
                                                        color: AppColors
                                                            .purpleNormal,
                                                      ),
                                                      title: Text(
                                                          Languages.settings[
                                                              isFrench
                                                                  ? Config.fr
                                                                  : Config.en],
                                                          style: Styles
                                                              .purpleTextNormal),
                                                    ))
                                              ]),
                                      actionWidget(
                                          iconSize: 25,
                                          label: Languages.undo[
                                              isFrench ? Config.fr : Config.en],
                                          icon: Icons.undo,
                                          iconColor: pointController
                                                      .numberOfAddedItems >
                                                  0
                                              ? Colors.red
                                              : Colors.grey,
                                          orderVertical: false,
                                          onPressed: () async {
                                            if (pointController
                                                    .numberOfAddedItems >
                                                0)
                                              await removeLast();
                                            else {
                                              print("no recent change oh");
                                            }
                                          }),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  actionWidget(
                                      orderVertical: true,
                                      label: pointMode == PointMode.Length
                                          ? Languages.length[
                                              isFrench ? Config.fr : Config.en]
                                          : "Angle",
                                      icon: pointMode == PointMode.Angle
                                          ? Icons.panorama_wide_angle
                                          : Icons.linear_scale,
                                      onPressed: () {
                                        if (pointMode == PointMode.Length) {
                                          pointController
                                              .setPointMode(PointMode.Angle);
                                          setState(() {
                                            pointMode = PointMode.Angle;
                                          });
                                        } else {
                                          pointController
                                              .setPointMode(PointMode.Length);
                                          setState(() {
                                            pointMode = PointMode.Length;
                                          });
                                        }
                                      }),
                                  actionWidget(
                                      label: Languages.newImage[
                                          isFrench ? Config.fr : Config.en],
                                      icon: Icons.add,
                                      onPressed: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                                child: InfoGetter(
                                                    context: context,
                                                    isFrench: isFrench,
                                                    lang: widget
                                                        .settings.globalLanguage
                                                        .getValue(),
                                                    nameController:
                                                        nameController,
                                                    widgetSettings:
                                                        widget.settings,
                                                    moduleName:
                                                        widget.moduleName,
                                                    objectId: widget.objectId,
                                                    objectName:
                                                        widget.objectName,
                                                    fromImageScreen: true)));
                                      })
                                ],
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> removeLast() async {
    //change this to objects screen
    if (pointController.objectStackFinal.length > 0 &&
        pointController.lastAddedPointType != null) {
      if (pointController.counter == 0) {
        //we have an already drawn line in this case
        //we remove this line's points from the database
        await DbOperations.deleteLastRow(
            pointController.lastAddedPointType == PointMode.Length
                ? Config.lengthpoints
                : Config.anglepoints,
            Config.pointsId);
      }
      pointController.removeLastItem();
      setState(() {
        print("last item successfuly removed");
      });
    }
  }

  Future<String> takeScreenshot(BuildContext context) async {
    Directory appDir = await getExternalStorageDirectory();

    final screenshotDir = await Directory(path.join(
            appDir.path, widget.moduleName, widget.objectName, "screenshots"))
        .create(recursive: true);

    final name = await showDialog<String>(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 300,
            child: AlertDialog(
              title: Text(
                Languages.saveAs[isFrench ? Config.fr : Config.en],
                style: Styles.purpleTextLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: screenshotController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (text) {
                        if (text != '' && text != null)
                          Navigator.of(context).pop(text);
                        else
                          Navigator.of(context).pop(widget.image.name);
                      },
                      cursorColor: AppColors.purpleNormal,
                      decoration: InputDecoration(
                          hintText: widget.image.name,
                          hintStyle: Styles.purpleTextNormal,
                          border: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.purpleNormal)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.purpleNormal)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.purpleNormal, width: 3))),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  PurpleButton(
                    label: "OK",
                    onPressed: () {
                      //when ok is pressed we pop the dialog returning the name entered
                      if (screenshotController.text != '' &&
                          screenshotController.text != null)
                        Navigator.of(context).pop(screenshotController.text);
                      else
                        Navigator.of(context).pop(widget.image.name);
                    },
                  )
                ],
              ),
            ),
          );
        });

    print(name);

    //we now define the path of the image
    if (name != null) {
      //if the input has focus we remove the focus
      FocusScope.of(context).unfocus();

      final finalPath = path.join(screenshotDir.path, "$name.png");

      RenderRepaintBoundary boundary =
          paintKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      var byteData = await image.toByteData(format: ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();

      File imgFile = new File("$finalPath");
      imgFile.writeAsBytes(pngBytes);

      print(finalPath);

      return finalPath;
    } else
      return null;
  }

  Widget actionWidget(
      {String label,
      Function onPressed,
      IconData icon,
      Color iconColor = Colors.white,
      double iconSize = 30,
      bool orderVertical = false}) {
    return TextButton(
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(10)),
            backgroundColor: MaterialStateProperty.all(
                AppColors.purpleNormal.withOpacity(.5))),
        onPressed: onPressed,
        child: !orderVertical
            ? Row(
                children: <Widget>[
                  Icon(
                    icon,
                    color: iconColor,
                    size: 30,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    color: iconColor,
                    size: 30,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ));
  }
}
