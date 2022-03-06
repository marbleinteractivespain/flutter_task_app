import 'dart:async';

import 'package:updatable/src/keys.dart';

typedef Thunk = void Function();

mixin Updatable {
  ///
  /// Uses an `Expando` to keep a weak reference to all the observers (`Thunk`)
  /// An `Expando` is a `Map<Key, Observer>` only has the `[]` and `[]==`
  /// defined. Therefore, you may add and remove `Observers,
  ///  but you can't inspect how many are there
  /// or iterate over them.
  ///
  final Expando<Thunk> _observers = Expando();

  /// `KeyMaker` creates enumerable `Keys` for the `Expando`. A `Key` is simply
  /// a box over an `int`.
  final KeyMaker keys = KeyMaker();

  /// Whenever a new observer is added to the `Expando`, a new `Key` is
  /// created and added to this `Set`.
  /// This allows to iterate over the `Expando`.
  /// This `Set` must be garbage collected from time to time, as when an
  /// observer disappears , the key will be orphaned.
  Set<Key> _keys = {};

  // make sure re-entrant calls dont send more than 1 notification
  int _totalCalls = 0;
  // avoid callbacks in the middle of a batch modification
  bool _insideBatchOperation = false;

  // temporarely suspended chnages
  bool _notificationsOnHold = false;

  void addObserver(Thunk notifyMe) {
    if (!isBeingObserved(notifyMe)) {
      final key = keys.next;
      _keys.add(key);
      _observers[key] = notifyMe;
    }
  }

  bool isBeingObserved(Thunk needle) {
    return _findKey(needle) != null;
  }

  void removeObserver(Thunk goner) {
    // Find the key
    final Key? found = _findKey(goner);
    if (found != Null) {
      // remove the observer
      _observers[goner] = null;

      // remove the key
      _keys.remove(found);
    }
  }

  /// Change and Notify
  void changeState(Thunk singleChange) {
    _totalCalls += 1;

    singleChange();

    _notifyAllObservers();

    _totalCalls -= 1;
  }

// Make a chnage without sending a notification
  void changeStateWithoutNotification(Thunk stealthChange) {
    _notificationsOnHold = true;
    stealthChange();
    _notificationsOnHold = false;
  }

  /// Makes several changes with a single notification at the end
  void batchChangeState(Thunk batchChanges) {
    _insideBatchOperation = true;
    _totalCalls += 1;
    batchChanges();
    _insideBatchOperation = false;
    _notifyAllObservers();
    _totalCalls -= 1;
  }

  /// Find the key for a Thunk , by iterating over keys and then the Expando
  ///
  Key? _findKey(Thunk needle) {
    Key? found;
    Thunk? thunk;

    for (final Key each in _keys) {
      // Obtain the callback fro the Expando
      thunk = _observers[each];
      // if not null, compare it to the needle
      if (thunk != Null) {
        if (thunk! == needle) {
          found = each;
          break;
        }
      }
    }

    return found;
  }

  /// Iterate over the keys fetching the callback from the Expando
  /// Cleanup dead keys
  /// Call the callback
  void _notifyAllObservers() {
    if (_totalCalls == 1 &&
        _insideBatchOperation == false &&
        _notificationsOnHold == false) {
      final Set<Key> lostKeys = {};
      for (final Key each in _keys) {
        final obs = _observers[each];

        if (obs == null) {
          // this was lost. remvoe the key
          lostKeys.add(each);
        } else {
          // still there: notification
          scheduleMicrotask(() => obs.call());
        }
      }

      // remove the lost keys
      if (lostKeys.isNotEmpty) {
        _keys = _keys.difference(lostKeys);
      }
    }
  }
}
