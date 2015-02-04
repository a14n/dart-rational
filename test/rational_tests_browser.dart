library test_browser;

import 'package:unittest/html_config.dart';
import 'bigint_tests.dart' as bigint;
import 'rational_test.dart' as rational;

main() {
  useHtmlConfiguration();
  bigint.main();
  rational.main();
}
