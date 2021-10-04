// ignore_for_file: prefer_void_to_null

import 'package:flutter_test/flutter_test.dart';

import 'package:state_property/state_property.dart';

enum TestStates {
  initial,
  loading,
  done,
}

abstract class TestStateProperty<ResolverType>
    implements StateProperty<TestStates, ResolverType> {
  @override
  ResolverType? resolve(Set<TestStates> states);

  static StateProperty<TestStates, ResolverType> loading<ResolverType>(
          StatelessResolver<ResolverType> resolver) =>
      StateProperty.resolveState<TestStates, ResolverType>(
        resolver,
        TestStates.loading,
      );

  static StateProperty<TestStates, ResolverType> resolveWith<ResolverType>(
          StatefulResolver<TestStates, ResolverType> resolver) =>
      StateProperty.resolveWith<TestStates, ResolverType>(
        resolver,
      );

  static StateProperty<TestStates, ResolverType> all<ResolverType>(
          StatelessResolver<ResolverType> resolver) =>
      StateProperty.all<TestStates, ResolverType>(
        resolver,
      );

  static StateProperty<TestStates, Null> never() => StateProperty.never();
}

void main() {
  group('StateProperty', () {
    group('#resolveWith', () {
      test('resolves true when in a given state', () {
        final stateProperty = TestStateProperty.resolveWith<bool>((states) {
          return states.contains(TestStates.initial);
        });

        expect(
          stateProperty.resolve({
            TestStates.initial,
          }),
          true,
        );
      });

      test('resolves false when not in a given state', () {
        final stateProperty = TestStateProperty.resolveWith<bool>((states) {
          return states.contains(TestStates.initial);
        });

        expect(
          stateProperty.resolve({
            TestStates.loading,
          }),
          false,
        );
      });
    });

    group('#resolveState', () {
      test('resolves true when in the given state', () {
        final stateProperty = TestStateProperty.loading<bool>(() {
          return true;
        });

        expect(
          stateProperty.resolve({
            TestStates.loading,
          }),
          true,
        );
      });

      test('resolves null when not in the given state', () {
        final stateProperty = TestStateProperty.loading<bool>(() {
          return true;
        });

        expect(
          stateProperty.resolve({
            TestStates.done,
          }),
          null,
        );
      });
    });

    group('#all', () {
      test('resolves true for any given states', () {
        final stateProperty = TestStateProperty.all<bool>(() {
          return true;
        });

        expect(
          stateProperty.resolve({}),
          true,
        );
      });
    });

    group('#never', () {
      test('resolves null for any given states', () {
        final stateProperty = TestStateProperty.never();

        expect(
          stateProperty.resolve({}),
          null,
        );
      });
    });
  });
}
