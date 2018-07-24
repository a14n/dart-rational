# Dart Rational

[![Build Status](https://travis-ci.org/a14n/dart-rational.svg?branch=master)](https://travis-ci.org/a14n/dart-rational)

This project enable to make computations on rational numbers.

## Usage
To use this library in your code :
* add a dependency in your `pubspec.yaml` :

```yaml
dependencies:
  rational: ^0.3.0
```

### Rational numbers

* add import in your `dart` code :

```dart
import 'package:rational/rational.dart';
```

* Start computing using `Rational.parse('1.23')`,
`Rational(BigInt.from(12), BigInt.from(7))` or `Rational.fromInt(12, 7)`.

## License
Apache 2.0
