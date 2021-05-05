import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:flutter/material.dart';

class NotificationDialog {
  static void showMyDialogue(String title, String message, BuildContext context,
      {bool positive = true}) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.purpleLight,
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            titleTextStyle:
                TextStyle(color: positive ? AppColors.purpleDark : Colors.red),
            contentTextStyle:
                TextStyle(color: positive ? AppColors.purpleDark : Colors.red),
            content: Container(
              child: Text(message),
              padding: EdgeInsets.all(10),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          );
        });
  }
}
