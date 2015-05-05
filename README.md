# Dart Rational

[![Build Status](https://travis-ci.org/a14n/dart-rational.svg?branch=master)](https://travis-ci.org/a14n/dart-rational)

This project enable to make computations on rational numbers.
The package also contains an implementation of _arbitrarily sized integer_ that works with dart2js.

## Usage
To use this library in your code :
* add a dependency in your `pubspec.yaml` :

```yaml
dependencies:
  rational: ^0.1.8
```

### Rational numbers

* add import in your `dart` code :

```dart
import 'package:rational/rational.dart';
```

* Start computing using `Rational.parse('1.23')` or `new Rational(12, 7)`.

### BigInt numbers

* add import in your `dart` code :

```dart
import 'package:rational/bigint.dart';
```

* Start computing using `BigInt.parse('12345678901234567890')`.

## License
Apache 2.0
