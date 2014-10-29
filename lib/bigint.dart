import 'dart:math' show max, min, pow;

final MAX_JS_INT = 9007199254740992;
final MAX_JS_INT_AS_BIG_INT = new BigInt.fromJsInt(MAX_JS_INT);
final _MAX_JS_INT_FOR_ADD = new BigInt.fromJsInt(MAX_JS_INT ~/ 2);
final _BASE = 10000000;
final _BASE_AS_BIG_INT = new BigInt.fromJsInt(_BASE);
final _LOG_BASE = 7;

int _getOr0(List<int> l, int index) => index < l.length ? l[index] : 0;

class _EuclidianDivisionResult {
  final BigInt quotien;
  final BigInt remainder;

  _EuclidianDivisionResult(this.quotien, this.remainder);
}

final _0 = new BigInt.fromJsInt(0);
final _1 = new BigInt.fromJsInt(1);
final _2 = new BigInt.fromJsInt(2);
final _5 = new BigInt.fromJsInt(5);
final _10 = new BigInt.fromJsInt(10);

class BigInt implements Comparable<BigInt> {
  static BigInt parse(String text) {
    bool isPositive = !text.startsWith('-');
    if (text.startsWith(new RegExp('[+-]'))) {
      text = text.substring(1);
    }
    if (!new RegExp(r'^[0-9]+$').hasMatch(text)) throw new FormatException('Invalid integer');
    final value = [];
    while (text.isNotEmpty) {
      final divider = text.length > _LOG_BASE ? text.length - _LOG_BASE : 0;
      value.add(int.parse(text.substring(divider)));
      text = text.substring(0, divider);
    }
    return new BigInt(value, isPositive);
  }

  final List<int> value;
  final bool isPositive;

  BigInt(this.value, this.isPositive) {
    // remove last 0
    for (int i = value.length - 1; i >= 0; i--) {
      if (value[i] == 0) {
        value.removeLast();
      } else break;
    }
  }

  factory BigInt.fromJsInt(int intValue) {
    int a = intValue.abs();
    final isPositive = intValue >= 0;
    if (a < _BASE) return new BigInt([a], isPositive);
    final value = [];
    while (a > 0) {
      value.add(a % _BASE);
      a = a ~/ _BASE;
    }
    return new BigInt(value, isPositive);
  }

  bool get isNegative => !isPositive;

  bool get is0 => value.isEmpty;
  bool get is1 => value.length == 1 && isPositive && value[0] == 1;
  bool get is2 => value.length == 1 && isPositive && value[0] == 2;
  bool get is5 => value.length == 1 && isPositive && value[0] == 5;
  bool get is10 => value.length == 1 && isPositive && value[0] == 10;

  bool get isValidJsInt => this <= MAX_JS_INT_AS_BIG_INT;
  int toValidJsInt() {
    if (is0) return 0;
    if (value.length == 1) return isPositive ? value[0] : -value[0];
    int intValue = 0;
    int inc = 1;
    for (int i = 0; i < value.length; i++) {
      intValue += value[i] * inc;
      inc *= _BASE;
    }
    return isPositive ? intValue : -intValue;
  }

  double toDouble() {
    double result = 1.0;
    for (int i = 0; i < value.length; i++) {
      result += value[i] * pow(_BASE, i);
    }
    return result;
  }

  BigInt operator -() => new BigInt(value, isNegative);

  BigInt operator +(BigInt other) {
    if (isPositive && other.isNegative) return this - (-other);
    if (isNegative && other.isPositive) return other - (-this);
    if (isNegative && other.isNegative) return -(-this + (-other));

    // 2 positive numbers

    // if they are small enough add them as int
    if (this <= _MAX_JS_INT_FOR_ADD && other <= _MAX_JS_INT_FOR_ADD) {
      return new BigInt.fromJsInt(toValidJsInt() + other.toValidJsInt());
    }

    // else add as BigInt
    final a = value;
    final b = other.value;
    final maxLength = max(a.length, b.length);
    final  result = [];
    int carry = 0;
    for (int i = 0; i < maxLength; i++) {
      int sum = _getOr0(a, i) + _getOr0(b, i) + carry;
      carry = sum >= _BASE ? 1 : 0;
      sum -= carry * _BASE;
      result.add(sum);
    }
    if (carry > 0) result.add(carry);
    return new BigInt(result, true);
  }

  BigInt operator -(BigInt other) {
    if (isPositive && other.isNegative) return this + (-other);
    if (isNegative && other.isPositive) return -(other + (-this));
    if (isNegative && other.isNegative) return -(-this - (-other));
    // 2 positive numbers
    if (this < other) return -(other - this);

    // 2 positive numbers and this >= other

    // if they are small enough add them as int
    if (this <= MAX_JS_INT_AS_BIG_INT && other <= MAX_JS_INT_AS_BIG_INT) {
      return new BigInt.fromJsInt(toValidJsInt() - other.toValidJsInt());
    }

    // as BigInt
    final a = value;
    final b = other.value;
    final maxLength = max(a.length, b.length);
    final  result = [];
    int borrow = 0;
    for (int i = 0; i < maxLength; i++) {
      int aa = _getOr0(a, i) - borrow;
      int bb = _getOr0(b, i);
      borrow = aa < bb ? 1 : 0;
      int diff = (borrow * _BASE) + aa - bb;
      result.add(diff);
    }
    return new BigInt(result, true);
  }

  BigInt operator *(BigInt other) {
    if (is0 || other.is0) return _0;
    if (isPositive && other.isNegative) return -(this * (-other));
    if (isNegative && other.isPositive) return -((-this) * other);
    if (isNegative && other.isNegative) return (-this) * (-other);
    if (this < other) return other * this;

    if (value[0] == 0) {
      final zeros = value.takeWhile((e) => e == 0).toList();
      return new BigInt((new BigInt(value.skip(zeros.length).toList(), true) * other).value..insertAll(0, zeros), true);
    }
    if (other.value[0] == 0) {
      final zeros = other.value.takeWhile((e) => e == 0).toList();
      return new BigInt((this * new BigInt(other.value.skip(zeros.length).toList(), true)).value..insertAll(0, zeros), true);
    }

    // if they are small enough add them as int
    if (this < _BASE_AS_BIG_INT && other < _BASE_AS_BIG_INT) {
      return new BigInt.fromJsInt(toValidJsInt() * other.toValidJsInt());
    }

    // as BigInt
    final a = other.value;
    final b = value;
    BigInt result = _0;
    for (int i = 0; i < a.length; i++) {
      final  partResult = [];
      int carry = 0;
      for (int j = 0; j < b.length; j++) {
        int sum = a[i] * b[j] + carry;
        carry = sum >= _BASE ? sum ~/ _BASE : 0;
        sum -= carry * _BASE;
        partResult.add(sum);
      }
      if (carry > 0) partResult.add(carry);
      for (var k = 0; k < i; k++) {
        partResult.insert(0, 0);
      }
      result += new BigInt(partResult, true);
    }
    return result;
  }

  BigInt operator ~/(BigInt other) {
    final a = abs();
    final b = other.abs();

    // if they are small enough add them as int
    if (a < MAX_JS_INT_AS_BIG_INT && b < MAX_JS_INT_AS_BIG_INT) {
      return new BigInt.fromJsInt(toValidJsInt() ~/ other.toValidJsInt());
    }

    // as BigInt
    final result = a._euclidianDivision(b);
    if (result.remainder == _0 || isPositive) {
      if (isPositive != other.isPositive) return -result.quotien;
      return result.quotien;
    }
    if (other.isPositive) return -result.quotien;
    else return result.quotien;
  }

  BigInt operator %(BigInt other) {
    if (is0) return _0;
    if (other.is2) return value.first % 2 == 0 ? _0 : _1;
    if (other.is5) return new BigInt.fromJsInt((isPositive ? value.first : -value.first) % 5);

    final a = abs();
    final b = other.abs();

    // if they are small enough add them as int
    if (a < MAX_JS_INT_AS_BIG_INT && b < MAX_JS_INT_AS_BIG_INT) {
      return new BigInt.fromJsInt(toValidJsInt() % other.toValidJsInt());
    }

    // as BigInt
    final result = a._euclidianDivision(b);
    if (result.remainder == _0) return _0;
    if (isPositive) return result.remainder;
    else return other.abs() - result.remainder;
  }

  _EuclidianDivisionResult _euclidianDivision(BigInt divisor) {
    assert(isPositive);
    assert(divisor.isPositive);
    if (divisor == _0) throw 'Cannot divise by 0';
    if (is0) return new _EuclidianDivisionResult(_0, _0);
    if (isValidJsInt && divisor.isValidJsInt) {
      final a = toValidJsInt();
      final b = divisor.toValidJsInt();
      return new _EuclidianDivisionResult(new BigInt.fromJsInt(a ~/ b), new BigInt.fromJsInt(a % b));
    }

    // optimization :
    final powerOfTens = <int, BigInt>{
      0: _1, // 10^0
    };
    final divisorByPowerOfTens = <int, BigInt>{
      0: divisor, // divisor * 10^0
    };
    var f = (int log, Map<int, BigInt> m) => m.putIfAbsent(log, () {
      if (log < _LOG_BASE) return m[log - 1] * _10;
      else {
        final index = log % _LOG_BASE;
        final pad = log ~/ _LOG_BASE;
        final a = m[index];
        return new BigInt(new List<int>.generate(pad + a.value.length,
            (index) => index < pad ? 0 : a.value[index - pad]), true);
      }
    });

    BigInt remainder = this;
    BigInt quotien = _0;
    do {
      int log = 0;
      BigInt c = divisor;
      BigInt inc = f(log, powerOfTens);
      BigInt t = f(log + 1, divisorByPowerOfTens);
      while (t < remainder) {
        log++;
        inc = f(log, powerOfTens);
        c = t;
        t = f(log + 1, divisorByPowerOfTens);
      }
      while (c <= remainder) {
        remainder -= c;
        quotien += inc;
      }
    } while (divisor <= remainder);
    return new _EuclidianDivisionResult(quotien, remainder);
  }

  BigInt abs() => new BigInt(value, true);

  int compareTo(BigInt other) {
    if (isPositive && other.isNegative) return 1;
    if (isNegative && other.isPositive) return -1;
    if (isNegative && other.isNegative) return -((-this).compareTo(-other));
    if (value.length > other.value.length) return 1;
    if (value.length < other.value.length) return -1;
    for (var i = value.length - 1; i >= 0; i--) {
      if (value[i] > other.value[i]) return 1;
      if (value[i] < other.value[i]) return -1;
    }
    return 0;
  }

  bool operator <(BigInt other) => this.compareTo(other) < 0;

  bool operator <=(BigInt other) => this.compareTo(other) <= 0;

  bool operator >(BigInt other) => this.compareTo(other) > 0;

  bool operator >=(BigInt other) => this.compareTo(other) >= 0;

  bool operator ==(BigInt other) => this.compareTo(other) == 0;

  int get hashCode => value.fold(0, (t,e) => t + e.hashCode) * 31 + isPositive.hashCode;

  String toString() {
    if (is0) return '0';
    final result = new StringBuffer();
    if (isNegative) result.write('-');
    result.write(value.last);
    value.reversed.skip(1).forEach((e) => result.write((_BASE + e).toString().substring(1)));
    return result.toString();
  }
}