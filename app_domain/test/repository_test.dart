import 'package:app_domain/app_domain.dart';
import 'package:app_domain/src/taskRepository.dart';
import 'package:app_domain/src/task.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late TaskRepository repo;
  late Task sampletask;
  late Task sampletask2;

  // Se llama antes de cualquier test
  setUp(() {
    repo = TaskRepository.shared;
    sampletask = Task.toDo(description: 'aqui va la tarea 1');
    sampletask2 = Task.done(description: 'aqui va la tarea 2');
  });

  // Se ejecuta despues de todo test
  tearDown(() {
    //vaciar repo
    repo.reset();
  });

  group('Creation & Accessors', () {
    test('Empty repo', () {
      expect(TaskRepository.shared, isNotNull);
      expect(TaskRepository.shared.length, 0);
    });
  });

  group('Mutators', () {
    test('Add to he begining of the repo', () {
      repo.add(sampletask);
      expect(repo.length, 1);
      expect(repo[0], sampletask);
    });

    test('Insert: adds at the corresponding index', () {
      expect(() => repo.insert(10, sampletask2), throwsRangeError);
      expect(() => repo.insert(0, sampletask2), returnsNormally);

      final taskNew = Task.done(description: 'prueba de inserccion');
      repo.insert(1, taskNew);
      expect(repo[1], taskNew);
    });

    test('Remove: removes object if present', () {
      final task = Task.toDo(description: 'tarea para borrar');
      final int oldSize = repo.length;
      repo.add(task);
      expect(repo.length, oldSize + 1);
      repo.remove(task);
      expect(repo.length, oldSize);
    });

    test('RemovesAt: removes from the corresponding index', () {
      expect(() => repo.removeAt(42), throwsRangeError);
      repo.add(sampletask2);
      repo.removeAt(0);
      expect(repo.length, 0);
    });

    test('Move: moves elements between valid indexes', () {
      repo.add(sampletask);
      repo.add(sampletask2);

      //mover de un sitio al mismo no altera
      repo.move(0, 0);
      expect(repo[0], sampletask2);
      expect(repo[1], sampletask);

      //mover con rangos q no existen da error de rango
      expect(() => repo.move(42, -1), throwsRangeError);

      //mover entre rangos normales funciona
      repo.move(0, 1);
      expect(repo.length, 2);
      expect(repo[1], sampletask2);
    });
  });
}
