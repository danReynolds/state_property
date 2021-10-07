// ignore_for_file: prefer_void_to_null

import 'package:flutter/material.dart';
import 'package:state_property/state_property.dart';

typedef StatelessWidgetResolver = Widget? Function(BuildContext context);
typedef StatefulWidgetResolver<States> = Widget? Function(
  BuildContext context,
  Set<States> states,
);

/// A state property that extends the [StateProperty] interface to pass a [BuildContext]
/// in the resolver in order to support Flutter widgets.
class WidgetStateProperty<States> {
  final StateProperty<States, Widget?> Function(BuildContext context) _resolve;

  WidgetStateProperty(this._resolve);

  Widget? resolve(BuildContext context, Set<States> states) {
    final stateProperty = _resolve(context);
    return stateProperty.resolve(states);
  }

  /// The most flexible [WidgetStateProperty] that allows for dynamically resolving behavior based on the provided set of states.
  static WidgetStateProperty<States> resolveWith<States>(
          StatefulWidgetResolver<States> builder) =>
      WidgetStateProperty(
        (BuildContext context) => StateProperty.resolveWith<States, Widget?>(
            (states) => builder(context, states)),
      );

  static WidgetStateProperty<States> resolveState<States>(
    StatelessWidgetResolver builder,
    States state,
  ) =>
      WidgetStateProperty(
        (BuildContext context) => StateProperty.resolveState<States, Widget?>(
            () => builder(context), state),
      );

  /// Resolves the given builder in all cases regardless of the state of the scroll view.
  static WidgetStateProperty<States> all<States>(
          StatelessWidgetResolver builder) =>
      WidgetStateProperty(
        (BuildContext context) =>
            StateProperty.all<States, Widget?>(() => builder(context)),
      );

  /// Resolves `null` as the value regardless of the state of the scroll view.
  static WidgetStateProperty<States> never<States>() =>
      WidgetStateProperty((_context) => StateProperty.never<States>());
}
