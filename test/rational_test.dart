library test.rational;

import 'package:test/test.dart' show test;
import 'package:rational/rational.dart';
import 'package:expector/expector.dart';

Rational p(String value) => Rational.parse(value);

void main() {
  test('string validation', () async {
    await expectThat(() => p('1')).returnsNormally();
    await expectThat(() => p('-1')).returnsNormally();
    await expectThat(() => p('+1')).returnsNormally();
    await expectThat(() => p('1.')).returnsNormally();
    await expectThat(() => p('1.0')).returnsNormally();
    await expectThat(() => p('1.0e5')).returnsNormally();
    await expectThat(() => p('1.0e-5')).returnsNormally();
    await expectThat(() => p('1.0e+5')).returnsNormally();
    await expectThat(() => p('1e+5')).returnsNormally();
    await expectThat(() => p('1.79769E+308')).returnsNormally();
    await expectThat(() => p('6E739019')).returnsNormally();
    await expectThat(() => p('+')).throwsA<FormatException>();
  });
  test('parse scientific notation', () {
    expectThat(p('1.0e3')).equals(p('1000'));
    expectThat(p('1e+3')).equals(p('1000'));
    expectThat(p('34.5e-2')).equals(p('0.345'));
    expectThat(p('345e-5')).equals(p('0.00345'));
    expectThat(p('.123')).equals(p('0.123'));
  });
  test('get isInteger', () {
    expectThat(p('1').isInteger).isTrue;
    expectThat(p('0').isInteger).isTrue;
    expectThat(p('-1').isInteger).isTrue;
    expectThat(p('+1').isInteger).isTrue;
    expectThat(p('-1.0').isInteger).isTrue;
    expectThat(p('1.2').isInteger).isFalse;
    expectThat(p('-1.21').isInteger).isFalse;
    expectThat(p('1.0e4').isInteger).isTrue;
    expectThat(p('1e-4').isInteger).isFalse;
  });
  test('get inverse', () async {
    expectThat(p('1').inverse).equals(p('1'));
    await expectThat(() => p('0').inverse).throwsA<ArgumentError>();
    expectThat(p('10').inverse).equals(p('0.1'));
    expectThat(p('200').inverse).equals(p('0.005'));
  });
  test('operator ==(Rational other)', () {
    expectThat(p('1') == (p('1'))).isTrue;
    expectThat(p('1') == (p('2'))).isFalse;
    expectThat(p('1') == (p('1.0'))).isTrue;
    expectThat(p('1') == (p('+1'))).isTrue;
    expectThat(p('1') == (p('2.0'))).isFalse;
    expectThat(p('1') != (p('1'))).isFalse;
    expectThat(p('1') != (p('2'))).isTrue;
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
      expectThat(p(n).toDecimalString()).equals(n);
    }
    expectThat(p('9.9').toDecimalString()).equals('9.9');
    expectThat(p('99.2').toDecimalString()).equals('99.2');
    expectThat((p('1') / p('3')).toDecimalString()).equals('0.3333333333');
    expectThat((p('1.0000000000000000000000000000000000000000000000001') *
                p('1.0000000000000000000000000000000000000000000000001'))
            .toDecimalString())
        .equals(
            '1.00000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000001');
  });
  test('compareTo(Rational other)', () {
    expectThat(p('1').compareTo(p('1'))).equals(0);
    expectThat(p('1').compareTo(p('1.0'))).equals(0);
    expectThat(p('1').compareTo(p('1.1'))).equals(-1);
    expectThat(p('1').compareTo(p('0.9'))).equals(1);
  });
  test('operator +(Rational other)', () {
    expectThat((p('1') + p('1')).toDecimalString()).equals('2');
    expectThat((p('1.1') + p('1')).toDecimalString()).equals('2.1');
    expectThat((p('1.1') + p('0.9')).toDecimalString()).equals('2');
    expectThat((p('31878018903828899277492024491376690701584023926880.0') +
                p('0.9'))
            .toDecimalString())
        .equals('31878018903828899277492024491376690701584023926880.9');
  });
  test('operator -(Rational other)', () {
    expectThat((p('1') - p('1')).toDecimalString()).equals('0');
    expectThat((p('1.1') - p('1')).toDecimalString()).equals('0.1');
    expectThat((p('0.1') - p('1.1')).toDecimalString()).equals('-1');
    expectThat((p('31878018903828899277492024491376690701584023926880.0') -
                p('0.9'))
            .toDecimalString())
        .equals('31878018903828899277492024491376690701584023926879.1');
  });
  test('operator *(Rational other)', () {
    expectThat((p('1') * p('1')).toDecimalString()).equals('1');
    expectThat((p('1.1') * p('1')).toDecimalString()).equals('1.1');
    expectThat((p('1.1') * p('0.1')).toDecimalString()).equals('0.11');
    expectThat((p('1.1') * p('0')).toDecimalString()).equals('0');
    expectThat((p('31878018903828899277492024491376690701584023926880.0') *
                p('10'))
            .toDecimalString())
        .equals('318780189038288992774920244913766907015840239268800');
  });
  test('operator %(Rational other)', () {
    expectThat((p('2') % p('1')).toDecimalString()).equals('0');
    expectThat((p('0') % p('1')).toDecimalString()).equals('0');
    expectThat((p('8.9') % p('1.1')).toDecimalString()).equals('0.1');
    expectThat((p('-1.2') % p('0.5')).toDecimalString()).equals('0.3');
    expectThat((p('-1.2') % p('-0.5')).toDecimalString()).equals('0.3');
    expectThat((p('-4') % p('4')).toDecimalString()).equals('0');
    expectThat((p('-4') % p('-4')).toDecimalString()).equals('0');
    expectThat((p('-8') % p('4')).toDecimalString()).equals('0');
    expectThat((p('-8') % p('-4')).toDecimalString()).equals('0');
  });
  test('operator /(Rational other)', () async {
    await expectThat(() => p('1') / p('0')).throwsA<ArgumentError>();
    expectThat((p('1') / p('1')).toDecimalString()).equals('1');
    expectThat((p('1.1') / p('1')).toDecimalString()).equals('1.1');
    expectThat((p('1.1') / p('0.1')).toDecimalString()).equals('11');
    expectThat((p('0') / p('0.2315')).toDecimalString()).equals('0');
    expectThat((p('31878018903828899277492024491376690701584023926880.0') /
                p('10'))
            .toDecimalString())
        .equals('3187801890382889927749202449137669070158402392688');
  });
  test('operator ~/(Rational other)', () async {
    await expectThat(() => p('1') ~/ p('0')).throwsA<ArgumentError>();
    expectThat((p('3') ~/ p('2')).toDecimalString()).equals('1');
    expectThat((p('1.1') ~/ p('1')).toDecimalString()).equals('1');
    expectThat((p('1.1') ~/ p('0.1')).toDecimalString()).equals('11');
    expectThat((p('0') ~/ p('0.2315')).toDecimalString()).equals('0');
  });
  test('operator -()', () {
    expectThat((-p('1')).toDecimalString()).equals('-1');
    expectThat((-p('-1')).toDecimalString()).equals('1');
  });
  test('remainder(Rational other)', () {
    expectThat((p('2').remainder(p('1'))).toDecimalString()).equals('0');
    expectThat((p('0').remainder(p('1'))).toDecimalString()).equals('0');
    expectThat((p('8.9').remainder(p('1.1'))).toDecimalString()).equals('0.1');
    expectThat((p('-1.2').remainder(p('0.5'))).toDecimalString())
        .equals('-0.2');
    expectThat((p('-1.2').remainder(p('-0.5'))).toDecimalString())
        .equals('-0.2');
    expectThat((p('-4').remainder(p('4'))).toDecimalString()).equals('0');
    expectThat((p('-4').remainder(p('-4'))).toDecimalString()).equals('0');
  });
  test('operator <(Rational other)', () {
    expectThat(p('1') < p('1')).isFalse;
    expectThat(p('1') < p('1.0')).isFalse;
    expectThat(p('1') < p('1.1')).isTrue;
    expectThat(p('1') < p('0.9')).isFalse;
  });
  test('operator <=(Rational other)', () {
    expectThat(p('1') <= p('1')).isTrue;
    expectThat(p('1') <= p('1.0')).isTrue;
    expectThat(p('1') <= p('1.1')).isTrue;
    expectThat(p('1') <= p('0.9')).isFalse;
  });
  test('operator >(Rational other)', () {
    expectThat(p('1') > p('1')).isFalse;
    expectThat(p('1') > p('1.0')).isFalse;
    expectThat(p('1') > p('1.1')).isFalse;
    expectThat(p('1') > p('0.9')).isTrue;
  });
  test('operator >=(Rational other)', () {
    expectThat(p('1') >= p('1')).isTrue;
    expectThat(p('1') >= p('1.0')).isTrue;
    expectThat(p('1') >= p('1.1')).isFalse;
    expectThat(p('1') >= p('0.9')).isTrue;
  });
  test('get isNaN', () {
    expectThat(p('1').isNaN).isFalse;
  });
  test('get isNegative', () {
    expectThat(p('-1').isNegative).isTrue;
    expectThat(p('0').isNegative).isFalse;
    expectThat(p('1').isNegative).isFalse;
  });
  test('get isInfinite', () {
    expectThat(p('1').isInfinite).isFalse;
  });
  test('abs()', () {
    expectThat((p('-1.49').abs()).toDecimalString()).equals('1.49');
    expectThat((p('1.498').abs()).toDecimalString()).equals('1.498');
  });
  test('signum', () {
    expectThat(p('-1.49').signum).equals(-1);
    expectThat(p('1.49').signum).equals(1);
    expectThat(p('0').signum).equals(0);
    // https://github.com/a14n/dart-decimal/issues/21
    expectThat(p('99999999999993.256').signum).equals(1);
  });
  test('floor()', () {
    expectThat((p('1').floor()).toDecimalString()).equals('1');
    expectThat((p('-1').floor()).toDecimalString()).equals('-1');
    expectThat((p('1.49').floor()).toDecimalString()).equals('1');
    expectThat((p('-1.49').floor()).toDecimalString()).equals('-2');
  });
  test('ceil()', () {
    expectThat((p('1').floor()).toDecimalString()).equals('1');
    expectThat((p('-1').floor()).toDecimalString()).equals('-1');
    expectThat((p('-1.49').ceil()).toDecimalString()).equals('-1');
    expectThat((p('1.49').ceil()).toDecimalString()).equals('2');
  });
  test('round()', () {
    expectThat((p('1.4999').round()).toDecimalString()).equals('1');
    expectThat((p('2.5').round()).toDecimalString()).equals('3');
    expectThat((p('-2.51').round()).toDecimalString()).equals('-3');
    expectThat((p('-2').round()).toDecimalString()).equals('-2');
  });
  test('truncate()', () {
    expectThat((p('2.51').truncate()).toDecimalString()).equals('2');
    expectThat((p('-2.51').truncate()).toDecimalString()).equals('-2');
    expectThat((p('-2').truncate()).toDecimalString()).equals('-2');
  });
  test('clamp(Rational lowerLimit, Rational upperLimit)', () {
    expectThat((p('2.51').clamp(p('1'), p('3'))).toDecimalString())
        .equals('2.51');
    expectThat((p('2.51').clamp(p('2.6'), p('3'))).toDecimalString())
        .equals('2.6');
    expectThat((p('2.51').clamp(p('1'), p('2.5'))).toDecimalString())
        .equals('2.5');
  });
  test('toInt()', () {
    expectThat(p('2.51').toInt()).equals(2);
    expectThat(p('-2.51').toInt()).equals(-2);
    expectThat(p('-2').toInt()).equals(-2);
  });
  test('toDouble()', () {
    expectThat(p('2.51').toDouble()).equals(2.51);
    expectThat(p('-2.51').toDouble()).equals(-2.51);
    expectThat(p('-2').toDouble()).equals(-2.0);
  });
  test('toStringAsFixed(int fractionDigits)', () {
    for (final n in [0, 1, 23, 2.2, 2.499999, 2.5, 2.7, 1.235]) {
      for (final precision in [0, 1, 5, 10]) {
        expectThat(p(n.toString()).toStringAsFixed(precision))
            .equals(n.toStringAsFixed(precision));
      }
    }
  });
  test('toStringAsExponential(int fractionDigits)', () {
    for (final n in [0, 1, 23, 2.2, 2.499999, 2.5, 2.7, 1.235]) {
      for (final precision in [1, 5, 10]) {
        expectThat(p(p(n.toString()).toStringAsExponential(precision)))
            .equals(p(n.toStringAsExponential(precision)));
      }
    }
  });
  test('toStringAsPrecision(int precision)', () {
    for (final n in [0, 1, 23, 2.2, 2.499999, 2.5, 2.7, 1.235]) {
      for (final precision in [1, 5, 10]) {
        expectThat(p(p(n.toString()).toStringAsPrecision(precision)))
            .equals(p(n.toStringAsPrecision(precision)));
      }
    }
    expectThat(p('0.512').toStringAsPrecision(20))
        .equals('0.51200000000000000000');
  });
  test('hasFinitePrecision', () {
    for (final r in [
      p('100'),
      p('100.100'),
      p('1') / p('5'),
      (p('1') / p('3')) * p('3'),
      p('0.00000000000000000000001')
    ]) {
      expectThat(r.hasFinitePrecision).isTrue;
    }
    for (final r in [p('1') / p('3')]) {
      expectThat(r.hasFinitePrecision).isFalse;
    }
  });
  test('precision', () async {
    expectThat(p('100').precision).equals(3);
    expectThat(p('10000').precision).equals(5);
    expectThat(p('-10000').precision).equals(5);
    expectThat(p('1e5').precision).equals(6);
    expectThat(p('100.000').precision).equals(3);
    expectThat(p('100.1').precision).equals(4);
    expectThat(p('100.0000001').precision).equals(10);
    expectThat(p('-100.0000001').precision).equals(10);
    expectThat(p('100.000000000000000000000000000001').precision).equals(33);
    await expectThat(() => (p('1') / p('3')).precision).throwsA<StateError>();
  });
  test('scale', () async {
    expectThat(p('100').scale).equals(0);
    expectThat(p('10000').scale).equals(0);
    expectThat(p('100.000').scale).equals(0);
    expectThat(p('100.1').scale).equals(1);
    expectThat(p('100.0000001').scale).equals(7);
    expectThat(p('-100.0000001').scale).equals(7);
    expectThat(p('100.000000000000000000000000000001').scale).equals(30);
    await expectThat(() => (p('1') / p('3')).scale).throwsA<StateError>();
  });
  test('pow', () {
    expectThat(p('100').pow(0)).equals(p('1'));
    expectThat(p('100').pow(1)).equals(p('100'));
    expectThat(p('100').pow(2)).equals(p('10000'));
    expectThat(p('100').pow(-1)).equals(p('0.01'));
    expectThat(p('100').pow(-2)).equals(p('0.0001'));
    expectThat(p('0.1').pow(0)).equals(p('1'));
    expectThat(p('0.1').pow(1)).equals(p('0.1'));
    expectThat(p('0.1').pow(2)).equals(p('0.01'));
    expectThat(p('0.1').pow(-1)).equals(p('10'));
    expectThat(p('0.1').pow(-2)).equals(p('100'));
    expectThat(p('-1').pow(0)).equals(p('1'));
    expectThat(p('-1').pow(1)).equals(p('-1'));
    expectThat(p('-1').pow(2)).equals(p('1'));
    expectThat(p('-1').pow(-1)).equals(p('-1'));
    expectThat(p('-1').pow(-2)).equals(p('1'));
  });
}
