import 'package:mow/mow.dart';

/// Composite of two models, for when an Observer has to observe 2 models,
/// it should observe the ModelPair instead
class ModelPair<First extends Updatable, Second extends Updatable>
    with Updatable {
  late final First first;
  late final Second second;

  ModelPair(First first, Second second)
      : first = first,
        second = second {
    first.addObserver(_subModelChanged);
    second.addObserver(_subModelChanged);
  }

  void _subModelChanged() {
    changeState(() {});
  }
}
