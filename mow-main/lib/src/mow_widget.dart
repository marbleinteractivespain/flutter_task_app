import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mow/src/mow_state.dart';
import 'package:updatable/updatable.dart';

abstract class MOWWidget<Model extends Updatable> extends StatefulWidget {
  final Model _model;
  @internal
  Model get model => _model;

  MOWWidget({required Model model, Key? key})
      : _model = model,
        super(key: key ??= UniqueKey());

  @override
  @factory
  @protected
  MOWState
      createState(); // ignore: no_logic_in_create_state, this is the original sin

}
