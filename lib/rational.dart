// Copyright (c) 2013, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library rational;

final _pattern = RegExp(r'^([+-]?\d*)(\.\d*)?([eE][+-]?\d+)?$');

final _r0 = Rational.zero;
final _r5 = Rational.fromInt(5);
final _r10 = Rational.fromInt(10);

final _i0 = BigInt.zero;
final _i1 = BigInt.one;
final _i10 = BigInt.from(10);

BigInt _gcd(BigInt a, BigInt b) {
  while (b != _i0) {
    final t = b;
    b = a % b;
    a = t;
  }
  return a;
}

/// A number that can be expressed as a fraction of two integers, a [numerator]
/// and a non-zero [denominator].
///
/// This fraction is stored in its canonical form. The canonical form is the
/// rational number expressed in a unique way as an irreducible fraction a/b,
/// where a and b are coprime integers and b > 0.
///
/// `Rational(2, 4)` corresponding to `2/4` will be created with its canonical
/// form `1/2`. That means `Rational(2, 4).numerator` will be equal to `1` and
/// `Rational(2, 4).denominator` equal to `2`.
class Rational implements Comparable<Rational> {
  /// Create a new rational number from its [numerator] and a non-zero
  /// [denominator].
  ///
  /// If the [denominator] is omitted then its value will be `1`.
  Rational._fromCanonicalForm(this.numerator, this.denominator)
      : assert(denominator > _i0),
        assert(numerator.abs().gcd(denominator) == _i1);

  /// Create a new rational number from its [numerator] and a non-zero
  /// [denominator].
  ///
  /// If the [denominator] is omitted then its value will be `1`.
  factory Rational(BigInt numerator, [BigInt? denominator]) {
    denominator ??= _i1;
    if (denominator == _i0) {
      throw ArgumentError('zero can not be used as denominator');
    }
    if (numerator == _i0) return Rational._fromCanonicalForm(_i0, _i1);
    if (denominator < _i0) {
      numerator = -numerator;
      denominator = -denominator;
    }
    // TODO(a14n): switch back when https://github.com/dart-lang/sdk/issues/46180 is fixed
    // final gcd = numerator.abs().gcd(denominator.abs());
    final gcd = _gcd(numerator.abs(), denominator.abs());
    return Rational._fromCanonicalForm(numerator ~/ gcd, denominator ~/ gcd);
  }

  /// Create a new rational number from its [numerator] and a non-zero
  /// [denominator].
  ///
  /// If the [denominator] is omitted then its value will be `1`.
  factory Rational.fromInt(int numerator, [int denominator = 1]) =>
      Rational(BigInt.from(numerator), BigInt.from(denominator));

  /// The numerator of this rational number.
  final BigInt numerator;

  /// The denominator of this rational number.
  final BigInt denominator;

  /// Parses [source] as a decimal literal and returns its value as [Rational].
  static Rational parse(String source) {
    final match = _pattern.firstMatch(source);
    if (match == null) {
      throw FormatException('$source is not a valid format');
    }
    final group1 = match.group(1);
    final group2 = match.group(2);
    final group3 = match.group(3);

    var numerator = _i0;
    var denominator = _i1;
    if (group2 != null) {
      for (var i = 1; i < group2.length; i++) {
        denominator = denominator * _i10;
      }
      numerator = BigInt.parse('$group1${group2.substring(1)}');
    } else {
      numerator = BigInt.parse(group1!);
    }
    if (group3 != null) {
      var exponent = int.parse(group3.substring(1));
      if (exponent > 0) {
        numerator *= _i10.pow(exponent);
      }
      if (exponent < 0) {
        denominator *= _i10.pow(exponent.abs());
      }
    }
    return Rational(numerator, denominator);
  }

  /// Parses [source] as a decimal literal and returns its value as [Rational].
  ///
  /// As [parse] except that this method returns `null` if the input is not
  /// valid
  static Rational? tryParse(String source) {
    try {
      return parse(source);
    } on FormatException {
      return null;
    }
  }

  /// The rational number corresponding to `0`.
  static final zero = Rational.fromInt(0);

  /// The rational number corresponding to `1`.
  static final one = Rational.fromInt(1);

  /// Returns `true` if `this` is an integer.
  bool get isInteger => denominator == _i1;

  /// Returns the [Rational] [denominator]/[numerator].
  Rational get inverse => Rational(denominator, numerator);

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  bool operator ==(Object other) =>
      other is Rational &&
      numerator == other.numerator &&
      denominator == other.denominator;

  @override
  String toString() {
    if (numerator == _i0) return '0';
    if (isInteger) {
      return '$numerator';
    } else {
      return '$numerator/$denominator';
    }
  }

  @override
  int compareTo(Rational other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);

  /// Addition operator.
  Rational operator +(Rational other) => Rational(
        numerator * other.denominator + other.numerator * denominator,
        denominator * other.denominator,
      );

  /// Subtraction operator.
  Rational operator -(Rational other) => Rational(
        numerator * other.denominator - other.numerator * denominator,
        denominator * other.denominator,
      );

  /// Multiplication operator.
  Rational operator *(Rational other) => Rational(
        numerator * other.numerator,
        denominator * other.denominator,
      );

  /// Euclidean modulo operator.
  ///
  /// See [num.operator%].
  Rational operator %(Rational other) {
    final remainder = this.remainder(other);
    if (remainder == _r0) return _r0;
    return remainder + (_isNegative ? other.abs() : _r0);
  }

  /// Division operator.
  Rational operator /(Rational other) => Rational(
        numerator * other.denominator,
        denominator * other.numerator,
      );

  /// Truncating division operator.
  ///
  /// See [num.operator~/].
  BigInt operator ~/(Rational other) => (this / other).truncate();

  /// Returns the negative value of this rational.
  Rational operator -() => Rational(-numerator, denominator);

  /// Returns the remainder from dividing this [Rational] by [other].
  Rational remainder(Rational other) =>
      this - (this ~/ other).toRational() * other;

  /// Whether this number is numerically smaller than [other].
  bool operator <(Rational other) => compareTo(other) < 0;

  /// Whether this number is numerically smaller than or equal to [other].
  bool operator <=(Rational other) => compareTo(other) <= 0;

  /// Whether this number is numerically greater than [other].
  bool operator >(Rational other) => compareTo(other) > 0;

  /// Whether this number is numerically greater than or equal to [other].
  bool operator >=(Rational other) => compareTo(other) >= 0;

  bool get _isNegative => numerator < _i0;

  /// Returns the absolute value of `this`.
  Rational abs() => _isNegative ? (-this) : this;

  /// The signum function value of `this`.
  ///
  /// E.e. -1, 0 or 1 as the value of this [Rational] is negative, zero or positive.
  int get signum {
    final v = compareTo(_r0);
    if (v < 0) return -1;
    if (v > 0) return 1;
    return 0;
  }

  /// Returns the [BigInt] value closest to this number.
  ///
  /// Rounds away from zero when there is no closest integer:
  /// `(3.5).round() == 4` and `(-3.5).round() == -4`.
  BigInt round() {
    final abs = this.abs();
    final absBy10 = abs * _r10;
    var r = abs.truncate();
    if (absBy10 % _r10 >= _r5) r += _i1;
    return _isNegative ? -r : r;
  }

  /// Returns the greatest [BigInt] value no greater than this [Rational].
  BigInt floor() => isInteger
      ? truncate()
      : _isNegative
          ? (truncate() - _i1)
          : truncate();

  /// Returns the least [BigInt] value that is no smaller than this [Rational].
  BigInt ceil() => isInteger
      ? truncate()
      : _isNegative
          ? truncate()
          : (truncate() + _i1);

  /// The [BigInt] obtained by discarding any fractional digits from `this`.
  BigInt truncate() => numerator ~/ denominator;

  /// Clamps `this` to be in the range [lowerLimit]-[upperLimit].
  Rational clamp(Rational lowerLimit, Rational upperLimit) => this < lowerLimit
      ? lowerLimit
      : this > upperLimit
          ? upperLimit
          : this;

  /// The [BigInt] obtained by discarding any fractional digits from `this`.
  ///
  /// Equivalent to [truncate].
  BigInt toBigInt() => truncate();

  /// Returns `this` as a [double].
  ///
  /// If the number is not representable as a [double], an approximation is
  /// returned. For numerically large integers, the approximation may be
  /// infinite.
  double toDouble() => numerator / denominator;

  /// Returns `this` to the power of [exponent].
  ///
  /// Returns [one] if the [exponent] equals `0`.
  Rational pow(int exponent) => exponent.isNegative
      ? inverse.pow(-exponent)
      : Rational(
          numerator.pow(exponent),
          denominator.pow(exponent),
        );
}

/// Extensions on [BigInt].
extension BigIntExt on BigInt {
  /// This [BigInt] as a [Rational].
  Rational toRational() => Rational(this);
}

/// Extensions on [int].
extension IntExt on int {
  /// This [int] as a [Rational].
  Rational toRational() => Rational.fromInt(this);
}
