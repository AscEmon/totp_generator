/// A flexible TOTP generator supporting Base32, Base64, custom time, and hash algorithms.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class TOTPGenerator {
  /// Decodes a Base32-encoded string into raw bytes (RFC 4648)
  Uint8List _base32Decode(String input) {
    const base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleaned = input.replaceAll(RegExp(r'=+$'), '').toUpperCase();

    int buffer = 0;
    int bitsLeft = 0;
    final output = <int>[];

    for (final char in cleaned.codeUnits) {
      final index = base32Chars.indexOf(String.fromCharCode(char));
      if (index == -1) {
        throw FormatException('Invalid Base32 character: $char');
      }

      buffer = (buffer << 5) | index;
      bitsLeft += 5;

      while (bitsLeft >= 8) {
        bitsLeft -= 8;
        output.add((buffer >> bitsLeft) & 0xFF);
      }
    }

    return Uint8List.fromList(output);
  }

  /// Generates a TOTP code from a secret key.
  ///
  /// [secret] can be in Base32 or Base64 format.
  /// [encoding] specifies the encoding of the secret: 'base32' or 'base64'.
  /// [digits] is the number of digits in the output (default: 6).
  /// [interval] is the time step in seconds (default: 30).
  /// [time] is the timestamp to use (defaults to current UTC time).
  /// [algorithm] is the hash algorithm (default: SHA-1).
  ///
  /// Returns a zero-padded string of length [digits].
  String generateTOTP({
    required String secret,
    required String encoding, // 'base32' or 'base64'
    int digits = 6,
    int interval = 30,
    DateTime? time,
    HashAlgorithm algorithm = HashAlgorithm.sha1,
  }) {
    late Uint8List keyBytes;

    try {
      if (encoding.toLowerCase() == 'base32') {
        keyBytes = _base32Decode(secret);
      } else if (encoding.toLowerCase() == 'base64') {
        keyBytes = base64.decode(secret);
      } else {
        throw FormatException('Encoding must be "base32" or "base64"');
      }
    } on FormatException {
      throw const FormatException('Invalid secret encoding');
    } on ArgumentError {
      throw const FormatException('Invalid base64 string');
    }

    final timestamp =
        (time?.toUtc().millisecondsSinceEpoch ??
            DateTime.now().toUtc().millisecondsSinceEpoch) ~/
        1000;
    final counter = timestamp ~/ interval;

    final timeBytes = _intToUint8List(counter);

    final hmac = _createHmac(algorithm, keyBytes, timeBytes);
    final hmacBytes = hmac.convert(timeBytes).bytes;

    // HOTP truncation
    final offset = hmacBytes.last & 0x0F;
    final binary =
        ((hmacBytes[offset] & 0x7F) << 24) |
        ((hmacBytes[offset + 1] & 0xFF) << 16) |
        ((hmacBytes[offset + 2] & 0xFF) << 8) |
        (hmacBytes[offset + 3] & 0xFF);

    final otp = binary % _pow(10, digits);
    return otp.toString().padLeft(digits, '0');
  }

  Uint8List _intToUint8List(int value) {
    final bytes = Uint8List(8);
    for (int i = 7; i >= 0; i--) {
      bytes[i] = value & 0xFF;
      value >>= 8;
    }
    return bytes;
  }

  Hmac _createHmac(HashAlgorithm algorithm, Uint8List key, Uint8List data) {
    switch (algorithm) {
      case HashAlgorithm.sha1:
        return Hmac(sha1, key);
      case HashAlgorithm.sha256:
        return Hmac(sha256, key);
      case HashAlgorithm.sha512:
        return Hmac(sha512, key);
    }
  }

  int _pow(int base, int exponent) {
    return pow(base, exponent).toInt();
  }
}

/// Supported hash algorithms for TOTP
enum HashAlgorithm { sha1, sha256, sha512 }
