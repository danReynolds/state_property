A library that implements the State Property pattern for resolving the behavior of systems based on their current states. An existing example of this pattern includes the [Material State Property](https://api.flutter.dev/flutter/material/MaterialStateProperty-class.html) used by the Flutter library.

In the example from Flutter, a [TextButton](https://api.flutter.dev/flutter/material/TextButton-class.html) can resolve its styling based on whether it's in one or more states like *hovered*, *pressed* or *focused*.

```dart
TextButton(
    onPressed: () {},
    child: const Text('TextButton'),
    style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed) || states.contains(MaterialState.hovered)) {
                return Colors.blue;
            }
            return Colors.grey;
        }),
    )
);
```

## Usage 1: Generic Loading States

Suppose we have a system that can be in 3 states: *pending*, *success* and *fail*. These set of states can describe any system that can take on a task and have it work or fail, such as an API call made over a network or reading data from a file system. Each state will have corresponding behavior, which we can codify with state properties as shown below:

```dart
import 'package:state_property/state_property.dart';

enum LoadingStates {
  loading,
  success,
  fail,
}

abstract class LoadingStateProperty<ResolverType>
    implements StateProperty<LoadingStates, ResolverType> {
  @override
  ResolverType? resolve(Set<LoadingStates> states);

  static StateProperty<LoadingStates, ResolverType> loading<ResolverType>(
        StatelessResolver<ResolverType> resolver) =>
    StateProperty.resolveState<LoadingStates, ResolverType>(
      resolver,
      LoadingStates.loading,
    );

  static StateProperty<LoadingStates, ResolverType> success<ResolverType>(
        StatelessResolver<ResolverType> resolver) =>
     StateProperty.resolveState<LoadingStates, ResolverType>(
      resolver,
      LoadingStates.success,
    );

  static StateProperty<LoadingStates, ResolverType> fail<ResolverType>(
        StatelessResolver<ResolverType> resolver) =>
     StateProperty.resolveState<LoadingStates, ResolverType>(
      resolver,
      LoadingStates.fail,
    );

  static StateProperty<LoadingStates, ResolverType> resolveWith<ResolverType>(
        StatefulResolver<LoadingStates, ResolverType> resolver) =>
    StateProperty.resolveWith<LoadingStates, ResolverType>(
      resolver,
    );

  static StateProperty<LoadingStates, ResolverType> all<ResolverType>(
        StatelessResolver<ResolverType> resolver) =>
    StateProperty.all<LoadingStates, ResolverType>(
      resolver,
    );

  static StateProperty<LoadingStates, Null> never<ResolverType>(
        StatelessResolver<ResolverType> resolver) =>
    StateProperty.never();
}
```

Our `LoadingStatePropery` class implements the `StateProperty` interface provided by the library to define a system that can be in any of our three loading states. It reuses the 4 core state properties from the library to build its loading state properties:

1. [resolveWith]() - The most flexible state property that allows for dynamically resolving behavior based on the provided set of states.

  ```dart
  final isLoadingStateProperty = LoadingStateProperty.resolveWith<bool>((states) {
    return states.contains(LoadingStates.loading);
  });

  isLoadingStateProperty.resolve({LoadingStates.loading}); // true
  isLoadingStateProperty.resolve({LoadingStates.success}); // false
  ```

2. [resolveState]() - Resolves the given behavior when in the provided state, otherwise `null`.

  ```dart
  final successStateProperty = LoadingStateProperty.resolveWith<bool>(() {
    return true;
  }, LoadingStates.done);

  successStateProperty.resolve({LoadingStates.done}); // true
  successStateProperty.resolve({LoadingStates.loading}); // false
  ```

3. [all]() - Resolves the given behavior independent of the current state of the system.

  ```dart
  final trueStateProperty = LoadingStateProperty.all<bool>(() {
    return true;
  });

  trueStateProperty.resolve({LoadingStates.done}); // true
  trueStateProperty.resolve({LoadingStates.loading}); // true
  ```

4. [never]() Resolves `null` as the behavior independent of the current state of the system.

  ```dart
  final nullStateProperty = LoadingStateProperty.all<bool>(() {
    return true;
  });

  nullStateProperty.resolve({LoadingStates.done}); // null
  nullStateProperty.resolve({LoadingStates.loading}); // null
  ```

## Usage 2: Using Loading States in Widgets

Now that we've built a state property that describes of loading states, we can apply it to a Flutter widget that supports different builders based on the current loading state.

```dart
import 'package:flutter/material.dart';
import './loading_state_property.dart';

class Loader extends StatefulWidget {
  final Future<void> Function() load;
  LoadingStateProperty<Widget> builder;

  @override
}

class _LoaderState extends State<_LoaderState> {
  LoadingState _state;

  @override
  initState() {
    super.initState();

    // Kick off loading data when the widget is first built.
    _state = LoadingStates.loading;
    widget.load().then((_resp) {
      setState(() {
        _state = LoadingStates.success;
      })
    }).catchError((e) {
      setState(() {
        _state = LoadingStates.fail;
      });
    });
  }

  @override
  build(context) {
    return widget.builder.resolve(_state) ?? SizedBox();
  }
}

// A widget that has different loading behavior based on the loading state.
class MyLoadingWidget extends StatelessWidget {
  @override
  build(context) {
    return Loader(
      builder: LoadingStateProperty.resolveWith<Widget>((states) {
        if (states.contains(LoadingStates.success)) {
          return Text('Done!');
        }

        if (states.contains(LoadingStates.fail)) {
          return Text('Something went wrong');
        }

        return const CircularProgressIndicator();
      });
    )
  }
}

// A widget that only has UI when the loading has finished successfully.
class SuccessfulLoadingWidget extends StatelessWidget {
  @override
  build(context) {
    return Loader(
      builder: LoadingStateProperty.resolveState<Widget>(() => Text('Done!'), LoadingStates.success);
    )
  }
}
```





