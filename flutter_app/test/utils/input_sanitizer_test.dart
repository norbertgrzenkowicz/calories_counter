import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/input_sanitizer.dart';

void main() {
  group('InputSanitizer', () {
    group('sanitizeText', () {
      test('removes dangerous characters', () {
        expect(InputSanitizer.sanitizeText('<script>alert("xss")</script>'),
            equals('alert(xss)'));
        expect(InputSanitizer.sanitizeText('test"; DROP TABLE users; --'),
            equals('test DROP TABLE users --'));
        expect(
            InputSanitizer.sanitizeText('normal text'), equals('normal text'));
      });

      test('handles null and empty input', () {
        expect(InputSanitizer.sanitizeText(null), equals(''));
        expect(InputSanitizer.sanitizeText(''), equals(''));
      });

      test('normalizes whitespace', () {
        expect(InputSanitizer.sanitizeText('  multiple   spaces  '),
            equals('multiple spaces'));
        expect(InputSanitizer.sanitizeText('line\n\nbreaks'),
            equals('line breaks'));
      });
    });

    group('sanitizeMealName', () {
      test('sanitizes meal names correctly', () {
        expect(InputSanitizer.sanitizeMealName('Chicken & Rice'),
            equals('Chicken Rice'));
        expect(InputSanitizer.sanitizeMealName('Pizza (Large)'),
            equals('Pizza (Large)'));
        expect(InputSanitizer.sanitizeMealName('<script>Pasta</script>'),
            equals('Pasta'));
      });

      test('limits meal name length', () {
        final longName = 'a' * 150;
        final result = InputSanitizer.sanitizeMealName(longName);
        expect(result.length, lessThanOrEqualTo(100));
      });
    });

    group('sanitizeNumeric', () {
      test('parses valid numbers', () {
        expect(InputSanitizer.sanitizeNumeric('123.45'), equals(123.45));
        expect(InputSanitizer.sanitizeNumeric('100'), equals(100.0));
        expect(InputSanitizer.sanitizeNumeric('0'), equals(0.0));
      });

      test('handles invalid input', () {
        expect(InputSanitizer.sanitizeNumeric('not a number'), isNull);
        expect(InputSanitizer.sanitizeNumeric(''), isNull);
        expect(InputSanitizer.sanitizeNumeric(null), isNull);
      });

      test('applies bounds correctly', () {
        expect(InputSanitizer.sanitizeNumeric('50', min: 100), equals(100));
        expect(InputSanitizer.sanitizeNumeric('150', max: 100), equals(100));
        expect(InputSanitizer.sanitizeNumeric('75', min: 50, max: 100),
            equals(75));
      });

      test('removes non-numeric characters', () {
        expect(InputSanitizer.sanitizeNumeric(r'$123.45'), equals(123.45));
        expect(InputSanitizer.sanitizeNumeric('1,234.56'), equals(1234.56));
      });
    });

    group('sanitizeCalories', () {
      test('sanitizes calorie input', () {
        expect(InputSanitizer.sanitizeCalories('250'), equals(250));
        expect(InputSanitizer.sanitizeCalories('250.7'), equals(251));
        expect(InputSanitizer.sanitizeCalories('-100'), equals(0));
        expect(InputSanitizer.sanitizeCalories('15000'), equals(10000));
      });
    });

    group('sanitizeMacroNutrient', () {
      test('sanitizes macro nutrient input', () {
        expect(InputSanitizer.sanitizeMacroNutrient('25.5'), equals(25.5));
        expect(InputSanitizer.sanitizeMacroNutrient('-5'), equals(0));
        expect(InputSanitizer.sanitizeMacroNutrient('2000'), equals(1000));
      });
    });

    group('sanitizeBarcode', () {
      test('validates barcode format', () {
        expect(InputSanitizer.sanitizeBarcode('1234567890123'),
            equals('1234567890123'));
        expect(
            InputSanitizer.sanitizeBarcode('123-456-789'), equals('123456789'));
        expect(InputSanitizer.sanitizeBarcode('12345'), isNull); // too short
        expect(InputSanitizer.sanitizeBarcode('123456789012345'),
            isNull); // too long
        expect(InputSanitizer.sanitizeBarcode('abc12345678'),
            equals('12345678')); // removes letters
      });
    });

    group('sanitizePhotoUrl', () {
      test('validates HTTPS URLs', () {
        expect(InputSanitizer.sanitizePhotoUrl('https://supabase.co/image.jpg'),
            equals('https://supabase.co/image.jpg'));
        expect(InputSanitizer.sanitizePhotoUrl('http://example.com/image.jpg'),
            isNull);
        expect(InputSanitizer.sanitizePhotoUrl('not-a-url'), isNull);
      });

      test('validates allowed domains', () {
        expect(InputSanitizer.sanitizePhotoUrl('https://evil.com/image.jpg'),
            isNull);
        expect(
            InputSanitizer.sanitizePhotoUrl(
                'https://sub.supabase.co/image.jpg'),
            equals('https://sub.supabase.co/image.jpg'));
      });
    });

    group('sanitizeEmail', () {
      test('validates email format', () {
        expect(InputSanitizer.sanitizeEmail('test@example.com'),
            equals('test@example.com'));
        expect(InputSanitizer.sanitizeEmail('TEST@Example.COM'),
            equals('test@example.com'));
        expect(InputSanitizer.sanitizeEmail('invalid-email'), isNull);
        expect(InputSanitizer.sanitizeEmail('test@'), isNull);
      });
    });

    group('removeXSS', () {
      test('removes XSS attempts', () {
        expect(InputSanitizer.removeXSS('<script>alert("xss")</script>text'),
            equals('text'));
        expect(InputSanitizer.removeXSS('javascript:alert("xss")'),
            equals('alert("xss")'));
        expect(InputSanitizer.removeXSS('<div onclick="alert()">text</div>'),
            contains('text'));
      });
    });

    group('sanitizeFilename', () {
      test('creates safe filenames', () {
        expect(InputSanitizer.sanitizeFilename('normal_file.jpg'),
            equals('normal_file.jpg'));
        expect(InputSanitizer.sanitizeFilename('../../../etc/passwd'),
            equals('etcpasswd'));
        expect(InputSanitizer.sanitizeFilename('file<>:"|?*.txt'),
            equals('file.txt'));
      });

      test('limits filename length', () {
        final longName = 'a' * 300;
        final result = InputSanitizer.sanitizeFilename(longName);
        expect(result.length, lessThanOrEqualTo(255));
      });
    });
  });
}
