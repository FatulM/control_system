# control_system

[![pub](https://img.shields.io/pub/v/control_system.svg?color=blue&label=control_system)](https://pub.dev/packages/control_system)
[![build](https://img.shields.io/github/workflow/status/FatulM/control_system/build?label=build)](https://github.com/FatulM/control_system/actions/workflows/build.yml)
[![coverage](https://img.shields.io/codecov/c/gh/FatulM/control_system?label=coverage)](https://codecov.io/gh/FatulM/control_system)

Flutter control system widgets, like on-off controller.

## Introduction

A control system manages, commands, directs, or regulates the behavior of other devices or systems using control loops.
It can range from a single home heating controller using a thermostat controlling a domestic boiler to large industrial
control systems which are used for controlling processes or machines.

For more info refer to [Control System on Wikipedia](https://en.wikipedia.org/wiki/Control_system).

## Installation

Add it to your `pubspec.yaml` file:

```yaml
dependencies:
  control_system: ^latest.version
```

Then depend on it:

```dart
import 'package:control_system/control_system.dart';
```

## Controllers

These controllers are provided in this package:

### on-off controller

On–off control uses a feedback controller that switches abruptly between two states. A simple bi-metallic domestic
thermostat can be described as an on-off controller. When the temperature in the room (PV) goes below the user setting (
SP), the heater is switched on. Another example is a pressure switch on an air compressor. When the pressure (PV) drops
below the setpoint (SP) the compressor is powered. Refrigerators and vacuum pumps contain similar mechanisms. Simple
on–off control systems like these can be cheap and effective.

For more info refer to [On–Off Controller on Wikipedia](https://en.wikipedia.org/wiki/Bang–bang_control).

`OnOffControllerBuilder` is provided to make an on-off controller widget in Flutter. Refer to dart-docs for more info.

For example:

```
OnOffControllerBuilder(
  initialState: false, /* initial state of controller */
  value: value, /* provide value here, here it comes from a slide between 0.0 and 100.0 */
  lowerLimit: 40.0, /* lower limit */
  upperLimit: 60.0, /* upper limit */
  listener: (state) { /* listen to changes if needed, here it is not needed */ }
  builder: (context, state) { /* build the resulting widget according to state */ }
);
```

![on-off controller example](.images/on-off-controller.gif)
