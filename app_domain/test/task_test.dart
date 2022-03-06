import 'package:app_domain/src/task.dart';
import 'package:test/test.dart';

void main() {
  group('Task', () {
    test('Creation', () {
      expect(InmutableTask(description: 'test'), isNotNull);
      expect(Task(description: 'Compilar', state: TaskState.toDo), isNotNull);
    });
  });

  group('Equality', () {
    test('Identical objects are equal', () {
      final compra = InmutableTask(description: 'comprar leche');
      expect(compra == compra, isTrue); // expect(compra, compra); ES LO MISMO
    });

    test('Equivalent objects must be equeal', () {
      expect(InmutableTask(description: 'description'),
          InmutableTask(description: 'description'));
    });

    test('Non-equivalent objects are not equal', () {
      expect(
          Task.toDo(description: 'Learn dart') !=
              Task.done(description: 'Learn dart'),
          isTrue);
    });
  });
}
