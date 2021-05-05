import 'package:new_bluebyte/components/pointMode.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';

import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditView extends StatefulWidget {
  EditView(
      {Key key,
      @required this.widget,
      @required this.superContext,
      @required this.valueController,
      @required this.widthController,
      @required this.lineColor,
      @required this.backgroundColor,
      @required this.pointType,
      @required this.initialValue,
      @required this.initialWidth})
      : super(key: key);

  final EditDialog widget;
  final String initialValue;
  final String initialWidth;
  final TextEditingController valueController;
  final TextEditingController widthController;

  final Color lineColor;
  final Color backgroundColor;
  final BuildContext superContext;
  final PointMode pointType;

  @override
  _EditViewState createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  Color newLineColor;
  Color newBackgroundColor;
  @override
  void initState() {
    super.initState();
    newLineColor = widget.lineColor;
    newBackgroundColor = widget.backgroundColor;
  }

  @override
  void dispose() {
    // widget.valueController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Languages.value[widget.widget.isFrench ? Config.fr : Config.en],
                style: Styles.purpleTextNormal,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    // width: 150,
                    child: Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: TextField(
                        controller: widget.valueController,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        cursorColor: AppColors.purpleNormal,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3, color: AppColors.purpleDark)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2, color: AppColors.purpleDark)),
                            hintText: Languages.value[
                                widget.widget.isFrench ? Config.fr : Config.en],
                            hintStyle: TextStyle(
                              color: AppColors.purpleLight,
                              fontSize: 15,
                            )),
                      ),
                    ),
                  ),
                  Text(
                    widget.pointType == PointMode.Length
                        ? widget.widget.lengthPoints.unit
                        : "°",
                    style: Styles.purpleTextNormal,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(
            height: 10,
          ),
          //line width field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Languages
                    .lineSize[widget.widget.isFrench ? Config.fr : Config.en],
                style: Styles.purpleTextNormal,
              ),
              TextField(
                controller: widget.widthController,
                textAlign: TextAlign.center,
                cursorColor: AppColors.purpleNormal,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 3, color: AppColors.purpleDark)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 2, color: AppColors.purpleDark)),
                    hintText: Languages
                        .value[widget.widget.isFrench ? Config.fr : Config.en],
                    hintStyle: TextStyle(
                      color: AppColors.purpleLight,
                      fontSize: 15,
                    )),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            child: Row(
              children: <Widget>[
                Text(
                  Languages.lineColor[
                      widget.widget.isFrench ? Config.fr : Config.en],
                  style: Styles.purpleTextNormal,
                ),
                SizedBox(width: 10),
                Container(
                  width: 90,
                  height: 20,
                  color: newLineColor,
                )
              ],
            ),
            onTap: () async {
              Color color;

              await showDialog<Color>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(Languages.lineColor[
                          widget.widget.isFrench ? Config.fr : Config.en]),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                            // paletteType: PaletteType.rgb,
                            pickerColor: newLineColor ?? AppColors.purpleNormal,
                            pickerAreaHeightPercent: 0.8,
                            pickerAreaBorderRadius: BorderRadius.circular(5),
                            onColorChanged: (col) {
                              color = col;
                            }),
                      ),
                      actions: <Widget>[
                        PurpleButton(
                          label: "OK",
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });

              if (color != null)
                //do something with color
                newLineColor = color;
              setState(() {});

              print("color was set to $color");
            },
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            child: Row(
              children: <Widget>[
                Text(
                  Languages.backgroundColor[
                      widget.widget.isFrench ? Config.fr : Config.en],
                  style: Styles.purpleTextNormal,
                ),
                SizedBox(width: 10),
                Container(
                  width: 90,
                  height: 20,
                  color: newBackgroundColor,
                )
              ],
            ),
            onTap: () async {
              Color color;

              await showDialog<Color>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(Languages.backgroundColor[
                          widget.widget.isFrench ? Config.fr : Config.en]),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                            // paletteType: PaletteType.rgb,
                            pickerColor:
                                newBackgroundColor ?? AppColors.purpleNormal,
                            pickerAreaHeightPercent: 0.8,
                            pickerAreaBorderRadius: BorderRadius.circular(5),
                            onColorChanged: (col) {
                              color = col;
                            }),
                      ),
                      actions: <Widget>[
                        PurpleButton(
                          label: "OK",
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });

              if (color != null)
                //do something with color
                newBackgroundColor = color;
              setState(() {});

              print("color was set to $color");
            },
          ),
          SizedBox(
            height: 10,
          ),
          PurpleButton(
            label: "OK",
            onPressed: () async {
              //implement line edition function

              if (widget.valueController.text.isNotEmpty &&
                  widget.widthController.text.isNotEmpty) {
                //we check if the new value of the valuefield is valid
                var isValueValid = false;
                if (widget.initialValue != widget.valueController.text &&
                    double.tryParse(widget.valueController.text) != null) {
                  isValueValid = true;
                }

                //we check if the new value of the width field is valid
                var isWidthValid = false;
                if (widget.initialWidth != widget.widthController.text &&
                    double.tryParse(widget.widthController.text) != null) {
                  isWidthValid = true;
                }

                //then we update the data in the database
                if (isValueValid ||
                    isWidthValid ||
                    widget.lineColor != newLineColor ||
                    widget.backgroundColor != newBackgroundColor) {
                  await DbOperations.editPoints(
                      widget.pointType == PointMode.Length
                          ? Config.lengthpoints
                          : Config.anglepoints,
                      widget.widget.lineOrAngleId,
                      widget.pointType == PointMode.Length
                          ? {
                              Config.length: isValueValid
                                  ? widget.valueController.text
                                  : widget.initialValue,
                              Config.width: isWidthValid
                                  ? widget.widthController.text
                                  : widget.initialWidth,
                              Config.color: newLineColor.toString(),
                              Config.backgroundColor:
                                  newBackgroundColor.toString()
                            }
                          : {
                              Config.angle: isValueValid
                                  ? widget.valueController.text
                                  : widget.initialValue,
                              Config.width: isWidthValid
                                  ? widget.widthController.text
                                  : widget.initialWidth,
                              Config.color: newLineColor.toString(),
                              Config.backgroundColor:
                                  newBackgroundColor.toString()
                            });

                  widget.widget.controller.loadPoints(context);

                  if (widget.widget.state.mounted)
                    widget.widget.state.setState(() {
                      print("setState called oh");
                    });
                }
              }
              Navigator.of(context).pop(true);
            },
          )
        ],
      ),
    );
  }
}
