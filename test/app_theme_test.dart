import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/theme/app_theme.dart';

void main() {
  test('both themes carry the GameColors extension', () {
    expect(AppTheme.dark.extension<GameColors>(), GameColors.dark);
    expect(AppTheme.light.extension<GameColors>(), GameColors.light);
  });
}
