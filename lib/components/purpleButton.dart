import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';

class PurpleButton extends StatelessWidget {
  PurpleButton(
      {this.label,
      this.onPressed,
      this.paddingVert = 10.0,
      this.paddingHori = 20.0});

  final String label;
  final Function onPressed;
  final double paddingVert;
  final double paddingHori;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        label,
        style: Styles.whiteTextNormal,
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppColors.purpleNormal),
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
            vertical: paddingVert, horizontal: paddingHori)),
      ),
      onPressed: onPressed,
    );
  }
}
