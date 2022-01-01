// Copyright 2021 - 2021, Amirreza Madani. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// builder for [OnOffControllerBuilder].
typedef OnOffControllerWidgetBuilder = Widget Function(
  BuildContext context,
  bool state,
);

/// change listener for [OnOffControllerBuilder].
///
/// won't be called with equal elements.
///
/// always will fire new states to listener.
typedef OnOffControllerChangeListener = void Function(bool state);

/// Basically:
/// If value > limit => {on}.
/// And if value < limit => {off}.
///
/// Only will change on `pass` not on `equal or pass`.
///
/// Diagram: {off} -- [lowerLimit] -- {off} or {on} -- [upperLimit] --- {on}.
///
/// {on} is {state == true}.
/// {off} is {state == false}.
///
/// It will reset state on [upperLimit] or [lowerLimit] properties updates, if
/// [isResetStateOnBoundaryUpdate] is set to true.
/// (which is true by default).
///
/// It will reset state on [initialState] property updates, if
/// [isResetStateOnBoundaryUpdate] is set to true.
/// (which is true by default).
///
/// [listener] will be called for initial state if [isCallChangeListenerForInitialState] is true.
/// (which is true by default).
///
/// [initialState] is false by default.
class OnOffControllerBuilder extends StatefulWidget {
  const OnOffControllerBuilder({
    Key? key,
    this.isResetStateOnBoundaryUpdate = true,
    this.isResetStateOnInitialStateUpdate = true,
    this.isCallChangeListenerForInitialState = true,
    this.initialState = false,
    required this.upperLimit,
    required this.lowerLimit,
    required this.value,
    this.listener,
    required this.builder,
  })  : assert(upperLimit >= lowerLimit),
        super(key: key);

  /// whether to reset state on boundary update.
  final bool isResetStateOnBoundaryUpdate;

  /// whether to reset state on initial state update.
  final bool isResetStateOnInitialStateUpdate;

  /// whether call change listener for initial state.
  final bool isCallChangeListenerForInitialState;

  /// state initial value.
  final bool initialState;

  /// upper limit.
  final double upperLimit;

  /// lower limit.
  final double lowerLimit;

  /// [value].
  final double value;

  /// change listener.
  final OnOffControllerChangeListener? listener;

  /// builder.
  final OnOffControllerWidgetBuilder builder;

  @override
  _OnOffControllerBuilderState createState() => _OnOffControllerBuilderState();
}

class _OnOffControllerBuilderState extends State<OnOffControllerBuilder> {
  /// if [_state] ?
  bool? _state;

  // no need for [setState] since we are
  // always changing state on widget updates.
  void _updateState(final bool newState, {required final bool isInitial}) {
    final oldStateOrNull = _state;
    if (newState != oldStateOrNull) {
      _state = newState;
      if (!isInitial || widget.isCallChangeListenerForInitialState) {
        widget.listener?.call(newState);
      }
    }
  }

  void _turnInitially() {
    _updateState(widget.initialState, isInitial: true);
  }

  void _turn(final bool newState) {
    _updateState(newState, isInitial: false);
  }

  void _controllerLogic() {
    final oldState = _state!;
    if (oldState) {
      // oldState == true.
      // controller was {on}:

      // update only if `passed` not on `equals or passed`.
      if (widget.value < widget.lowerLimit) {
        // turn {off} controller:
        _turn(false);
      }
    } else {
      // oldState == false.
      // controller was {off}:

      // update only if `passed` not on `equals or passed`.
      if (widget.value > widget.upperLimit) {
        // turn {on} controller:
        _turn(true);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _turnInitially();
  }

  @override
  void didUpdateWidget(covariant OnOffControllerBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialState != oldWidget.initialState) {
      if (widget.isResetStateOnInitialStateUpdate) {
        _turnInitially();
        return;
      }
    }

    if (widget.upperLimit != oldWidget.upperLimit ||
        widget.lowerLimit != oldWidget.lowerLimit) {
      if (widget.isResetStateOnBoundaryUpdate) {
        _turnInitially();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _controllerLogic();

    return widget.builder(context, _state!);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(ObjectFlagProperty(
      'listener',
      widget.listener,
      showName: true,
      ifPresent: 'non-null - has change listener',
      ifNull: 'null - has NOT change listener',
    ));
    properties.add(FlagProperty(
      'isResetStateOnBoundaryUpdate',
      value: widget.isResetStateOnBoundaryUpdate,
      defaultValue: true,
      showName: true,
      ifTrue: 'true - resets controller state on '
          'widget boundary properties updates',
      ifFalse: 'false - does NOT reset controller state on '
          'widget boundary properties updates',
    ));
    properties.add(FlagProperty(
      'isResetStateOnInitialStateUpdate',
      value: widget.isResetStateOnInitialStateUpdate,
      defaultValue: true,
      showName: true,
      ifTrue: 'true - resets controller state on '
          'widget initial state property updates',
      ifFalse: 'false - does NOT reset controller state on '
          'widget initial state property updates',
    ));
    properties.add(FlagProperty(
      'isCallChangeListenerForInitialState',
      value: widget.isCallChangeListenerForInitialState,
      defaultValue: true,
      showName: true,
      ifTrue: 'true - calls change listener for initial state',
      ifFalse: 'false - does NOT call change listener for initial state',
    ));
    properties.add(DiagnosticsProperty<bool>(
      'initialState',
      widget.initialState,
      defaultValue: false,
    ));
    properties.add(DoubleProperty('upperLimit', widget.upperLimit));
    properties.add(DoubleProperty('lowerLimit', widget.lowerLimit));
    properties.add(DoubleProperty('value', widget.value));
  }
}
