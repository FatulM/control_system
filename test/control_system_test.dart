import 'package:control_system/control_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnOffControllerBuilder', () {
    group('dart-tests', () {
      test('diagnosis should provide correct information', () {
        final widget = OnOffControllerBuilder(
          isResetStateOnInitialStateUpdate: true,
          isResetStateOnBoundaryUpdate: true,
          isCallChangeListenerForInitialState: true,
          initialState: false,
          upperLimit: 60.0,
          lowerLimit: 40.0,
          value: 10.0,
          builder: (context, state) => Container(),
        );
        final element = widget.createElement();
        final state = element.state;
        final diagnosticsNode = state.toDiagnosticsNode();
        final properties = diagnosticsNode.getProperties();

        expect(
          properties.map((e) => e.toStringDeep()).toList(),
          containsAll(<String>[
            'listener: null - has NOT change listener',
            'isResetStateOnBoundaryUpdate: true - resets controller '
                'state on widget boundary properties updates',
            'isResetStateOnInitialStateUpdate: true - resets controller '
                'state on widget initial state property updates',
            'isCallChangeListenerForInitialState: true - calls change '
                'listener for initial state',
            'initialState: false',
            'upperLimit: 60.0',
            'lowerLimit: 40.0',
            'value: 10.0',
          ]),
        );
      });
    });

    group('flutter-tests', () {
      late bool resetOnBounds;
      late bool resetOnInitial;
      late bool callForInitial;
      late bool initialState;
      late double value;
      late double lowerLimit;
      late double upperLimit;

      WidgetTester? widgetTester;
      StateSetter? stateSetter;
      OnOffControllerChangeListener? listener;

      List<bool>? states;

      setUp(() {
        resetOnBounds = true;
        resetOnInitial = true;
        callForInitial = true;
        initialState = false;
        value = 10.0;
        lowerLimit = 40.0;
        upperLimit = 60.0;

        widgetTester = null;
        stateSetter = null;
        listener = null;

        states = null;
      });

      tearDown(() {
        widgetTester = null;
        stateSetter = null;
        listener = null;

        states = null;
      });

      Future<void> initialize(WidgetTester tester) async {
        widgetTester = tester;

        await widgetTester!.pumpWidget(
          MaterialApp(
            title: 'Testing',
            theme: ThemeData.light(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  stateSetter = setState;

                  return OnOffControllerBuilder(
                    isCallChangeListenerForInitialState: callForInitial,
                    isResetStateOnBoundaryUpdate: resetOnBounds,
                    isResetStateOnInitialStateUpdate: resetOnInitial,
                    initialState: initialState,
                    value: value,
                    lowerLimit: lowerLimit,
                    upperLimit: upperLimit,
                    listener: listener,
                    builder: (BuildContext context, bool state) {
                      return Center(
                        child: Text(
                          'state: ${state ? 'on' : 'off'}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      }

      Future<void> settle() async {
        await widgetTester!.pumpAndSettle();
      }

      Future<void> check(bool state) async {
        await settle();
        expect(find.text('state: ${state ? 'on' : 'off'}'), findsOneWidget);
      }

      void update(VoidCallback fn) {
        stateSetter!(fn);
      }

      void updateValue(double newValue) {
        update(() => value = newValue);
      }

      void registerChangeListener() {
        states = [];
        listener = (state) {
          states!.add(state);
        };
      }

      testWidgets(
        'given default configuration then '
        'basic interaction should work correctly',
        (tester) async {
          await initialize(tester);

          // value = 10.0
          await check(false);

          updateValue(30.0);
          await check(false);

          updateValue(50.0);
          await check(false);

          updateValue(70.0);
          await check(true);

          updateValue(90.0);
          await check(true);

          updateValue(70.0);
          await check(true);

          updateValue(50.0);
          await check(true);

          updateValue(30.0);
          await check(false);

          updateValue(10.0);
          await check(false);
        },
      );

      testWidgets(
        'state changes should be only on `pass` not on `equal or pass`',
        (tester) async {
          await initialize(tester);

          // value = 10.0
          await check(false);

          updateValue(50.0);
          await check(false);

          // only on pass:
          updateValue(60.0);
          await check(false);

          updateValue(70.0);
          await check(true);

          updateValue(50.0);
          await check(true);

          // only on pass:
          updateValue(40.0);
          await check(true);

          updateValue(30.0);
          await check(false);
        },
      );

      testWidgets(
        'given if we should call change listener for initial state then '
        'listener should capture all state changes with initial state',
        (tester) async {
          callForInitial = true;
          registerChangeListener();

          await initialize(tester);

          await check(false);
          updateValue(90.0);
          await check(true);
          updateValue(10.0);
          await check(false);

          expect(
            states,
            equals(<bool>[
              false,
              true,
              false,
            ]),
          );
        },
      );

      testWidgets(
        'given if we should NOT call change listener for initial state then '
        'listener should capture all state changes WITHOUT initial state',
        (tester) async {
          callForInitial = false;
          registerChangeListener();

          await initialize(tester);

          await check(false);
          updateValue(90.0);
          await check(true);
          updateValue(10.0);
          await check(false);

          expect(
            states,
            equals(<bool>[
              true,
              false,
            ]),
          );
        },
      );

      testWidgets(
        'given reset on initial state change enabled then '
        'should reset state if initial state changes',
        (tester) async {
          callForInitial = true;
          resetOnInitial = true;
          registerChangeListener();

          await initialize(tester);

          await settle();
          update(() => initialState = true);
          await settle();

          expect(
            states,
            equals(<bool>[
              false,
              // should be changed immediately back and forth:
              true,
              false,
            ]),
          );
        },
      );

      testWidgets(
        'given reset on initial state change enabled then '
        'should reset state if initial state changes '
        'and also we change value to match changed initial state',
        (tester) async {
          callForInitial = true;
          resetOnInitial = true;
          registerChangeListener();

          await initialize(tester);

          await settle();
          update(() => initialState = true);
          updateValue(90);
          await settle();

          expect(
            states,
            equals(<bool>[
              false,
              // should be not oscillate:
              true,
            ]),
          );
        },
      );

      testWidgets(
        'given reset on initial state change NOT enabled then '
        'should NOT reset state if initial state changes',
        (tester) async {
          callForInitial = true;
          resetOnInitial = false;
          registerChangeListener();

          await initialize(tester);

          await settle();
          update(() => initialState = true);
          await settle();

          expect(
            states,
            equals(<bool>[
              false,
            ]),
          );
        },
      );

      testWidgets(
        'given reset on boundary update is enabled then '
        'should reset state if initial state changes '
        'and also we change value to match changed initial state',
        (tester) async {
          callForInitial = true;
          resetOnInitial = false;
          resetOnBounds = true;
          registerChangeListener();

          await initialize(tester);

          // 1:
          await settle();
          updateValue(90);
          await settle();

          // 2:
          update(() => upperLimit = 70.0);
          await settle();

          // 3:
          update(() => lowerLimit = 30.0);
          await settle();

          expect(
            states,
            equals(<bool>[
              // 1:
              false,
              true,
              // 2: should oscillate:
              false,
              true,
              // 3: should oscillate:
              false,
              true,
            ]),
          );
        },
      );

      testWidgets(
        'given reset on boundary update is NOT enabled then '
        'should reset state if initial state changes '
        'and also we change value to match changed initial state',
        (tester) async {
          callForInitial = true;
          resetOnInitial = false;
          resetOnBounds = false;
          registerChangeListener();

          await initialize(tester);

          // 1:
          await settle();
          updateValue(90);
          await settle();

          // 2:
          update(() => upperLimit = 70.0);
          await settle();

          // 3:
          update(() => lowerLimit = 30.0);
          await settle();

          expect(
            states,
            equals(<bool>[
              // 1:
              false,
              true,
              // 2,3: nothing
            ]),
          );
        },
      );
    });
  });
}
