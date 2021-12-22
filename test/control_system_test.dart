import 'package:control_system/control_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnOffControllerBuilder', () {
    testWidgets('basic interaction', (tester) async {
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
  });
}
