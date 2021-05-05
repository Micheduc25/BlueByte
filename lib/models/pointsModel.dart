import 'package:new_bluebyte/utils/config.dart';

class LengthPoints {
  LengthPoints(
      {this.pointsId,
      this.imageId,
      this.firstpointX,
      this.firstpointY,
      this.secondpointX,
      this.secondpointY,
      this.length,
      this.width,
      this.color,
      this.backgroundColor,
      this.unit});

  final int pointsId;
  final String unit;
  final String backgroundColor;

  final int imageId;
  final double firstpointX;
  final double firstpointY;
  final double secondpointX;
  final double secondpointY;
  final double length;
  final double width;
  final String color;

  factory LengthPoints.fromMap(Map<String, dynamic> map) {
    return LengthPoints(
        pointsId: map[Config.pointsId] ?? 0,
        imageId: map[Config.imageId],
        firstpointX: map[Config.firstpointX],
        firstpointY: map[Config.firstpointY],
        secondpointX: map[Config.secondpointX],
        secondpointY: map[Config.secondpointY],
        length: map[Config.length],
        width: map[Config.width],
        color: map[Config.color],
        backgroundColor: map[Config.backgroundColor],
        unit: map[Config.unit] ?? "");
  }

  Map<String, dynamic> toMap() {
    return {
      Config.imageId: this.imageId,
      Config.firstpointX: this.firstpointX,
      Config.firstpointY: this.firstpointY,
      Config.secondpointX: this.secondpointX,
      Config.secondpointY: this.secondpointY,
      Config.length: this.length,
      Config.width: this.width,
      Config.color: this.color,
      Config.backgroundColor: this.backgroundColor,
      Config.unit: this.unit
    };
  }
}

class AnglePoints {
  AnglePoints(
      {this.pointsId,
      this.imageId,
      this.firstpointX,
      this.firstpointY,
      this.secondpointX,
      this.secondpointY,
      this.thirdpointX,
      this.thirdpointY,
      this.angle,
      this.color,
      this.width,
      this.backgroundColor,
      this.unit});

  final int pointsId;
  final int imageId;
  final double firstpointX;
  final double firstpointY;
  final double secondpointX;
  final double secondpointY;
  final double thirdpointX;
  final double thirdpointY;
  final double angle;
  final double width;
  final String backgroundColor;
  final String color;
  final String unit;

  factory AnglePoints.fromMap(Map<String, dynamic> map) {
    return AnglePoints(
        pointsId: map[Config.pointsId] ?? 0,
        imageId: map[Config.imageId] ?? 0,
        firstpointX: map[Config.firstpointX] ?? 0,
        firstpointY: map[Config.firstpointY] ?? 0,
        secondpointX: map[Config.secondpointX] ?? 0,
        secondpointY: map[Config.secondpointY] ?? 0,
        thirdpointX: map[Config.thirdpointX] ?? 0,
        thirdpointY: map[Config.thirdpointY] ?? 0,
        angle: map[Config.angle] ?? 0,
        width: map[Config.width] ?? 0,
        color: map[Config.color] ?? "0xff000000",
        backgroundColor: map[Config.backgroundColor] ?? "0xff000000",
        unit: map[Config.unit] ?? "");
  }

  Map<String, dynamic> toMap() {
    return {
      Config.imageId: this.imageId,
      Config.firstpointX: this.firstpointX,
      Config.firstpointY: this.firstpointY,
      Config.secondpointX: this.secondpointX,
      Config.secondpointY: this.secondpointY,
      Config.thirdpointX: this.thirdpointX,
      Config.thirdpointY: this.thirdpointY,
      Config.angle: this.angle,
      Config.width: this.width,
      Config.color: this.color,
      Config.backgroundColor: this.backgroundColor,
      Config.unit: this.unit
    };
  }
}
