library test.rational;

import 'package:expector/expector.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart' show test;

Rational p(String value) => Rational.parse(value);

void main() {
  test('Rational constructor', () async {
    await expectThat(() => Rational(BigInt.one)).returnsNormally();
    await expectThat(() => Rational(BigInt.one, BigInt.one)).returnsNormally();
    await expectThat(() => Rational(BigInt.one, BigInt.zero))
        .throwsA<ArgumentError>();
  });
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
  test('tryParse returns correctly on valid value', () {
    expectThat(Rational.tryParse('1')).equals(p('1'));
    expectThat(Rational.tryParse('-1')).equals(p('-1'));
    expectThat(Rational.tryParse('1.0e3')).equals(p('1000'));
    expectThat(Rational.tryParse('1e+3')).equals(p('1000'));
  });
  test('tryParse returns null on invalid', () {
    expectThat(Rational.tryParse('+')).isNull;
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
  test('compareTo(Rational other)', () {
    expectThat(p('1').compareTo(p('1'))).equals(0);
    expectThat(p('1').compareTo(p('1.0'))).equals(0);
    expectThat(p('1').compareTo(p('1.1'))).equals(-1);
    expectThat(p('1').compareTo(p('0.9'))).equals(1);
  });
  test('operator +(Rational other)', () {
    expectThat(p('1') + p('1')).equals(p('2'));
    expectThat(p('1.1') + p('1')).equals(p('2.1'));
    expectThat(p('1.1') + p('0.9')).equals(p('2'));
    expectThat(p('31878018903828899277492024491376690701584023926880.0') +
            p('0.9'))
        .equals(p('31878018903828899277492024491376690701584023926880.9'));
  });
  test('operator -(Rational other)', () {
    expectThat(p('1') - p('1')).equals(p('0'));
    expectThat(p('1.1') - p('1')).equals(p('0.1'));
    expectThat(p('0.1') - p('1.1')).equals(p('-1'));
    expectThat(p('31878018903828899277492024491376690701584023926880.0') -
            p('0.9'))
        .equals(p('31878018903828899277492024491376690701584023926879.1'));
  });
  test('operator *(Rational other)', () {
    expectThat(p('1') * p('1')).equals(p('1'));
    expectThat(p('1.1') * p('1')).equals(p('1.1'));
    expectThat(p('1.1') * p('0.1')).equals(p('0.11'));
    expectThat(p('1.1') * p('0')).equals(p('0'));
    expectThat(
            p('31878018903828899277492024491376690701584023926880.0') * p('10'))
        .equals(p('318780189038288992774920244913766907015840239268800'));
  });
  test('operator %(Rational other)', () {
    expectThat(p('2') % p('1')).equals(p('0'));
    expectThat(p('0') % p('1')).equals(p('0'));
    expectThat(p('8.9') % p('1.1')).equals(p('0.1'));
    expectThat(p('-1.2') % p('0.5')).equals(p('0.3'));
    expectThat(p('-1.2') % p('-0.5')).equals(p('0.3'));
    expectThat(p('-4') % p('4')).equals(p('0'));
    expectThat(p('-4') % p('-4')).equals(p('0'));
    expectThat(p('-8') % p('4')).equals(p('0'));
    expectThat(p('-8') % p('-4')).equals(p('0'));
  });
  test('operator /(Rational other)', () async {
    await expectThat(() => p('1') / p('0')).throwsA<ArgumentError>();
    expectThat(p('1') / p('1')).equals(p('1'));
    expectThat(p('1.1') / p('1')).equals(p('1.1'));
    expectThat(p('1.1') / p('0.1')).equals(p('11'));
    expectThat(p('0') / p('0.2315')).equals(p('0'));
    expectThat(
            p('31878018903828899277492024491376690701584023926880.0') / p('10'))
        .equals(p('3187801890382889927749202449137669070158402392688'));
  });
  test('operator ~/(Rational other)', () async {
    await expectThat(() => p('1') ~/ p('0')).throwsA<ArgumentError>();
    expectThat((p('3') ~/ p('2')).toString()).equals('1');
    expectThat((p('1.1') ~/ p('1')).toString()).equals('1');
    expectThat((p('1.1') ~/ p('0.1')).toString()).equals('11');
    expectThat((p('0') ~/ p('0.2315')).toString()).equals('0');
    expectThat((p('1') ~/ p('-0.3')).toString()).equals('-3');
  });
  test('operator -()', () {
    expectThat(-p('1')).equals(p('-1'));
    expectThat(-p('-1')).equals(p('1'));
  });
  test('remainder(Rational other)', () {
    expectThat(p('2').remainder(p('1'))).equals(p('0'));
    expectThat(p('0').remainder(p('1'))).equals(p('0'));
    expectThat(p('8.9').remainder(p('1.1'))).equals(p('0.1'));
    expectThat(p('-1.2').remainder(p('0.5'))).equals(p('-0.2'));
    expectThat(p('-1.2').remainder(p('-0.5'))).equals(p('-0.2'));
    expectThat(p('-4').remainder(p('4'))).equals(p('0'));
    expectThat(p('-4').remainder(p('-4'))).equals(p('0'));
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
  test('abs()', () {
    expectThat(p('-1.49').abs()).equals(p('1.49'));
    expectThat(p('1.498').abs()).equals(p('1.498'));
  });
  test('signum', () {
    expectThat(p('-1.49').signum).equals(-1);
    expectThat(p('1.49').signum).equals(1);
    expectThat(p('0').signum).equals(0);
    // https://github.com/a14n/dart-decimal/issues/21
    expectThat(p('99999999999993.256').signum).equals(1);
  });
  test('floor()', () {
    expectThat(p('1').floor()).equals(BigInt.from(1));
    expectThat(p('-1').floor()).equals(BigInt.from(-1));
    expectThat(p('1.49').floor()).equals(BigInt.from(1));
    expectThat(p('-1.49').floor()).equals(BigInt.from(-2));
  });
  test('ceil()', () {
    expectThat(p('1').ceil()).equals(BigInt.from(1));
    expectThat(p('-1').ceil()).equals(BigInt.from(-1));
    expectThat(p('-1.49').ceil()).equals(BigInt.from(-1));
    expectThat(p('1.49').ceil()).equals(BigInt.from(2));
  });
  test('round()', () {
    expectThat(p('1.4999').round()).equals(BigInt.from(1));
    expectThat(p('2.5').round()).equals(BigInt.from(3));
    expectThat(p('-2.51').round()).equals(BigInt.from(-3));
    expectThat(p('-2').round()).equals(BigInt.from(-2));
  });
  test('truncate()', () {
    expectThat(p('2.51').truncate()).equals(BigInt.from(2));
    expectThat(p('-2.51').truncate()).equals(BigInt.from(-2));
    expectThat(p('-2').truncate()).equals(BigInt.from(-2));
  });
  test('clamp(Rational lowerLimit, Rational upperLimit)', () {
    expectThat(p('2.51').clamp(p('1'), p('3'))).equals(p('2.51'));
    expectThat(p('2.51').clamp(p('2.6'), p('3'))).equals(p('2.6'));
    expectThat(p('2.51').clamp(p('1'), p('2.5'))).equals(p('2.5'));
  });
  test('toDouble()', () {
    expectThat(p('2.51').toDouble()).equals(2.51);
    expectThat(p('-2.51').toDouble()).equals(-2.51);
    expectThat(p('-2').toDouble()).equals(-2.0);
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
