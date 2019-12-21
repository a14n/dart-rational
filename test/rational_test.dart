library test.rational;

import 'package:test/test.dart';
import 'package:rational/rational.dart';

Rational p(String value) => Rational.parse(value);

void main() {
  test('string validation', () {
    expect(() => p('1'), returnsNormally);
    expect(() => p('-1'), returnsNormally);
    expect(() => p('+1'), returnsNormally);
    expect(() => p('1.'), returnsNormally);
    expect(() => p('1.0'), returnsNormally);
    expect(() => p('1.0e5'), returnsNormally);
    expect(() => p('1.0e-5'), returnsNormally);
    expect(() => p('1.0e+5'), returnsNormally);
    expect(() => p('1e+5'), returnsNormally);
    expect(() => p('+'), throwsFormatException);
  });
  test('parse scientific notation', () {
    expect(p('1.0e3'), equals(p('1000')));
    expect(p('1e+3'), equals(p('1000')));
    expect(p('34.5e-2'), equals(p('0.345')));
    expect(p('345e-5'), equals(p('0.00345')));
    expect(p('.123'), equals(p('0.123')));
  });
  test('get isInteger', () {
    expect(p('1').isInteger, equals(true));
    expect(p('0').isInteger, equals(true));
    expect(p('-1').isInteger, equals(true));
    expect(p('+1').isInteger, equals(true));
    expect(p('-1.0').isInteger, equals(true));
    expect(p('1.2').isInteger, equals(false));
    expect(p('-1.21').isInteger, equals(false));
    expect(p('1.0e4').isInteger, equals(true));
    expect(p('1e-4').isInteger, equals(false));
  });
  test('get inverse', () {
    expect(p('1').inverse, equals(p('1')));
    expect(() => p('0').inverse, throwsArgumentError);
    expect(p('10').inverse, equals(p('0.1')));
    expect(p('200').inverse, equals(p('0.005')));
  });
  test('operator ==(Rational other)', () {
    expect(p('1') == (p('1')), equals(true));
    expect(p('1') == (p('2')), equals(false));
    expect(p('1') == (p('1.0')), equals(true));
    expect(p('1') == (p('+1')), equals(true));
    expect(p('1') == (p('2.0')), equals(false));
    expect(p('1') != (p('1')), equals(false));
    expect(p('1') != (p('2')), equals(true));
  });
  test('toDecimalString()', () {
    for (final n in [
      '0',
      '1',
      '-1',
      '-1.1',
      '23',
      '31878018903828899277492024491376690701584023926880.1'
    ]) {
      expect(p(n).toDecimalString(), equals(n));
    }
    expect(p('9.9').toDecimalString(), equals('9.9'));
    expect(p('99.2').toDecimalString(), equals('99.2'));
    expect((p('1') / p('3')).toDecimalString(), equals('0.3333333333'));
    expect(
        (p('1.0000000000000000000000000000000000000000000000001') *
                p('1.0000000000000000000000000000000000000000000000001'))
            .toDecimalString(),
        equals(
            '1.00000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000001'));
  });
  test('compareTo(Rational other)', () {
    expect(p('1').compareTo(p('1')), equals(0));
    expect(p('1').compareTo(p('1.0')), equals(0));
    expect(p('1').compareTo(p('1.1')), equals(-1));
    expect(p('1').compareTo(p('0.9')), equals(1));
  });
  test('operator +(Rational other)', () {
    expect((p('1') + p('1')).toDecimalString(), equals('2'));
    expect((p('1.1') + p('1')).toDecimalString(), equals('2.1'));
    expect((p('1.1') + p('0.9')).toDecimalString(), equals('2'));
    expect(
        (p('31878018903828899277492024491376690701584023926880.0') + p('0.9'))
            .toDecimalString(),
        equals('31878018903828899277492024491376690701584023926880.9'));
  });
  test('operator -(Rational other)', () {
    expect((p('1') - p('1')).toDecimalString(), equals('0'));
    expect((p('1.1') - p('1')).toDecimalString(), equals('0.1'));
    expect((p('0.1') - p('1.1')).toDecimalString(), equals('-1'));
    expect(
        (p('31878018903828899277492024491376690701584023926880.0') - p('0.9'))
            .toDecimalString(),
        equals('31878018903828899277492024491376690701584023926879.1'));
  });
  test('operator *(Rational other)', () {
    expect((p('1') * p('1')).toDecimalString(), equals('1'));
    expect((p('1.1') * p('1')).toDecimalString(), equals('1.1'));
    expect((p('1.1') * p('0.1')).toDecimalString(), equals('0.11'));
    expect((p('1.1') * p('0')).toDecimalString(), equals('0'));
    expect(
        (p('31878018903828899277492024491376690701584023926880.0') * p('10'))
            .toDecimalString(),
        equals('318780189038288992774920244913766907015840239268800'));
  });
  test('operator %(Rational other)', () {
    expect((p('2') % p('1')).toDecimalString(), equals('0'));
    expect((p('0') % p('1')).toDecimalString(), equals('0'));
    expect((p('8.9') % p('1.1')).toDecimalString(), equals('0.1'));
    expect((p('-1.2') % p('0.5')).toDecimalString(), equals('0.3'));
    expect((p('-1.2') % p('-0.5')).toDecimalString(), equals('0.3'));
    expect((p('-4') % p('4')).toDecimalString(), equals('0'));
    expect((p('-4') % p('-4')).toDecimalString(), equals('0'));
    expect((p('-8') % p('4')).toDecimalString(), equals('0'));
    expect((p('-8') % p('-4')).toDecimalString(), equals('0'));
  });
  test('operator /(Rational other)', () {
    expect(() => p('1') / p('0'), throwsArgumentError);
    expect((p('1') / p('1')).toDecimalString(), equals('1'));
    expect((p('1.1') / p('1')).toDecimalString(), equals('1.1'));
    expect((p('1.1') / p('0.1')).toDecimalString(), equals('11'));
    expect((p('0') / p('0.2315')).toDecimalString(), equals('0'));
    expect(
        (p('31878018903828899277492024491376690701584023926880.0') / p('10'))
            .toDecimalString(),
        equals('3187801890382889927749202449137669070158402392688'));
  });
  test('operator ~/(Rational other)', () {
    expect(() => p('1') ~/ p('0'), throwsArgumentError);
    expect((p('3') ~/ p('2')).toDecimalString(), equals('1'));
    expect((p('1.1') ~/ p('1')).toDecimalString(), equals('1'));
    expect((p('1.1') ~/ p('0.1')).toDecimalString(), equals('11'));
    expect((p('0') ~/ p('0.2315')).toDecimalString(), equals('0'));
  });
  test('operator -()', () {
    expect((-p('1')).toDecimalString(), equals('-1'));
    expect((-p('-1')).toDecimalString(), equals('1'));
  });
  test('remainder(Rational other)', () {
    expect((p('2').remainder(p('1'))).toDecimalString(), equals('0'));
    expect((p('0').remainder(p('1'))).toDecimalString(), equals('0'));
    expect((p('8.9').remainder(p('1.1'))).toDecimalString(), equals('0.1'));
    expect((p('-1.2').remainder(p('0.5'))).toDecimalString(), equals('-0.2'));
    expect((p('-1.2').remainder(p('-0.5'))).toDecimalString(), equals('-0.2'));
    expect((p('-4').remainder(p('4'))).toDecimalString(), equals('0'));
    expect((p('-4').remainder(p('-4'))).toDecimalString(), equals('0'));
  });
  test('operator <(Rational other)', () {
    expect(p('1') < p('1'), equals(false));
    expect(p('1') < p('1.0'), equals(false));
    expect(p('1') < p('1.1'), equals(true));
    expect(p('1') < p('0.9'), equals(false));
  });
  test('operator <=(Rational other)', () {
    expect(p('1') <= p('1'), equals(true));
    expect(p('1') <= p('1.0'), equals(true));
    expect(p('1') <= p('1.1'), equals(true));
    expect(p('1') <= p('0.9'), equals(false));
  });
  test('operator >(Rational other)', () {
    expect(p('1') > p('1'), equals(false));
    expect(p('1') > p('1.0'), equals(false));
    expect(p('1') > p('1.1'), equals(false));
    expect(p('1') > p('0.9'), equals(true));
  });
  test('operator >=(Rational other)', () {
    expect(p('1') >= p('1'), equals(true));
    expect(p('1') >= p('1.0'), equals(true));
    expect(p('1') >= p('1.1'), equals(false));
    expect(p('1') >= p('0.9'), equals(true));
  });
  test('get isNaN', () {
    expect(p('1').isNaN, equals(false));
  });
  test('get isNegative', () {
    expect(p('-1').isNegative, equals(true));
    expect(p('0').isNegative, equals(false));
    expect(p('1').isNegative, equals(false));
  });
  test('get isInfinite', () {
    expect(p('1').isInfinite, equals(false));
  });
  test('abs()', () {
    expect((p('-1.49').abs()).toDecimalString(), equals('1.49'));
    expect((p('1.498').abs()).toDecimalString(), equals('1.498'));
  });
  test('signum', () {
    expect(p('-1.49').signum, equals(-1));
    expect(p('1.49').signum, equals(1));
    expect(p('0').signum, equals(0));
    // https://github.com/a14n/dart-decimal/issues/21
    expect(p('99999999999993.256').signum, equals(1));
  });
  test('floor()', () {
    expect((p('1').floor()).toDecimalString(), equals('1'));
    expect((p('-1').floor()).toDecimalString(), equals('-1'));
    expect((p('1.49').floor()).toDecimalString(), equals('1'));
    expect((p('-1.49').floor()).toDecimalString(), equals('-2'));
  });
  test('ceil()', () {
    expect((p('1').floor()).toDecimalString(), equals('1'));
    expect((p('-1').floor()).toDecimalString(), equals('-1'));
    expect((p('-1.49').ceil()).toDecimalString(), equals('-1'));
    expect((p('1.49').ceil()).toDecimalString(), equals('2'));
  });
  test('round()', () {
    expect((p('1.4999').round()).toDecimalString(), equals('1'));
    expect((p('2.5').round()).toDecimalString(), equals('3'));
    expect((p('-2.51').round()).toDecimalString(), equals('-3'));
    expect((p('-2').round()).toDecimalString(), equals('-2'));
  });
  test('truncate()', () {
    expect((p('2.51').truncate()).toDecimalString(), equals('2'));
    expect((p('-2.51').truncate()).toDecimalString(), equals('-2'));
    expect((p('-2').truncate()).toDecimalString(), equals('-2'));
  });
  test('clamp(Rational lowerLimit, Rational upperLimit)', () {
    expect((p('2.51').clamp(p('1'), p('3'))).toDecimalString(), equals('2.51'));
    expect(
        (p('2.51').clamp(p('2.6'), p('3'))).toDecimalString(), equals('2.6'));
    expect(
        (p('2.51').clamp(p('1'), p('2.5'))).toDecimalString(), equals('2.5'));
  });
  test('toInt()', () {
    expect(p('2.51').toInt(), equals(2));
    expect(p('-2.51').toInt(), equals(-2));
    expect(p('-2').toInt(), equals(-2));
  });
  test('toDouble()', () {
    expect(p('2.51').toDouble(), equals(2.51));
    expect(p('-2.51').toDouble(), equals(-2.51));
    expect(p('-2').toDouble(), equals(-2.0));
  });
  test('toStringAsFixed(int fractionDigits)', () {
    for (final n in [0, 1, 23, 2.2, 2.499999, 2.5, 2.7, 1.235]) {
      for (final precision in [0, 1, 5, 10]) {
        expect(p(n.toString()).toStringAsFixed(precision),
            equals(n.toStringAsFixed(precision)));
      }
    }
  });
  test('toStringAsExponential(int fractionDigits)', () {
    for (final n in [0, 1, 23, 2.2, 2.499999, 2.5, 2.7, 1.235]) {
      for (final precision in [1, 5, 10]) {
        expect(
          p(p(n.toString()).toStringAsExponential(precision)),
          p(n.toStringAsExponential(precision)),
        );
      }
    }
  });
  test('toStringAsPrecision(int precision)', () {
    for (final n in [0, 1, 23, 2.2, 2.499999, 2.5, 2.7, 1.235]) {
      for (final precision in [1, 5, 10]) {
        expect(
          p(p(n.toString()).toStringAsPrecision(precision)),
          p(n.toStringAsPrecision(precision)),
        );
      }
    }
    expect(p('0.512').toStringAsPrecision(20), '0.51200000000000000000');
  });
  test('hasFinitePrecision', () {
    for (final r in [
      p('100'),
      p('100.100'),
      p('1') / p('5'),
      (p('1') / p('3')) * p('3'),
      p('0.00000000000000000000001')
    ]) {
      expect(r.hasFinitePrecision, isTrue);
    }
    for (final r in [p('1') / p('3')]) {
      expect(r.hasFinitePrecision, isFalse);
    }
  });
  test('precision', () {
    expect(p('100').precision, equals(3));
    expect(p('10000').precision, equals(5));
    expect(p('-10000').precision, equals(5));
    expect(p('1e5').precision, equals(6));
    expect(p('100.000').precision, equals(3));
    expect(p('100.1').precision, equals(4));
    expect(p('100.0000001').precision, equals(10));
    expect(p('-100.0000001').precision, equals(10));
    expect(p('100.000000000000000000000000000001').precision, equals(33));
    expect(() => (p('1') / p('3')).precision, throwsStateError);
  });
  test('scale', () {
    expect(p('100').scale, equals(0));
    expect(p('10000').scale, equals(0));
    expect(p('100.000').scale, equals(0));
    expect(p('100.1').scale, equals(1));
    expect(p('100.0000001').scale, equals(7));
    expect(p('-100.0000001').scale, equals(7));
    expect(p('100.000000000000000000000000000001').scale, equals(30));
    expect(() => (p('1') / p('3')).scale, throwsStateError);
  });
  test('pow', () {
    expect(p('100').pow(0), equals(p('1')));
    expect(p('100').pow(1), equals(p('100')));
    expect(p('100').pow(2), equals(p('10000')));
    expect(p('0.1').pow(0), equals(p('1')));
    expect(p('0.1').pow(1), equals(p('0.1')));
    expect(p('0.1').pow(2), equals(p('0.01')));
    expect(p('-1').pow(0), equals(p('1')));
    expect(p('-1').pow(1), equals(p('-1')));
    expect(p('-1').pow(2), equals(p('1')));
  });
}
