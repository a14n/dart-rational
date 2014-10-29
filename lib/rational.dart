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

import 'package:rational/bigint.dart';

final IS_JS = identical(1, 1.0);

final _PATTERN = new RegExp(r"^([+-]?\d+)(\.\d+)?([eE][+-]?\d+)?$");

final _0 = new Rational(0);
final _1 = new Rational(1);
final _5 = new Rational(5);
final _10 = new Rational(10);

_int(int value) => IS_JS ? new BigInt.fromJsInt(value) : value;
final _INT_0 = _int(0);
final _INT_1 = _int(1);
final _INT_2 = _int(2);
final _INT_5 = _int(5);
final _INT_10 = _int(10);
final _INT_31 = _int(31);

_parseInt(String text) => IS_JS ? BigInt.parse(text) : int.parse(text);

_gcd(a, b) {
  while (b != _INT_0) {
    var t = b;
    b = a % t;
    a = t;
  }
  return a;
}

abstract class Rational<T extends dynamic/*int|BigInt*/> implements Comparable<Rational> {
  static Rational parse(String decimalValue) {
    final match = _PATTERN.firstMatch(decimalValue);
    if (match == null) throw new FormatException("$decimalValue is not a valid format");
    final group1 = match.group(1);
    final group2 = match.group(2);
    final group3 = match.group(3);

    var numerator = _INT_0;
    var denominator = _INT_1;
    if (group2 != null) {
      for (int i = 1; i < group2.length; i++) {
        denominator = denominator * _INT_10;
      }
      numerator = _parseInt('${group1}${group2.substring(1)}');
    } else {
      numerator = _parseInt(group1);
    }
    if(group3 != null) {
      var exponent = _parseInt(group3.substring(1));
      while(exponent > 0) {
        numerator = numerator * _INT_10;
        exponent--;
      }
      while(exponent < 0) {
        denominator = denominator * _INT_10;
        exponent++;
      }
    }
    return new Rational._normalize(numerator, denominator);
  }

  final T _numerator, _denominator;

  Rational._(this._numerator, this._denominator);

  factory Rational._normalized(numerator, denominator) => IS_JS ?
      new _RationalJs._normalized(numerator, denominator) :
        new _RationalVM._normalized(numerator, denominator);

  factory Rational(int numerator, [int denominator = 1]) =>
      new Rational._normalize(_int(numerator), _int(denominator));

  factory Rational._normalize(numerator, denominator) {
    if (denominator == _INT_0) throw new IntegerDivisionByZeroException();
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

  @Deprecated('can give bad value with dart2js')
  int get numerator;

  @Deprecated('can give bad value with dart2js')
  int get denominator;

  bool get isInteger => _denominator == _INT_1;

  int get hashCode => (_numerator + _INT_31 * _denominator).hashCode;

  bool operator ==(Object other) => other is Rational
      && _numerator == other._numerator
      && _denominator == other._denominator;

  String toString() {
    if (_numerator == _INT_0) return '0';
    if (isInteger) return '$_numerator';
    else return '$_numerator/$_denominator';
  }

  String toDecimalString() {
    if (isInteger) return toStringAsFixed(0);

    int fractionDigits = hasFinitePrecision ? scale : 10;
    String asString = toStringAsFixed(fractionDigits);
    while (asString.contains('.') && (asString.endsWith('0') || asString.endsWith('.'))) {
      asString = asString.substring(0, asString.length - 1);
    }
    return asString;
  }
  // implementation of Comparable

  int compareTo(Rational other) => (_numerator * other._denominator).compareTo(other._numerator * _denominator);

  // implementation of num

  /** Addition operator. */
  Rational operator +(Rational other) => new Rational._normalize(_numerator * other._denominator + other._numerator * _denominator, _denominator * other._denominator);

  /** Subtraction operator. */
  Rational operator -(Rational other) => new Rational._normalize(_numerator * other._denominator - other._numerator * _denominator, _denominator * other._denominator);

  /** Multiplication operator. */
  Rational operator *(Rational other) => new Rational._normalize(_numerator * other._numerator, _denominator * other._denominator);

  /** Euclidean modulo operator. */
  Rational operator %(Rational other) => this.remainder(other) + (isNegative ? other.abs() : _0);

  /** Division operator. */
  Rational operator /(Rational other) => new Rational._normalize(_numerator * other._denominator, _denominator * other._numerator);

  /**
   * Truncating division operator.
   *
   * The result of the truncating division [:a ~/ b:] is equivalent to
   * [:(a / b).truncate():].
   */
  Rational operator ~/(Rational other) => (this / other).truncate();

  /** Negate operator. */
  Rational operator -() => new Rational._normalized(-_numerator, _denominator);

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

  bool get isNegative => _numerator < _INT_0;

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
    final absBy10 =  abs * _10;
    Rational r;
    if (absBy10 % _10 < _5) {
      r = abs.truncate();
    } else {
      r = abs.truncate() + _1;
    }
    return isNegative ? -r : r;
  }

  /** Returns the greatest integer value no greater than this [num]. */
  Rational floor() => isInteger ? this.truncate() : isNegative ? (this.truncate() - _1) : this.truncate();

  /** Returns the least integer value that is no smaller than this [num]. */
  Rational ceil() => isInteger ? this.truncate() : isNegative ? this.truncate() : (this.truncate() + _1);

  /**
   * Returns the integer value obtained by discarding any fractional
   * digits from this [num].
   */
  Rational truncate() => new Rational._normalized(_toInt(), _INT_1);

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
  Rational clamp(Rational lowerLimit, Rational upperLimit) => this < lowerLimit ? lowerLimit : this > upperLimit ? upperLimit : this;

  /** Truncates this [num] to an integer and returns the result as an [int]. */
  int toInt();

  T _toInt() => _numerator ~/ _denominator;

  /**
   * Return this [num] as a [double].
   *
   * If the number is not representable as a [double], an
   * approximation is returned. For numerically large integers, the
   * approximation may be infinite.
   */
  double toDouble();

  /**
   * Inspect if this [num] has a finite precision.
   */
  bool get hasFinitePrecision {
    // the denominator should only be a product of powers of 2 and 5
    var den = _denominator;
    while(den % _INT_5 == _INT_0)
      den = den ~/ _INT_5;
    while(den % _INT_2 == _INT_0)
      den = den ~/ _INT_2;
    return den == 1;
  }

  /**
   * The precision of this [num].
   *
   * The sum of the number of digits before and after
   * the decimal point.
   *
   * Throws [StateError] if the precision is infinite,
   * i.e. when [hasFinitePrecision] is [false].
   */
  int get precision {
    if(!hasFinitePrecision)
      throw new StateError("This number has an infinite precision: $this");
    var x = _numerator;
    while(x % _denominator != _INT_0) {
      x = x * _INT_10;
    }
    x = x ~/ _denominator;
    return x.toString().length;
  }

  /**
   * The scale of this [num].
   *
   * The number of digits after the decimal point.
   *
   * Throws [StateError] if the scale is infinite,
   * i.e. when [hasFinitePrecision] is [false].
   */
  int get scale {
    if(!hasFinitePrecision)
      throw new StateError("This number has an infinite precision: $this");
    var i = 0;
    var x = _numerator;
    while(x % _denominator != _INT_0) {
      i++;
      x = x * _INT_10;
    }
    return i;
  }

  /**
   * Converts a [num] to a string representation with [fractionDigits]
   * digits after the decimal point.
   */
  String toStringAsFixed(int fractionDigits) {
    if (fractionDigits == 0) {
      return round()._toInt().toString();
    } else {
      var mul = _INT_1;
      for (int i = 0; i < fractionDigits; i++) {
        mul *= _INT_10;
      }
      final mulRat = new Rational._normalize(mul, _INT_1);
      final lessThanOne = abs() < _1;
      final tmp = (lessThanOne ? (abs() + _1) : abs()) * mulRat;
      final tmpRound = tmp.round();
      final intPart = (lessThanOne ? ((tmpRound ~/ mulRat) - _1) : (tmpRound ~/ mulRat))._toInt();
      final decimalPart = tmpRound._toInt().toString().substring(intPart.toString().length);
      return '${isNegative ? '-' : ''}${intPart}.${decimalPart}';
    }
  }

  /**
   * Converts a [num] to a string in decimal exponential notation with
   * [fractionDigits] digits after the decimal point.
   */
  String toStringAsExponential([int fractionDigits])  => toDouble().toStringAsExponential(fractionDigits);

  /**
   * Converts a [num] to a string representation with [precision]
   * significant digits.
   */
  String toStringAsPrecision(int precision) => toDouble().toStringAsPrecision(precision);
}

class _RationalJs extends Rational<BigInt> {
  _RationalJs._normalized(BigInt numerator, BigInt denominator) :
    super._(numerator, denominator);

  int get numerator => int.parse('$_numerator');
  int get denominator => int.parse('$_denominator');
  int toInt() => int.parse(_toInt().toString());
  double toDouble() => double.parse('$_numerator') / double.parse('$_denominator');
}

class _RationalVM extends Rational<int> {
  _RationalVM._normalized(int numerator, int denominator) :
    super._(numerator, denominator);

  int get numerator => _numerator;
  int get denominator => _denominator;
  int toInt() => _numerator ~/ _denominator;
  double toDouble() => _numerator / _denominator;
}
