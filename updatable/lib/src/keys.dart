// Enumerable keys for an Expando. Just a box over an int
class Key {
  final int value;
  Key(this.value);

  @override
  String toString() {
    return '<$runtimeType: $value>';
  }
}

// Creates keys in an an ordered way
class KeyMaker {
  int _current = 0;
  Key get next {
    return Key(_current++);
  }
}
