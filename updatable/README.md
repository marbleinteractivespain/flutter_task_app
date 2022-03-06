A library for Dart developers.

## Usage

A simple usage example:

```dart
import 'package:updatable/updatable.dart';

void main() {
  final p = Person('Georgina'); // Model
  final logger = ChangeLogger().observee = p; // Observer

  p.name = 'Jerome'; // Loggers will log

  final me = SelfAbsorbedPerson('Elaine'); // Both
  me.name = 'Lisa'; 
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
