import 'package:updatable/updatable.dart';

class InmutableTask {
  late String _description;

  //Accesors
  // String get description {
  //   return _description;
  // }

  String get description => _description;

  set description(String newValue) {
    if (newValue != _description) {
      _description = newValue;
    }
  }

  //Constructors
  InmutableTask({required String description}) : _description = description;

  //Overrides

  @override
  String toString() {
    return '<$runtimeType: $description>';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else {
      return other is InmutableTask && _description == description;
    }
  }

  @override
  int get hashCode => description.hashCode;
}

//Enum TaskState
enum TaskState { toDo, doing, done }

// Subclass InmutableTask
class Task extends InmutableTask with Updatable {
  late TaskState _state;

  TaskState get state => _state;

  set state(TaskState newValue) {
    if (newValue != _state) {
      changeState(() {
        _state = newValue;
      });
    }
  }

  //Constructor "designado"
  Task({required String description, required TaskState state})
      : _state = state,
        super(description: description);

  //Contructores con nombre
  Task.toDo({required String description})
      : _state = TaskState.toDo,
        super(description: description);

  Task.done({required String description})
      : _state = TaskState.done,
        super(description: description);

  //Overrides
  @override
  String toString() {
    return '<$runtimeType: $state, $description>';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else {
      return other is Task &&
          state == other.state &&
          description == other.description;
    }
  }

  @override
  // int get hashCode => description.hashCode ^ state.hashCode;
  int get hashCode => Object.hashAll([description, state]);
}
