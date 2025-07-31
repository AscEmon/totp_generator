# TOTP Generator
A flexible and easy-to-use Time-based One-Time Password (TOTP) generator for Dart and Flutter applications. This package supports multiple hash algorithms and secret encodings, making it compatible with most TOTP implementations.

## Features

- ✅ Generate TOTP codes from Base32 or Base64 encoded secrets
- 🔄 Multiple hash algorithm support (SHA-1, SHA-256, SHA-512)
- ⏱️ Customizable time step intervals
- 🔢 Configurable code length (digits)
- 🕒 Support for custom timestamps
- 🚀 Lightweight and fast
- 🧪 100% test coverage
- 📱 Works with Flutter and pure Dart projects

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  totp_generator: ^1.0.0
```

Then run:

```bash
flutter pub get
# or
dart pub get
```

## Usage

### Basic Usage

```dart
import 'package:totp_generator/totp_generator.dart';

void main() {
  final totp = TOTPGenerator();
  
  // Generate a TOTP using a Base32 secret (most common)
  final code = totp.generateTOTP(
    secret: 'JBSWY3DPEHPK3PXP',  // Example secret (Base32)
    encoding: 'base32',
  );
  
  print('Generated TOTP: $code');
}
```

### Advanced Usage

```dart
import 'package:totp_generator/totp_generator.dart';

void main() {
  final totp = TOTPGenerator();
  
  // Generate a TOTP with custom parameters
  final code = totp.generateTOTP(
    secret: 'MTIzNDU2Nzg5MDEyMzQ1Njc4OTA=',  // Example secret (Base64)
    encoding: 'base64',
    digits: 8,                                 // 8-digit code
    interval: 60,                             // 60-second time step
    algorithm: HashAlgorithm.sha256,          // Use SHA-256
    time: DateTime.now().subtract(Duration(minutes: 1)), // Custom time
  );
  
  print('Generated TOTP: $code');
}
```

## API Reference

### `TOTPGenerator`

The main class for generating TOTP codes.

#### Methods

##### `generateTOTP`

Generates a TOTP code using the provided parameters.

```dart
String generateTOTP({
  required String secret,
  required String encoding,
  int digits = 6,
  int interval = 30,
  DateTime? time,
  HashAlgorithm algorithm = HashAlgorithm.sha1,
})
```

**Parameters:**

- `secret` (required): The shared secret key in Base32 or Base64 format.
- `encoding` (required): The encoding of the secret ('base32' or 'base64').
- `digits`: The number of digits in the generated code (default: 6).
- `interval`: The time step in seconds (default: 30).
- `time`: The timestamp to use for code generation (defaults to current UTC time).
- `algorithm`: The hash algorithm to use (default: `HashAlgorithm.sha1`).

**Returns:** A string containing the generated TOTP code.

### `HashAlgorithm`

An enum representing the supported hash algorithms:

- `HashAlgorithm.sha1`
- `HashAlgorithm.sha256`
- `HashAlgorithm.sha512`

## Error Handling

The package throws `FormatException` in the following cases:
- When an invalid encoding is provided (not 'base32' or 'base64')
- When the secret contains invalid characters for the specified encoding
- When the Base64 string is malformed

## Example Project

For a complete example, see the `example` directory in the package.

## Testing

Run the tests with:

```bash
flutter test
# or
dart test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Based on [RFC 6238](https://tools.ietf.org/html/rfc6238) (TOTP)
- Inspired by various OTP implementations
