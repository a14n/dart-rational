
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
