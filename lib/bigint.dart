import 'dart:math' show max, min;

final MAX_JS_INT = 9007199254740992;
final MAX_JS_INT_AS_BIG_INT = new BigInt.fromJsInt(MAX_JS_INT);
final _BASE = 10000000;
final _LOG_BASE = 7;

_normalize(List<int> a, List<int> b) {
  final maxLength = max(a.length, b.length);
  final minLength = min(a.length, b.length);
  a.length = maxLength;
  b.length = maxLength;
  for (int i = minLength; i < maxLength; i++) {
    if (a[i] == null) a[i] = 0;
    if (b[i] == null) b[i] = 0;
  }
  for (int i = maxLength - 1; i >= 0; i--) {
    if (a[i] == 0 && b[i] == 0) {
      a.removeLast();
      b.removeLast();
    } else break;
  }
  if (a.isEmpty) {
    a = [0];
    b = [0];
  }
}

class _EuclidianDivisionResult {
  final BigInt quotien;
  final BigInt remainder;

  _EuclidianDivisionResult(this.quotien, this.remainder);
}

final _0 = BigInt.parse('0');
final _1 = BigInt.parse('1');
final _2 = BigInt.parse('2');
final _5 = BigInt.parse('5');
final _10 = BigInt.parse('10');

class BigInt {
  static BigInt parse(String text) {
    bool isPositive = true;
    if (text.startsWith('-')) {
      isPositive = false;
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
    final value = [];
    int a = intValue.abs();
    while (a > 0) {
      value.add(a % _BASE);
      a = a ~/ _BASE;
    }
    return new BigInt(value, intValue >= 0);
  }

  bool get isNegative => !isPositive;

  bool get is0 => value.isEmpty;
  bool get is1 => value.length == 1 && isPositive && value[0] == 1;
  bool get is2 => value.length == 1 && isPositive && value[0] == 2;
  bool get is5 => value.length == 1 && isPositive && value[0] == 5;

  bool get isValidJsInt => this <= MAX_JS_INT_AS_BIG_INT;
  int toValidJsInt() {
    int intValue = 0;
    int inc = 1;
    for (int i = 0; i < value.length; i++) {
      intValue += value[i] * inc;
      inc *= _BASE;
    }
    return isPositive ? intValue : -intValue;
  }

  BigInt operator -() => new BigInt(value, isNegative);

  BigInt operator +(BigInt other) {
    if (isPositive && other.isNegative) return this - (-other);
    if (isNegative && other.isPositive) return other - (-this);
    if (isNegative && other.isNegative) return -(-this + (-other));

    // 2 positive numbers
    final a = value.toList();
    final b = other.value.toList();
    _normalize(a, b);
    final  result = [];
    int carry = 0;
    for (int i = 0; i < a.length; i++) {
      int sum = a[i] + b[i] + carry;
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
    final a = value.toList();
    final b = other.value.toList();
    _normalize(a, b);
    final  result = [];
    int borrow = 0;
    for (int i = 0; i < a.length; i++) {
      a[i] -= borrow;
      borrow = a[i] < b[i] ? 1 : 0;
      int minuend = (borrow * _BASE) + a[i] - b[i];
      result.add(minuend);
    }
    return new BigInt(result, true);
  }

  BigInt operator *(BigInt other) {
    if (isPositive && other.isNegative) return -(this * (-other));
    if (isNegative && other.isPositive) return -((-this) * other);
    if (isNegative && other.isNegative) return (-this) * (-other);
    if (this < other) return other * this;

    final a = value.toList();
    final b = other.value.toList();
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
    final result = this.abs()._euclidianDivision(other.abs());
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
    if (other.is5 && value.length > 1) return new BigInt([value.first], isPositive) % _5;
    final result = this.abs()._euclidianDivision(other.abs());
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
    BigInt remainder = this;
    BigInt quotien = _0;
    do {
      BigInt inc = _1;
      BigInt c = divisor;
      BigInt t = c * _10;
      while (t < remainder) {
        c = t;
        inc *= _10;
        t *= _10;
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
    final a = value.toList();
    final b = other.value.toList();
    _normalize(a, b);
    for (var i = a.length - 1; i >= 0; i--) {
      if (a[i] > b[i]) return 1;
      if (a[i] < b[i]) return -1;
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