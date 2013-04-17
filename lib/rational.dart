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

import 'package:meta/meta.dart';

final _PATTERN = new RegExp(r"^(-?\d+)(\.\d+)?$");
final _0 = new Rational(0);
final _1 = new Rational(1);
final _5 = new Rational(5);
final _10 = new Rational(10);

int _gcd(int a, int b) {
  while (b != 0) {
    int t = b;
    b = a % t;
    a = t;
  }
  return a;
}

class Rational implements Comparable<Rational> {
  static Rational parse(String decimalValue) {
    final match = _PATTERN.firstMatch(decimalValue);
    if (match == null) throw new FormatException("$decimalValue is not a valid format");
    final group1 = match.group(1);
    final group2 = match.group(2);

    if (group2 != null) {
      int denominator = 1;
      for (int i = 1; i < group2.length; i++) {
        denominator = denominator * 10;
      }
      return new Rational(int.parse('${group1}${group2.substring(1)}'), denominator);
    } else {
      return new Rational(int.parse(group1), 1);
    }
  }

  final int numerator, denominator;

  Rational._normalized(this.numerator, this.denominator);

  factory Rational(int numerator, [int denominator = 1]) {
    if (denominator == 0) throw new IntegerDivisionByZeroException();
    if (numerator == 0) return new Rational._normalized(0, 1);
    if (denominator < 0) {
      numerator = -numerator;
      denominator = -denominator;
    }
    final aNumerator = numerator.abs();
    final aDenominator = denominator.abs();
    final gcd = _gcd(aNumerator, aDenominator);
    return (gcd == 1)
        ? new Rational._normalized(numerator, denominator)
        : new Rational._normalized(numerator ~/ gcd, denominator ~/ gcd);
  }

  bool get isInteger => denominator == 1;

  int get hashCode => numerator + 31 * denominator;

  bool operator ==(Rational other) => numerator == other.numerator && denominator == other.denominator;

  @override String toString() {
    if (numerator == 0) return '0';
    if (denominator == 1) return numerator.toString();
    else return '$numerator/$denominator';
  }

  String toDecimalString() {
    // remove factor 2 and 5 of denominator to know if String representation is finished
    // in decimal system, division by 2 or 5 leads to a finished size of decimal part
    int denominator = this.denominator;
    int fractionDigits = 0;
    while (denominator % 2 == 0) {
      denominator = denominator ~/ 2;
      fractionDigits++;
    }
    while (denominator % 5 == 0) {
      denominator = denominator ~/ 5;
      fractionDigits++;
    }
    final hasLimitedLength = numerator % denominator == 0;
    if (!hasLimitedLength) {
      fractionDigits = 10;
    }
    String asString = toStringAsFixed(fractionDigits);
    while (asString.contains('.') && (asString.endsWith('0') || asString.endsWith('.'))) {
      asString = asString.substring(0, asString.length - 1);
    }
    return asString;
  }
  // implementation of Comparable

  @override int compareTo(Rational other) => (numerator * other.denominator).compareTo(other.numerator * denominator);

  // implementation of num

  /** Addition operator. */
  Rational operator +(Rational other) => new Rational(numerator * other.denominator + other.numerator * denominator, denominator * other.denominator);

  /** Subtraction operator. */
  Rational operator -(Rational other) => new Rational(numerator * other.denominator - other.numerator * denominator, denominator * other.denominator);

  /** Multiplication operator. */
  Rational operator *(Rational other) => new Rational(numerator * other.numerator, denominator * other.denominator);

  /** Euclidean modulo operator. */
  Rational operator %(Rational other) => this.remainder(other) + (isNegative ? other.abs() : _0);

  /** Division operator. */
  Rational operator /(Rational other) => new Rational(numerator * other.denominator, denominator * other.numerator);

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

  bool get isNegative => numerator < 0;

  bool get isInfinite => false;

  /** Returns the absolute value of this [num]. */
  Rational abs() => isNegative ? (-this) : this;

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
  Rational truncate() => new Rational(this.toInt());

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
   * It also implies that [double.NaN] is treated as the maximal double value.
   */
  Rational clamp(Rational lowerLimit, Rational upperLimit) => this < lowerLimit ? lowerLimit : this > upperLimit ? upperLimit : this;

  /** Truncates this [num] to an integer and returns the result as an [int]. */
  int toInt() => numerator ~/ denominator;

  /**
   * Return this [num] as a [double].
   *
   * If the number is not representable as a [double], an
   * approximation is returned. For numerically large integers, the
   * approximation may be infinite.
   */
  double toDouble() => numerator / denominator;

  /**
   * Converts a [num] to a string representation with [fractionDigits]
   * digits after the decimal point.
   */
  String toStringAsFixed(int fractionDigits) {
    if (fractionDigits == 0) {
      return round().toInt().toString();
    } else {
      int mul = 1;
      for (int i = 0; i < fractionDigits; i++) {
        mul *= 10;
      }
      final mulRat = new Rational(mul);
      final tmp = (abs() + _1) * mulRat;
      final tmpRound = tmp.round();
      final intPart = ((tmpRound ~/ mulRat) - _1).toInt();
      final decimalPart = tmpRound.toInt().toString().substring(intPart.toString().length);
      return '${isNegative ? '-' : ''}${intPart}.${decimalPart}';
    }
  }

  /**
   * Converts a [num] to a string in decimal exponential notation with
   * [fractionDigits] digits after the decimal point.
   */
  String toStringAsExponential(int fractionDigits)  => isInteger ? toInt().toStringAsExponential(fractionDigits) : toDouble().toStringAsExponential(fractionDigits);

  /**
   * Converts a [num] to a string representation with [precision]
   * significant digits.
   */
  String toStringAsPrecision(int precision) => isInteger ? toInt().toStringAsPrecision(precision) : toDouble().toStringAsPrecision(precision);
}