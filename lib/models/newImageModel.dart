import 'package:new_bluebyte/utils/config.dart';
import 'package:flutter/cupertino.dart';

class ObjectImage {
  ObjectImage(
      {this.imageId,
      @required this.objectId,
      @required this.path,
      @required this.name});

  int imageId;
  String name;
  String path;
  int objectId;

  Map<String, dynamic> toMap() {
    return {
      Config.objectId: this.objectId,
      Config.name: this.name,
      Config.path: this.path,
    };
  }

  factory ObjectImage.fromMap(Map<String, dynamic> map) {
    return new ObjectImage(
        imageId: map[Config.imageId],
        objectId: map[Config.objectId],
        path: map[Config.path],
        name: map[Config.name]);
  }
}
