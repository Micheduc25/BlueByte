import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  SettingsItem(
      {this.icon,
      this.label,
      this.action,
      this.color,
      this.currentValue,
      this.showTrailing = true});
  final IconData icon;
  final String label;
  final Function action;
  final Color color;
  final bool showTrailing;
  final Widget currentValue;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: AppColors.purpleNormal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  color: color ?? AppColors.purpleNormal,
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label ?? "",
                      style: Styles.purpleTextNormal,
                    ),
                    currentValue != null
                        ? SizedBox(
                            height: 5,
                          )
                        : Container(),
                    currentValue ?? Container()
                  ],
                )
              ],
            ),
            showTrailing
                ? Icon(
                    Icons.chevron_right,
                    color: color ?? AppColors.purpleNormal,
                  )
                : Container()
          ],
        ),
      ),
      onTap: action ??
          () {
            print("action for $label launched");
          },
    );
  }
}
