import 'package:new_bluebyte/utils/config.dart';

class Object {
  Object(
      {this.objectId,
      this.name,
      this.moduleId,
      this.creationDate,
      this.objectType});
  final int objectId;
  final int moduleId;
  final String name;
  final String objectType;
  final String creationDate;

  factory Object.fromMap(Map<String, dynamic> map) {
    return Object(
        objectId: map[Config.objectId] ?? 0,
        moduleId: map[Config.moduleId] ?? 0,
        name: map[Config.name] ?? "",
        creationDate: map[Config.creationDate] ?? "",
        objectType: map[Config.objectType] ?? "");
  }

  Map<String, dynamic> toMap() {
    //we omit the objectId here as it is automatically added in the database
    return {
      Config.moduleId: this.moduleId,
      Config.name: this.name,
      Config.objectType: this.objectType,
      Config.creationDate: this.creationDate
    };
  }
}
