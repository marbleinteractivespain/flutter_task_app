import 'package:test/test.dart';
import 'package:updatable/src/keys.dart';

void main() {
  late KeyMaker keys;

  group('Keys', () {
    setUp(() {
      keys = KeyMaker();
    });

    test('Create', () {
      expect(() => Key(42), returnsNormally);
      expect(Key(1202), isNotNull);

      expect(() => KeyMaker(), returnsNormally);
      expect(KeyMaker(), isNotNull);
    });

    test('Ordered next keys', () {
      for (int i = 0; i < 100; i++) {
        expect(keys.next.value, i);
      }
    });
  });
}
