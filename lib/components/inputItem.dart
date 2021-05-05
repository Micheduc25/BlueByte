import 'package:new_bluebyte/utils/colors&fonts.dart';

import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';

class InputItem extends StatelessWidget {
  const InputItem(
      {Key key,
      @required this.lang,
      @required this.controller,
      this.label,
      this.hint,
      this.size})
      : super(key: key);

  final String lang;
  final String label;
  final String hint;
  final Size size;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: Styles.purpleTextNormal,
        ),
        SizedBox(height: 10),
        TextField(
          textAlign: TextAlign.center,
          controller: controller,
          autofocus: true,
          cursorColor: AppColors.purpleNormal,
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 3, color: AppColors.purpleDark)),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 2, color: AppColors.purpleDark)),
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.purpleLight,
                fontSize: 15,
              )),
        ),
      ],
    );
  }
}
