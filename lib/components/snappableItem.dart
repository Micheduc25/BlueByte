import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_bluebyte/components/objectsPainter.dart';
import 'package:new_bluebyte/components/pointMode.dart';
import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/models/newImageModel.dart';
import 'package:new_bluebyte/models/objectModel.dart';
import 'package:new_bluebyte/utils/settings.dart';

class SnappableItem extends StatelessWidget {
  SnappableItem(
      {@required this.imageFile,
      @required this.objectImage,
      @required this.isFrench,
      @required this.module,
      @required this.objectId,
      @required this.pointController,
      @required this.settings,
      @required this.wstate,
      @required this.isVisible});
  final File imageFile;
  final ObjectImage objectImage;
  final bool isFrench;
  final Module module;
  final int objectId;
  final PointCollector pointController;
  final AppSettings settings;
  final State<StatefulWidget> wstate;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isVisible ? 1 : 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image(
            image: FileImage(
              imageFile,
            ),
            fit: BoxFit.contain,
          ),
          ObjectsPainter(
              context: context,
              image: objectImage,
              imagePath: objectImage.path,
              isFrench: isFrench,
              moduleName: module.name,
              objectId: objectId,
              objectName: '',
              pointControllerState: pointController,
              settings: settings,
              state: wstate,
              strokeWidth: settings.lineWidth.getValue(),
              objectsToPaint: pointController.objectStackFinal)
        ],
      ),
    );
  }
}
