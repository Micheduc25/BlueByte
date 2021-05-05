import 'package:new_bluebyte/components/pointMode.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';

class MeasurementDialog extends StatefulWidget {
  MeasurementDialog({this.myContext, this.isFrench, this.unit, this.pointMode});

  @required
  final BuildContext myContext;
  @required
  final bool isFrench;
  @required
  final String unit;
  @required
  final PointMode pointMode;

  @override
  _MeasurementDialogState createState() => _MeasurementDialogState();
}

class _MeasurementDialogState extends State<MeasurementDialog> {
  TextEditingController valueController;

  @override
  void initState() {
    valueController = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    valueController?.dispose();
    super.dispose();
  }

  @override
  Widget build(myContext) {
    return SingleChildScrollView(
      child: Container(
        // height: 300,
        decoration: BoxDecoration(

            // borderRadius: BorderRadius.circular(10),
            color: Colors.white),
        // padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              Languages.enterValue[widget.isFrench ? Config.fr : Config.en],
              style: Styles.purpleTextLarge,
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      controller: valueController,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      cursorColor: AppColors.purpleNormal,
                      style: Styles.purpleTextLarge,
                      textAlign: TextAlign.center,
                      onSubmitted: (val) {
                        if (val != "")
                          Navigator.of(widget.myContext)
                              .pop(valueController.text);
                        else
                          Navigator.of(widget.myContext).pop();
                      },
                      decoration: InputDecoration(
                          hintText: Languages
                              .value[widget.isFrench ? Config.fr : Config.en],
                          hintStyle: TextStyle(
                              color: AppColors.purpleLight, fontSize: 15),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                            width: 1,
                            color: AppColors.purpleNormal,
                          )),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            width: 3,
                            color: AppColors.purpleNormal,
                          )),
                          filled: true,
                          fillColor: AppColors.purpleNormal.withOpacity(.2),
                          focusColor: AppColors.purpleNormal.withOpacity(.2)),
                    ),
                  ),
                ),
                Text(
                  widget.pointMode == PointMode.Length ? widget.unit : "°",
                  style: Styles.purpleTextLarge,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            SizedBox(height: 10),
            PurpleButton(
              label: "OK",
              onPressed: () {
                if (valueController.text != "")
                  Navigator.of(widget.myContext).pop(valueController.text);
                else
                  Navigator.of(widget.myContext).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
