import 'dart:async';

class EditStreamService {
  final StreamController<bool> _onEditData;

  EditStreamService() : _onEditData = StreamController<bool>.broadcast();

  Stream<bool> get onEditData => _onEditData.stream;

  void emitEditEvent(bool event) {
    _onEditData.add(event);

    print("edit event emitted ohhh!");
  }

  // void emitErrorEvent(err){
  //   _onEditData.addError(error)
  // }

  void dispose() {
    _onEditData.close();
  }
}
