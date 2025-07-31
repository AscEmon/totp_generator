import 'package:totp_generator/totp_generator.dart';
import 'package:test/test.dart';

void main() {
  test('generates valid TOTP code', () {
    TOTPGenerator totpGenerator = TOTPGenerator();
    final code = totpGenerator.generateTOTP(
      secret: 'JBSWY3DPEHPK3PXP',
      encoding: 'base32',
    );
    print(code);
    expect(code.length, 6);
  });
}
