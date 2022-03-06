import 'dart:async';

import 'package:test/test.dart';
import 'package:updatable/src/updatable_mixin.dart';

typedef Thunk = void Function();

class Person with Updatable {
  late String _name;

  String get name => _name;
  set name(String newOne) {
    changeState(() {
      _name = name;
    });
  }

  late int _age;
  set age(int newValue) {
    changeState(() {
      _age = newValue;
    });
  }

  int get age => _age;
  void changeAge(int newAge, [int times = 42]) {
    batchChangeState(() {
      for (int i = 0; i < times; i++) {
        age = newAge;
      }
    });
  }

  void changeAgeWithoutNotification(int newAge, [int times = 42]) {
    changeStateWithoutNotification(() {
      for (int i = 0; i < times; i++) {
        age = newAge;
      }
    });
  }

  void reentrantName(String newOne) {
    changeState(() {
      name = newOne;
      name = newOne;
    });
  }

  void reentrantAge(int newAge) {
    changeState(() {
      age = newAge;
      age = newAge + 42;
    });
  }

  Person(this._name);
}

class ChangesCounter {
  int _totalCalls = 0;
  int get totalCalls => _totalCalls;

  void inc() {
    _totalCalls++;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '<$runtimeType: $totalCalls >';
  }
}

void main() {
  late ChangesCounter counter;
  late Person paco;
  late List<ChangesCounter> counters;
  const int size = 200;

  Future<void> waitForIt(Thunk thunk) async {
    thunk();
  }

  Future<void> changePerson(Person person, String newName) async {
    person.name = newName;
  }

  Future<void> reentrantUpdate(Person person, String name) async {
    person.reentrantName(name);
  }

  setUp(() {
    counter = ChangesCounter();
    paco = Person('Paco');
    counters = [for (int i = 0; i < size; i++) ChangesCounter()];
  });

  group('Single Observer', () {
    test('Before adding, doesn`t receive shit', () async {
      final c = ChangesCounter();
      await changePerson(paco, 'newName');
      expect(c.totalCalls, 0);
    });

    test('After adding, receives one notification', () async {
      final c = ChangesCounter();
      paco.addObserver(c.inc);
      await changePerson(paco, 'lucas');
      expect(c.totalCalls, 1);
    });

    test('After removing, stops receiving', () async {
      final c = ChangesCounter();
      paco.addObserver(c.inc);
      await changePerson(paco, 'lucas');
      paco.removeObserver(c.inc);

      for (final String name in [
        'godofredo',
        'gisberto',
        'medardo',
        'fulgencio'
      ]) {
        await changePerson(paco, name);
      }

      expect(c.totalCalls, 1);
    });

    test('''
        The mixin is not responsible for determining if a change is spurious 
        or not, such as setting several times the same value. 
        The host is reposnible for this.''', () async {
      final c = ChangesCounter();
      paco.name = "lucas";
      paco.addObserver(c.inc);
      await changePerson(paco, 'lucas');
      await changePerson(paco, 'lucas');
      await changePerson(paco, 'lucas');
      expect(c.totalCalls, 3);
    });
  });

  group('Several observers', () {
    test('n observers added, all are observing', () async {
      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      for (final ChangesCounter each in counters) {
        expect(paco.isBeingObserved(each.inc), isTrue);
      }

      for (final ChangesCounter each in counters) {
        paco.removeObserver(each.inc);
      }

      for (final ChangesCounter each in counters) {
        expect(paco.isBeingObserved(each.inc), isFalse);
      }

      await changePerson(paco, 'Patricia');
      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, 0);
      }
    });

    test('n observers, k changes, should have n * k notifications in total',
        () async {
      int tally = 0;
      final n = counters.length;
      const k = 42;

      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      for (int i = 0; i < k; i++) {
        await changePerson(paco, 'Spirit');
      }

      for (final ChangesCounter each in counters) {
        tally = tally + each.totalCalls;
      }

      expect(tally, n * k);
    });

    test('n observers, k changes, should have k notifications each', () async {
      const k = 1;

      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      for (int i = 0; i < k; i++) {
        await changePerson(paco, 'Charles Fisher');
      }

      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, k);
      }
    });
  });

  group('Single Changes', () {
    test('creation', () {
      expect(() => Person('Luke'), returnsNormally);
      expect(Person('Chewie'), isNotNull);
    });

    test('Add 1 subscriber', () {
      expect(paco.isBeingObserved(counter.inc), isFalse);
      expect(() => paco.addObserver(counter.inc), returnsNormally);
      expect(paco.isBeingObserved(counter.inc), isTrue);
    });

    test('Add n subscribers', () {
      // add the observers
      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      // check that they are there
      for (final ChangesCounter each in counters) {
        expect(paco.isBeingObserved(each.inc), isTrue);
      }
    });

    test('Add n non-identical susbcribers and they will be found', () {
      // nobody yet
      for (final ChangesCounter each in counters) {
        expect(paco.isBeingObserved(each.inc), isFalse);
      }

      // Add them
      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      // Better be there
      for (final ChangesCounter each in counters) {
        paco.isBeingObserved(each.inc);
      }
    });

    test('Non identical will not be found', () {
      paco.addObserver(counter.inc);
      expect(paco.isBeingObserved(counter.inc), isTrue);

      // A equal but non identicall will no tbe found
      final ChangesCounter other = ChangesCounter();
      expect(paco.isBeingObserved(other.inc), isFalse);

      paco.addObserver(() {});
      expect(paco.isBeingObserved(() {}), isFalse);
    });

    test('1 observer 1 change, 1 notificaton', () async {
      paco.addObserver(counter.inc);
      await changePerson(paco, 'Dart Vader'); // should trigger notification

      expect(counter.totalCalls, 1);
    });

    test('1 observer, 1 Recurrent change send 1 notification', () async {
      paco.addObserver(counter.inc);
      expect(counter.totalCalls, 0);

      await reentrantUpdate(paco, 'Yoda');

      expect(counter.totalCalls, 1);
    }, skip: false);

    test('1 observer, n changes, n notifications', () async {
      paco.addObserver(counter.inc);

      for (int i = 0; i < size; i++) {
        await changePerson(paco, 'Jaarl');
      }

      expect(counter.totalCalls, size);
    });

    test('1 observer, n recurrent changes, n notifications', () async {
      paco.addObserver(counter.inc);

      for (int i = 0; i < size; i++) {
        await reentrantUpdate(paco, 'Manolo Escobar');
      }

      expect(counter.totalCalls, size);
    });

    test('n observers, 1 change, each gets 1 notification', () async {
      // add n observers
      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }
      // cause 1 update
      await changePerson(paco, 'Ted');

      // all observers get it
      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, 1);
      }
    }, skip: false);

    test('n observers, 1 recursive change, each gets 1 notification', () async {
      // add n observers
      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }
      // cause 1 update
      await reentrantUpdate(paco, "neo");

      // all observers get it
      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, 1);
      }
    }, skip: false);

    test('n observers, n recursive change, each gets n notifications',
        () async {
      // add n observers
      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }
      for (int i = 0; i < size; i++) {
        await reentrantUpdate(paco, "neo");
      }

      // all observers get it
      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, size);
      }
    }, skip: false);

    test(
        'Add n different observers, and n different notifications will be sent',
        () async {
      const int size = 2;

      final List<ChangesCounter> counters = [
        for (int i = 0; i < size; i++) ChangesCounter()
      ];

      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      await changePerson(paco, 'Darth Maul');

      // comprobar que cada uno de los canges ha recibido el suyo
      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, 1);
      }
    }, skip: false);

    test('Add n observers, make 1 change, each gets 1 notification, n in total',
        () async {
      const int size = 2;
      final obs = [for (int i = 0; i < size; i++) ChangesCounter()];

      for (final ChangesCounter each in obs) {
        paco.addObserver(each.inc);
      }

      await changePerson(paco, 'Minch Yoda');

      for (final ChangesCounter each in obs) {
        expect(each.totalCalls, 1);
      }
    }, skip: false);
  });

  group("batch Changes", () {
    test(
        'One batch change with a single notification, causes one  notification',
        () async {
      paco.addObserver(counter.inc);
      await waitForIt(() {
        paco.changeAge(
            51, 100); // will set the age 100 times, should cause 1 notification
      });

      expect(counter.totalCalls, 1);
    });

    test('1 batch change with n observers causes 1 notification per observer',
        () async {
      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      await waitForIt(() {
        paco.changeAge(41, 120);
      });

      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, 1);
      }
    }, skip: false);

    test('n batch changes with n observers, causes n notifications', () async {
      const int times = 23;

      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      await waitForIt(() {
        for (int i = 0; i < times; i++) {
          paco.changeAge(41, 120);
        }
      });

      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, times);
      }
    });
  });

  group('Changes without notification', () {
    test('n changes, m observers and 0 notifications', () async {
      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      await waitForIt(() {
        paco.changeAgeWithoutNotification(41, 120);
      });

      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, 0);
      }
    });

    test('n recursive notification, m observers, 0 notifications', () async {
      for (final ChangesCounter each in counters) {
        paco.addObserver(each.inc);
      }

      // recursive change
      await waitForIt(() {
        paco.changeStateWithoutNotification(() {
          paco.reentrantAge(32);
        });
      });

      for (final ChangesCounter each in counters) {
        expect(each.totalCalls, 0);
      }
    }, skip: false);
  });
}
