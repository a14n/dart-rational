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

## Limitation ##
**WARNING** : If you are using this package through dart2js, results may not be good. This is because dart2js does not implement yet integers with arbitrary precision. Once [issue 1533](http://code.google.com/p/dart/issues/detail?id=1533) fixed, you should be able to use it in javascript.

## License ##
Apache 2.0
