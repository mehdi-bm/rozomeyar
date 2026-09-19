import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/domain/services/resume_validator.dart';

void main() {
  group('isBlank', () {
    test('treats null, empty and whitespace as blank', () {
      expect(ResumeValidator.isBlank(null), isTrue);
      expect(ResumeValidator.isBlank(''), isTrue);
      expect(ResumeValidator.isBlank('   '), isTrue);
      expect(ResumeValidator.isBlank('  م  '), isFalse);
    });
  });

  group('isValidEmail', () {
    test('accepts ordinary addresses', () {
      expect(ResumeValidator.isValidEmail('mehdi@example.com'), isTrue);
      expect(ResumeValidator.isValidEmail('a.b-c+d@sub.example.co.uk'), isTrue);
      expect(ResumeValidator.isValidEmail('  spaced@example.com  '), isTrue);
    });

    test('rejects malformed addresses', () {
      expect(ResumeValidator.isValidEmail('mehdi'), isFalse);
      expect(ResumeValidator.isValidEmail('mehdi@'), isFalse);
      expect(ResumeValidator.isValidEmail('@example.com'), isFalse);
      expect(ResumeValidator.isValidEmail('mehdi@example'), isFalse);
      expect(ResumeValidator.isValidEmail('a b@example.com'), isFalse);
    });
  });

  group('isValidUrl', () {
    test('accepts full URLs', () {
      expect(ResumeValidator.isValidUrl('https://example.com'), isTrue);
      expect(ResumeValidator.isValidUrl('http://example.com/path?x=1'), isTrue);
    });

    test('accepts bare domains, since users rarely type the scheme', () {
      expect(ResumeValidator.isValidUrl('example.com'), isTrue);
      expect(ResumeValidator.isValidUrl('linkedin.com/in/mehdi'), isTrue);
    });

    test('rejects malformed values', () {
      expect(ResumeValidator.isValidUrl(''), isFalse);
      expect(ResumeValidator.isValidUrl('   '), isFalse);
      expect(ResumeValidator.isValidUrl('not a url'), isFalse);
      expect(ResumeValidator.isValidUrl('localhost'), isFalse);
      expect(ResumeValidator.isValidUrl('example.'), isFalse);
      expect(ResumeValidator.isValidUrl('ftp://example.com'), isFalse);
    });
  });

  group('normalizeUrl', () {
    test('adds https when no scheme is present', () {
      expect(
        ResumeValidator.normalizeUrl('example.com'),
        'https://example.com',
      );
    });

    test('keeps an existing scheme', () {
      expect(
        ResumeValidator.normalizeUrl('http://example.com'),
        'http://example.com',
      );
    });

    test('leaves an empty value alone', () {
      expect(ResumeValidator.normalizeUrl('   '), '');
    });
  });
}
