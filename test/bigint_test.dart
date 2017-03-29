library test.bigint;

import 'package:rational/bigint.dart';
import 'package:test/test.dart';

BigInt p(String value) => BigInt.parse(value);

main() {
  test('string validation', () {
    expect(() => p('1'), returnsNormally);
    expect(() => p('-1'), returnsNormally);
    expect(() => p('+1'), returnsNormally);
    expect(() => p('1.'), throws);
    expect(() => p('1.0'), throws);
    expect(() => p('++1'), throws);
    expect(() => p('--1'), throws);
  });
  test('valid js int', () {
    for (int i = 0; i < 100; i++) {
      final a = new BigInt.fromJsInt(i);
      expect(a.toString(), equals(i.toString()));
      expect(a.toValidJsInt(), equals(i));
    }
  });
  test('toString()', () {
    for (int i = 0; i < 100; i++) {
      final n = '1' + (new List.filled(i, 0)).join();
      expect(p(n).toString(), equals(n));
      expect(p('0$n').toString(), equals(n));
      expect(p('-$n').toString(), equals('-$n'));
      expect(p('-0$n').toString(), equals('-$n'));
    }
  });
  test('toDouble()', () {
    ['0', '1', '2', '23', '3187801890382']
        .expand((e) => [e, '-$e']) // also test negative values
        .forEach((n) => expect(p(n).toDouble(), equals(double.parse(n))));
    ['31878018903828899277492024491376690701584023926880']
        .expand((e) => [e, '-$e']) // also test negative values
        .forEach((n) => expect(p(n).toDouble().toStringAsExponential(10),
            equals(double.parse(n).toStringAsExponential(10))));
  });
  test('operator ==(BigInt other)', () {
    expect(p('1') == p('1'), equals(true));
    expect(p('1') == p('2'), equals(false));
    expect(p('-1') != p('1'), equals(true));
  });
  test('compareTo(BigInt other)', () {
    expect(p('1').compareTo(p('1')), equals(0));
    expect(p('1').compareTo(p('2')), equals(-1));
    expect(p('1').compareTo(p('-2')), equals(1));
    expect(p('2').compareTo(p('-1')), equals(1));
    expect(p('1').compareTo(p('-1')), equals(1));
    expect(p('-1').compareTo(p('1')), equals(-1));
  });
  test('operator +(BigInt other)', () {
    expect((p('1') + p('2')).toString(), equals('3'));
    expect((p('1') + p('-2')).toString(), equals('-1'));
    expect((p('-1') + p('2')).toString(), equals('1'));
    expect((p('-1') + p('-2')).toString(), equals('-3'));
    expect(
        (p('31878018903828899277492024491376690701584023926880') + p('1'))
            .toString(),
        equals('31878018903828899277492024491376690701584023926881'));
    expect(
        (p('10000000000000000000000000000000000000000000000000') +
                p('10000000000000000000000000000000000000000000000000'))
            .toString(),
        equals('20000000000000000000000000000000000000000000000000'));
  });
  test('operator -(BigInt other)', () {
    expect((p('1') - p('2')).toString(), equals('-1'));
    expect((p('1') - p('-2')).toString(), equals('3'));
    expect((p('-1') - p('2')).toString(), equals('-3'));
    expect((p('-1') - p('-2')).toString(), equals('1'));
    expect(
        (p('31878018903828899277492024491376690701584023926880') - p('1'))
            .toString(),
        equals('31878018903828899277492024491376690701584023926879'));
    expect(
        (p('10000000000000000000000000000000000000000000000000') -
                p('1000000000000000000000000000000000000000000000000'))
            .toString(),
        equals('9000000000000000000000000000000000000000000000000'));
  });
  test('operator *(BigInt other)', () {
    expect((p('1') * p('2')).toString(), equals('2'));
    expect((p('1') * p('-2')).toString(), equals('-2'));
    expect((p('-1') * p('2')).toString(), equals('-2'));
    expect((p('-1') * p('-2')).toString(), equals('2'));
    expect(
        (p('31878018903828899277492024491376690701584023926880') * p('1'))
            .toString(),
        equals('31878018903828899277492024491376690701584023926880'));
    expect(
        (p('10000000000000000000000000000000000000000000000000') *
                p('10000000000000000000000000000000000000000000000000'))
            .toString(),
        equals(
            '100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'));
    for (int i = 0; i < 100; i++) {
      final n = '1' + (new List.filled(i, 0)).join();
      expect((p(n) * p(n)).toString(),
          equals('1' + (new List.filled(2 * i, 0)).join()));
    }
  });
  test('operator %(BigInt other)', () {
    expect((p('2') % p('1')).toString(), equals('0'));
    expect((p('10') % p('3')).toString(), equals('1'));
    expect((p('1000000000') % p('3')).toString(), equals('1'));
    for (int i = -10; i < 10; i++) {
      for (int j = -10; j < 10; j++) {
        if (j == 0) continue;
        expect((p(i.toString()) % p(j.toString())).toString(),
            equals((i % j).toString()),
            reason: "$i % $j");
      }
    }
    expect((p('7') % p('-3')).toString(), equals((7 % -3).toString()));
    expect((p('-7') % p('3')).toString(), equals(((-7) % 3).toString()));
    expect((p('-7') % p('-3')).toString(), equals(((-7) % -3).toString()));
  });
  test('operator ~/(BigInt other)', () {
    expect((p('-10') ~/ p('-9')).toString(), equals('1'));
    expect((p('2') ~/ p('1')).toString(), equals('2'));
    expect((p('10') ~/ p('3')).toString(), equals('3'));
    expect((p('1000000000') ~/ p('3')).toString(), equals('333333333'));
    for (int i = -10; i < 10; i++) {
      for (int j = -10; j < 10; j++) {
        if (j == 0) continue;
        expect((p(i.toString()) ~/ p(j.toString())).toString(),
            equals((i ~/ j).toString()),
            reason: "$i ~/ $j");
      }
    }
    expect((p('7') % p('-3')).toString(), equals((7 % -3).toString()));
    expect((p('-7') % p('3')).toString(), equals(((-7) % 3).toString()));
    expect((p('-7') % p('-3')).toString(), equals(((-7) % -3).toString()));
  });
  test('operator -()', () {
    expect((-p('1')).toString(), equals('-1'));
    expect((-p('-1')).toString(), equals('1'));
  });
}
