import 'package:flutter/material.dart';
import 'package:mow/src/mow_widget.dart';
import 'package:updatable/updatable.dart';

abstract class MOWState<Model extends Updatable, W extends MOWWidget<Model>>
    extends State<W> {
  // The state keeps the reference to the model

  late final Model _model;
  Model get model => _model;

  @mustCallSuper
  void _modelDidChange() {
    setState(() {});
  }

  /// Life cycle
  @override
  void initState() {
    // Start observing the model
    _model = widget.model;
    _model.addObserver(_modelDidChange);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    // stop observing old model
    oldWidget.model.removeObserver(_modelDidChange);

    // Get new model and start observing
    _model = widget.model;
    _model.addObserver(_modelDidChange);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _model.removeObserver(_modelDidChange);
    super.dispose();
  }
}
