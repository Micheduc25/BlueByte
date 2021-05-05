import 'package:new_bluebyte/models/pointsModel.dart';

import 'package:flutter/material.dart';

enum ObjectStackItemType {
  ///this represents points for a dot
  Dot,

  ///this represents points for a line
  Line,

  ///this represents points for a line
  Angle
}

class ObjectStackItem {
  ObjectStackItem(
      {@required this.objectType,
      this.angleObject,
      this.lineObject,
      @required this.actionAdded,
      this.dotOffset,
      @required this.newObject});

  ObjectStackItemType objectType;
  AnglePoints angleObject;
  LengthPoints lineObject;
  Offset dotOffset;
  bool actionAdded;
  bool newObject;
}
