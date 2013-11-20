Dart Rational
=============
This project enable to make computations on rational numbers.

## Usage ##
To use this library in your code :
* add a dependency in your `pubspec.yaml` :

```yaml
dependencies:
  rational: '<1.0.0'
```

* add import in your `dart` code :

```dart
import 'package:rational/rational.dart';
```

* Start computing using `Rational.parse('1.23')` or `new Rational(12, 7)`.

## WARNING ##
If you are using this package through dart2js, performances may not be good. This is because dart2js does not implement yet integers with arbitrary precision (see [issue 1533](http://code.google.com/p/dart/issues/detail?id=1533)) and this package contains a custom implementation of _bigint_.

## License ##
Apache 2.0
