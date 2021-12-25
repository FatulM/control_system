import 'package:control_system/control_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnOffControllerBuilder', () {
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
          'isResetStateOnUpdate: true - resets controller state on widget updates',
          'isCallChangeListenerForInitialState: true - calls change listener for initial state',
          'initialState: false',
          'upperLimit: 60.0',
          'lowerLimit: 40.0',
          'value: 10.0',
        ]),
      );
    });

    testWidgets('basic interaction should work correctly', (tester) async {
      double _value = 10.0;
      late StateSetter _updater;

      Future<void> check(bool state) async {
        await tester.pumpAndSettle();
        expect(find.text('state: ${state ? 'on' : 'off'}'), findsOneWidget);
      }

      void update(double newValue) {
        _updater(() => _value = newValue);
      }

      await tester.pumpWidget(
        MaterialApp(
          title: 'Testing',
          theme: ThemeData.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                _updater = setState;

                return OnOffControllerBuilder(
                  initialState: false,
                  value: _value,
                  lowerLimit: 40.0,
                  upperLimit: 60.0,
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
      double _value = 10.0;
      late StateSetter _updater;

      Future<void> check(bool state) async {
        await tester.pumpAndSettle();
        expect(find.text('state: ${state ? 'on' : 'off'}'), findsOneWidget);
      }

      void update(double newValue) {
        _updater(() => _value = newValue);
      }

      await tester.pumpWidget(
        MaterialApp(
          title: 'Testing',
          theme: ThemeData.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                _updater = setState;

                return OnOffControllerBuilder(
                  initialState: false,
                  value: _value,
                  lowerLimit: 40.0,
                  upperLimit: 60.0,
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
}
