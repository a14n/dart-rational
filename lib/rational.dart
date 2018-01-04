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

final _PATTERN = new RegExp(r"^([+-]?\d+)(\.\d+)?([eE][+-]?\d+)?$");

final _0 = new Rational.fromInt(0);
final _1 = new Rational.fromInt(1);
final _5 = new Rational.fromInt(5);
final _10 = new Rational.fromInt(10);

final _INT_0 = new BigInt.from(0);
final _INT_1 = new BigInt.from(1);
final _INT_2 = new BigInt.from(2);
final _INT_5 = new BigInt.from(5);
final _INT_10 = new BigInt.from(10);
final _INT_31 = new BigInt.from(31);

BigInt _gcd(BigInt a, BigInt b) {
  while (b != _INT_0) {
    final t = b;
    b = a % t;
    a = t;
  }
  return a;
}

class Rational implements Comparable<Rational> {
  static Rational parse(String decimalValue) {
    final match = _PATTERN.firstMatch(decimalValue);
    if (match == null) {
      throw new FormatException("$decimalValue is not a valid format");
    }
    final group1 = match.group(1);
    final group2 = match.group(2);
    final group3 = match.group(3);

    var numerator = _INT_0;
    var denominator = _INT_1;
    if (group2 != null) {
      for (int i = 1; i < group2.length; i++) {
        denominator = denominator * _INT_10;
      }
      numerator = BigInt.parse('${group1}${group2.substring(1)}');
    } else {
      numerator = BigInt.parse(group1);
    }
    if (group3 != null) {
      var exponent = BigInt.parse(group3.substring(1));
      while (exponent > _INT_0) {
        numerator = numerator * _INT_10;
        exponent -= _INT_1;
      }
      while (exponent < _INT_0) {
        denominator = denominator * _INT_10;
        exponent += _INT_1;
      }
    }
    return new Rational(numerator, denominator);
  }

  factory Rational.fromInt(int numerator, [int denominator = 1]) =>
      new Rational(new BigInt.from(numerator), new BigInt.from(denominator));

  factory Rational(BigInt numerator, [BigInt denominator]) {
    denominator ??= _INT_1;
    if (denominator == _INT_0) throw new ArgumentError();
    if (numerator == _INT_0) return new Rational._normalized(_INT_0, _INT_1);
    if (denominator < _INT_0) {
      numerator = -numerator;
      denominator = -denominator;
    }
    final aNumerator = numerator.abs();
    final aDenominator = denominator.abs();
    final gcd = _gcd(aNumerator, aDenominator);
    return (gcd == _INT_1)
        ? new Rational._normalized(numerator, denominator)
        : new Rational._normalized(numerator ~/ gcd, denominator ~/ gcd);
  }
  Rational._normalized(this.numerator, this.denominator);
  // : assert(numerator != null),
  //   assert(denominator != null),
  //   assert(denominator > _INT_0),
  //   assert(_gcd(numerator.abs(), denominator) == _INT_1);

  final BigInt numerator, denominator;

  bool get isInteger => denominator == _INT_1;

  int get hashCode => (numerator + _INT_31 * denominator).hashCode;

  bool operator ==(Object other) =>
      other is Rational &&
      numerator == other.numerator &&
      denominator == other.denominator;

  String toString() {
    if (numerator == _INT_0) return '0';
    if (isInteger)
      return '$numerator';
    else
      return '$numerator/$denominator';
  }

  String toDecimalString() {
    if (isInteger) return toStringAsFixed(0);

    int fractionDigits = hasFinitePrecision ? scale : 10;
    String asString = toStringAsFixed(fractionDigits);
    while (asString.contains('.') &&
        (asString.endsWith('0') || asString.endsWith('.'))) {
      asString = asString.substring(0, asString.length - 1);
    }
    return asString;
  }
  // implementation of Comparable

  int compareTo(Rational other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);

  // implementation of num

  /** Addition operator. */
  Rational operator +(Rational other) => new Rational(
      numerator * other.denominator + other.numerator * denominator,
      denominator * other.denominator);

  /** Subtraction operator. */
  Rational operator -(Rational other) => new Rational(
      numerator * other.denominator - other.numerator * denominator,
      denominator * other.denominator);

  /** Multiplication operator. */
  Rational operator *(Rational other) => new Rational(
      numerator * other.numerator, denominator * other.denominator);

  /** Euclidean modulo operator. */
  Rational operator %(Rational other) {
    final remainder = this.remainder(other);
    if (remainder == _0) return _0;
    return remainder + (isNegative ? other.abs() : _0);
  }

  /** Division operator. */
  Rational operator /(Rational other) => new Rational(
      numerator * other.denominator, denominator * other.numerator);

  /**
   * Truncating division operator.
   *
   * The result of the truncating division [:a ~/ b:] is equivalent to
   * [:(a / b).truncate():].
   */
  Rational operator ~/(Rational other) => (this / other).truncate();

  /** Negate operator. */
  Rational operator -() => new Rational._normalized(-numerator, denominator);

  /** Return the remainder from dividing this [num] by [other]. */
  Rational remainder(Rational other) => this - (this ~/ other) * other;

  /** Relational less than operator. */
  bool operator <(Rational other) => this.compareTo(other) < 0;

  /** Relational less than or equal operator. */
  bool operator <=(Rational other) => this.compareTo(other) <= 0;

  /** Relational greater than operator. */
  bool operator >(Rational other) => this.compareTo(other) > 0;

  /** Relational greater than or equal operator. */
  bool operator >=(Rational other) => this.compareTo(other) >= 0;

  bool get isNaN => false;

  bool get isNegative => numerator < _INT_0;

  bool get isInfinite => false;

  /** Returns the absolute value of this [num]. */
  Rational abs() => isNegative ? (-this) : this;

  /**
   * The signum function value of this [num].
   *
   * E.e. -1, 0 or 1 as the value of this [num] is negative, zero or positive.
   */
  int get signum => compareTo(_0);

  /**
   * Returns the integer value closest to this [num].
   *
   * Rounds away from zero when there is no closest integer:
   *  [:(3.5).round() == 4:] and [:(-3.5).round() == -4:].
   */
  Rational round() {
    final abs = this.abs();
    final absBy10 = abs * _10;
    Rational r = abs.truncate();
    if (absBy10 % _10 >= _5) r += _1;
    return isNegative ? -r : r;
  }

  /** Returns the greatest integer value no greater than this [num]. */
  Rational floor() => isInteger
      ? this.truncate()
      : isNegative ? (this.truncate() - _1) : this.truncate();

  /** Returns the least integer value that is no smaller than this [num]. */
  Rational ceil() => isInteger
      ? this.truncate()
      : isNegative ? this.truncate() : (this.truncate() + _1);

  /**
   * Returns the integer value obtained by discarding any fractional
   * digits from this [num].
   */
  Rational truncate() =>
      new Rational._normalized(numerator ~/ denominator, _INT_1);

  /**
   * Returns the integer value closest to `this`.
   *
   * Rounds away from zero when there is no closest integer:
   *  [:(3.5).round() == 4:] and [:(-3.5).round() == -4:].
   *
   * The result is a double.
   */
  double roundToDouble() => round().toDouble();

  /**
   * Returns the greatest integer value no greater than `this`.
   *
   * The result is a double.
   */
  double floorToDouble() => floor().toDouble();

  /**
   * Returns the least integer value no smaller than `this`.
   *
   * The result is a double.
   */
  double ceilToDouble() => ceil().toDouble();

  /**
   * Returns the integer obtained by discarding any fractional
   * digits from `this`.
   *
   * The result is a double.
   */
  double truncateToDouble() => truncate().toDouble();

  /**
   * Clamps [this] to be in the range [lowerLimit]-[upperLimit]. The comparison
   * is done using [compareTo] and therefore takes [:-0.0:] into account.
   */
  Rational clamp(Rational lowerLimit, Rational upperLimit) =>
      this < lowerLimit ? lowerLimit : this > upperLimit ? upperLimit : this;

  /**
   * Truncates this [num] to an integer and returns the result as an [int].
   */
  int toInt() => toBigInt().toInt();

  /**
   * Truncates this [num] to a big integer and returns the result as an [BigInt].
   */
  BigInt toBigInt() => numerator ~/ denominator;

  /**
   * Return this [num] as a [double].
   *
   * If the number is not representable as a [double], an
   * approximation is returned. For numerically large integers, the
   * approximation may be infinite.
   */
  double toDouble() => numerator / denominator;

  /**
   * Inspect if this [num] has a finite precision.
   */
  bool get hasFinitePrecision {
    // the denominator should only be a product of powers of 2 and 5
    var den = denominator;
    while (den % _INT_5 == _INT_0) den = den ~/ _INT_5;
    while (den % _INT_2 == _INT_0) den = den ~/ _INT_2;
    return den == _INT_1;
  }

  /**
   * The precision of this [num].
   *
   * The sum of the number of digits before and after the decimal point.
   * **WARNING for dart2js** : It can give bad result for large number.
   *
   * Throws [StateError] if the precision is infinite,
   * i.e. when [hasFinitePrecision] is [false].
   */
  int get precision {
    if (!hasFinitePrecision) {
      throw new StateError("This number has an infinite precision: $this");
    }
    var x = numerator;
    while (x % denominator != _INT_0) x *= _INT_10;
    x = x ~/ denominator;
    return x.abs().toString().length;
  }

  /**
   * The scale of this [num].
   *
   * The number of digits after the decimal point.
   * **WARNING for dart2js** : It can give bad result for large number.
   *
   * Throws [StateError] if the scale is infinite,
   * i.e. when [hasFinitePrecision] is [false].
   */
  int get scale {
    if (!hasFinitePrecision) {
      throw new StateError("This number has an infinite precision: $this");
    }
    var i = 0;
    var x = numerator;
    while (x % denominator != _INT_0) {
      i++;
      x *= _INT_10;
    }
    return i;
  }

  /**
   * Converts a [num] to a string representation with [fractionDigits]
   * digits after the decimal point.
   */
  String toStringAsFixed(int fractionDigits) {
    if (fractionDigits == 0) {
      return round().toBigInt().toString();
    } else {
      var mul = _INT_1;
      for (int i = 0; i < fractionDigits; i++) mul *= _INT_10;
      final mulRat = new Rational(mul);
      final lessThanOne = abs() < _1;
      final tmp = (lessThanOne ? (abs() + _1) : abs()) * mulRat;
      final tmpRound = tmp.round();
      final intPart =
          (lessThanOne ? ((tmpRound ~/ mulRat) - _1) : (tmpRound ~/ mulRat))
              .toBigInt();
      final decimalPart =
          tmpRound.toBigInt().toString().substring(intPart.toString().length);
      return '${isNegative ? '-' : ''}${intPart}.${decimalPart}';
    }
  }

  /**
   * Converts a [num] to a string in decimal exponential notation with
   * [fractionDigits] digits after the decimal point.
   */
  String toStringAsExponential([int fractionDigits]) =>
      toDouble().toStringAsExponential(fractionDigits);

  /**
   * Converts a [num] to a string representation with [precision]
   * significant digits.
   */
  String toStringAsPrecision(int precision) =>
      toDouble().toStringAsPrecision(precision);
}
