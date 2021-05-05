import 'package:new_bluebyte/utils/config.dart';

class Measurement {
  Measurement({this.measurementId, this.imageId, this.type, this.color});
  final int measurementId;
  final int imageId;
  final String type;
  final String color; //can be corrected to Color instead

  factory Measurement.fromMap(Map map) {
    return Measurement(
        measurementId: map[Config.measurementId] ?? 0,
        imageId: map[Config.imageId],
        type: map[Config.type],
        color: map[Config.color]);
  }

  Map<String, dynamic> toMap() {
    return {
      Config.imageId: this.imageId,
      Config.type: this.type,
      Config.color: this.color
    };
  }
}
