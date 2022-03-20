# 2.2.0 (2022-03-20)

- Explicitly throw an `ArgumentError` when a Rational is created with a zero denominator.

# 2.1.0 (2022-01-27)

- Add `Rational.tryParse`.

# 2.0.0 (2021-11-29)

The goal of this version is to move several decimal methods back to the [decimal](https://pub.dev/packages/decimal) package and to have sharper types on the API.

It introduces several breaking changes.

- `~/`, `round()`, `floor()`, `ceil()`, `truncate()` now return a `BigInt`. If you need a `Rational` you can convert the `BigInt` to `Rational` with `bigint.toRational()`.
- Removal of `toDecimalString()`. You can replace it with `rational.toDecimal(scaleOnInfinitePrecision: 10).toString()` using the [decimal](https://pub.dev/packages/decimal) package.
- Removal of `isNaN` getter. It was always returning `false`.
- Removal of `isInfinite` getter. It was always returning `false`.
- Removal of `isNegative` getter. You can replace it with `rational < Rational.zero`.
- Removal of `roundToDouble()`, `floorToDouble()`, `ceilToDouble()`, `truncateToDouble()`. You can replace them by `round().toDouble()`, `floor().toDouble()`, `ceil().toDouble()`, `truncate().toDouble()`.
- Removal of `toInt()`. You can replace it with `rational.toBigInt().toInt()`.
- Removal of `hasFinitePrecision` getter. This getter (provided as extension on `Rational`) is now part of the [decimal](https://pub.dev/packages/decimal) package.
- Removal of `precision` and `scale` getters. They was only available on rational returning `true` on `hasFinitePrecision` (ie. decimal numbers). You can replace them with `rational.toDecimal().precision` and `rational.toDecimal().scale` using the [decimal](https://pub.dev/packages/decimal) package.
- Removal of `toStringAsFixed`, `toStringAsExponential` and `toStringAsPrecision`. You can replace them with `rational.toDecimal(scaleOnInfinitePrecision: xxx).toStringAsFixed`,`rational.toDecimal(scaleOnInfinitePrecision: xxx).toStringAsExponential` and `rational.toDecimal(scaleOnInfinitePrecision: xxx).toStringAsPrecision` using the [decimal](https://pub.dev/packages/decimal) package.

Other changes:

- Add extension method `toRational()` on `int`.
- Add extension method `toRational()` on `BigInt`.

# 1.2.1 (2021-05-28)

- Improve performance of several methods by working around the issue [BigInt.gcd() is really slow](https://github.com/dart-lang/sdk/issues/46180) with a custom `gcd` implementation based on [Euclidean algorithm](https://en.wikipedia.org/wiki/Euclidean_algorithm).

# 1.2.0 (2021-05-28)

- Improve parsing of number with big exponent part. However the exponent part
must now be parsable as an int.

# 1.1.0+1 (2021-04-29)

- Fix the doc of `pow`.

# 1.1.0 (2021-04-29)

- Allow negative value as exponent of `pow`.

# 1.0.0 (2021-02-25)

- Stable null safety release.

# 1.0.0-nullsafety (2020-11-27)

- Migrate to nullsafety.

# 0.3.8 (2020-01-30)

- Improve pub score.

# 0.3.7 (2019-09-02)

- [Replace gcd implementation with dart:core's](https://github.com/a14n/dart-rational/pull/23).

# 0.3.6 (2019-09-02)

- add `Rational.pow`.

# 0.3.5 (2019-07-29)

- add `Rational.zero` and `Rational.one`.
- add `Rational.inverse`.

# 0.3.4 (2019-04-25)

- [allow numbers starting with dot](https://github.com/a14n/dart-rational/issues/21).

# 0.3.3 (2019-04-08)

- fix [issue with `signnum`](https://github.com/a14n/dart-decimal/issues/21).

# 0.3.2 (2019-03-19)

- fix [issue with `toStringAsPrecision`](https://github.com/a14n/dart-decimal/issues/19).

# 0.3.1 (2018-07-24)

- migration to Dart 2.

# 0.3.0 (2018-07-10)

- allow parsing of `1.`.
- make `Rational.parse` a factory constructor.

# 0.2.0 (2018-03-15)

- move to Dart SDK 2.0
- remove `BigInt` class
- use `BigInt` provided by `dart:core`

# v0.1.11 (2017-06-16)

- add types.

# v0.1.10+1 (2017-02-19)

- fix [bug on `operator %` with negative values](https://github.com/a14n/dart-rational/issues/16) on browser.

# v0.1.10 (2017-02-19)

- fix [bug on `operator %` with negative values](https://github.com/a14n/dart-rational/issues/16).

# v0.1.9 (2016-06-10)

- fix a [bug on `BigInt.toDouble`](https://github.com/a14n/dart-rational/issues/14).

# v0.1.8+1 (2014-10-29)

- fix a bug for `Rational.precision` on negative number.

# v0.1.8 (2014-10-29)

- fix bugs with dart2js
- add `Rational.signum`
- add `Rational.hasFinitePrecision`
- add `Rational.precision`
- add `Rational.scale`

# v0.1.7 (2014-10-07)

- `Rational.parse` accepts strings in scientific notation (eg. `1.5e-3`).

# v0.1.6 (2014-10-06)

- `BigInt.parse` accepts an optional prepending `+` for positive integers.

# Semantic Version Conventions

http://semver.org/

- *Stable*:  All even numbered minor versions are considered API stable:
  i.e.: v1.0.x, v1.2.x, and so on.
- *Development*: All odd numbered minor versions are considered API unstable:
  i.e.: v0.9.x, v1.1.x, and so on.
