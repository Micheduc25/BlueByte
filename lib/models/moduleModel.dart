import 'package:new_bluebyte/utils/config.dart';

class Module {
  Module(
      {this.moduleId,
      this.moduleType,
      this.name,
      this.location,
      this.creationDate});
  int moduleId;
  String name;
  String location;
  String moduleType;
  String creationDate;

  set id(int newId) {
    this.moduleId = newId;
  }

  factory Module.fromMap(Map map) {
    return Module(
        moduleId: map[Config.moduleId] ?? 0,
        name: map[Config.name] ?? "",
        location: map[Config.location] ?? "",
        moduleType: map[Config.moduleType] ?? "",
        creationDate: map[Config.creationDate] ?? null);
  }

  Map<String, dynamic> toMap() {
    return {
      Config.name: this.name,
      Config.location: this.location,
      Config.moduleType: this.moduleType,
      Config.creationDate: this.creationDate
    };
  }
}
