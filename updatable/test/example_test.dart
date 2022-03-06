import 'package:test/test.dart';
import 'package:updatable/src/updatable_mixin.dart';

void main() {
  group("example", () {
    test('sample usage', () async {
      final p = Person('Anakin');
      final logger = ChangeLogger();

      expect(logger.isObserving, false);
      logger.observee = p;
      expect(logger.isObserving, true);

      // cause some changes
      await () async {
        p.name = 'Darth Vader';
        p.name = 'Worst father of the year';
      }();
      expect(logger.changes, 2);
    });
  });
}

class Person with Updatable {
  late String _name;
  String get name => _name;

  set name(String newValue) {
    changeState(() {
      _name = newValue;
    });
  }

  Person(this._name);

  @override
  String toString() {
    return '<$runtimeType: $_name>';
  }
}

class SelfAbsorbedPerson extends Person {
  SelfAbsorbedPerson(String name) : super(name) {
    addObserver(navelStaring);
  }

  void navelStaring() {
    // ignore: avoid_print
    print('I just changed!');
  }
}

class ChangeLogger<Model extends Updatable> {
  Model? _observee;
  Model? get observee => _observee;
  set observee(Model? other) {
    if (_observee != other) {
      _observee = other;
      _observee?.addObserver(nameWasChanged);
    }
  }

  int _changes = 0;
  int get changes => _changes;

  void nameWasChanged() {
    _changes += 1;
    // ignore: avoid_print
    print('$_observee has changed $_changes times!');
  }

  bool get isObserving => _observee != null;
}
