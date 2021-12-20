import 'package:control_system/control_system.dart';
import 'package:flutter/material.dart';

class OnOffControllerExample extends StatelessWidget {
  const OnOffControllerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('on-off controller'),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  var _value = 10.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'start = 0.0\n'
            'lower-limit = 40.0\n'
            'lower-limit = 60.0\n'
            'end = 100.0',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              'value: ${_value.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _value,
            onChanged: (value) {
              setState(() {
                _value = value;
              });
            },
            min: 0.0,
            max: 100.0,
          ),
          const SizedBox(height: 32),
          OnOffControllerBuilder(
            value: _value,
            upperLimit: 60.0,
            lowerLimit: 40.0,
            initialState: false,
            builder: (context, state) {
              return Container(
                height: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: state ? Colors.yellow : Colors.grey,
                ),
                alignment: Alignment.center,
                child: Text(
                  state ? 'ON' : 'OFF',
                  style: const TextStyle(
                    fontSize: 28,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
