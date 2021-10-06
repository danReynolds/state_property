// ignore_for_file: prefer_void_to_null

library state_property;

export 'package:state_property/widget_state_property.dart';

typedef StatefulResolver<States, ResolverType> = ResolverType? Function(
  Set<States> states,
);

typedef StatelessResolver<ResolverType> = ResolverType? Function();

abstract class StateProperty<States, ResolverType> {
  ResolverType? resolve(Set<States> states);

  /// The most flexible [StateProperty] that allows for dynamically resolving behavior based on the provided set of states.
  static StateProperty<States, ResolverType> resolveWith<States, ResolverType>(
          StatefulResolver<States, ResolverType> resolver) =>
      _StatePropertyWhen<States, ResolverType>(resolver);

  /// Resolves the given behavior when in the provided state, otherwise `null`.
  static StateProperty<States, ResolverType> resolveState<States, ResolverType>(
          StatelessResolver<ResolverType> resolver, States state) =>
      _StatePropertyValueWhenInState<States, ResolverType>(resolver, state);

  /// Resolves the given behavior independent of the current state of the system.
  static StateProperty<States, ResolverType> all<States, ResolverType>(
          StatelessResolver<ResolverType> resolver) =>
      _StatePropertyValue<States, ResolverType>(resolver);

  /// Resolves `null` as the behavior independent of the current state of the system.
  static StateProperty<States, Null> never<States, ResolverType>() =>
      _StatePropertyValue<States, Null>(() => null);
}

/// A [StateProperty] that provides the resolver with the set of current states
/// so that it can dynamically choose what value to return based on those states.
class _StatePropertyWhen<States, ResolverType>
    implements StateProperty<States, ResolverType> {
  final StatefulResolver<States, ResolverType> _resolver;

  _StatePropertyWhen(this._resolver);

  @override
  ResolverType? resolve(states) => _resolver(states);
}

/// A [StateProperty] that resolves the state-agnostic resolver function.
class _StatePropertyValue<States, ResolverType>
    implements StateProperty<States, ResolverType> {
  final StatelessResolver<ResolverType> _resolve;

  _StatePropertyValue(this._resolve);

  @override
  ResolverType? resolve(_states) => _resolve();
}

/// A [StateProperty] that resolves the state-agnostic resolver function when the current
/// states includes the given state.
class _StatePropertyValueWhenInState<States, ResolverType>
    implements StateProperty<States, ResolverType> {
  final StatelessResolver<ResolverType> _resolve;
  final States _state;

  _StatePropertyValueWhenInState(this._resolve, this._state);

  @override
  ResolverType? resolve(states) {
    if (states.contains(_state)) {
      return _resolve();
    }

    return null;
  }
}
