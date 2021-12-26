import 'package:control_system/control_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnOffControllerBuilder', () {
    group('dart-tests', () {
      test('diagnosis should provide correct information', () {
        final widget = OnOffControllerBuilder(
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
          containsAll([
            'listener: null - has NOT change listener',
            'isResetStateOnBoundaryUpdate: true - resets controller state on widget boundary properties updates',
            'isResetStateOnInitialStateUpdate: true - resets controller state on widget initial state property updates',
            'isCallChangeListenerForInitialState: true - calls change listener for initial state',
            'initialState: false',
            'upperLimit: 60.0',
            'lowerLimit: 40.0',
            'value: 10.0',
          ]),
        );
      });
    });

    group('widget-tests', () {
      late bool isResetStateOnBoundaryUpdate;
      late bool isResetStateOnInitialStateUpdate;
      late bool isCallChangeListenerForInitialState;
      late bool initialState;
      late double value;
      late double lowerLimit;
      late double upperLimit;

      WidgetTester? widgetTester;
      StateSetter? stateSetter;
      OnOffControllerChangeListener? listener;

      setUp(() {
        isResetStateOnBoundaryUpdate = true;
        isResetStateOnInitialStateUpdate = true;
        isCallChangeListenerForInitialState = true;
        initialState = false;
        value = 10.0;
        lowerLimit = 40.0;
        upperLimit = 60.0;

        widgetTester = null;
        stateSetter = null;
        listener = null;
      });

      tearDown(() {
        widgetTester = null;
        stateSetter = null;
        listener = null;
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
                    isCallChangeListenerForInitialState: isCallChangeListenerForInitialState,
                    isResetStateOnBoundaryUpdate: isResetStateOnBoundaryUpdate,
                    isResetStateOnInitialStateUpdate: isResetStateOnInitialStateUpdate,
                    initialState: initialState,
                    value: value,
                    lowerLimit: lowerLimit,
                    upperLimit: upperLimit,
                    listener: listener,
                    builder: (context, state) {
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

      Future<void> check(bool state) async {
        await widgetTester!.pumpAndSettle();
        expect(find.text('state: ${state ? 'on' : 'off'}'), findsOneWidget);
      }

      void update(double newValue) {
        stateSetter!(() => value = newValue);
      }

      testWidgets('basic interaction should work correctly', (tester) async {
        await initialize(tester);

        // value = 10.0
        await check(false);

        update(30.0);
        await check(false);

        update(50.0);
        await check(false);

        update(70.0);
        await check(true);

        update(90.0);
        await check(true);

        update(70.0);
        await check(true);

        update(50.0);
        await check(true);

        update(30.0);
        await check(false);

        update(10.0);
        await check(false);
      });

      testWidgets('state changes should be only on `pass` not on `equal or pass`', (tester) async {
        await initialize(tester);

        // value = 10.0
        await check(false);

        update(50.0);
        await check(false);

        // only on pass:
        update(60.0);
        await check(false);

        update(70.0);
        await check(true);

        update(50.0);
        await check(true);

        // only on pass:
        update(40.0);
        await check(true);

        update(30.0);
        await check(false);
      });
    });
  });
}
