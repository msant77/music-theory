import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('PitchClass', () {
    group('values', () {
      test('has 12 pitch classes', () {
        expect(PitchClass.values.length, equals(12));
      });

      test('are in chromatic order', () {
        expect(PitchClass.values[0], equals(PitchClass.c));
        expect(PitchClass.values[1], equals(PitchClass.cSharp));
        expect(PitchClass.values[11], equals(PitchClass.b));
      });
    });

    group('name', () {
      test('returns correct display names', () {
        expect(PitchClass.c.name, equals('C'));
        expect(PitchClass.cSharp.name, equals('C#'));
        expect(PitchClass.fSharp.name, equals('F#'));
        expect(PitchClass.b.name, equals('B'));
      });

      test('toString returns name', () {
        expect(PitchClass.a.toString(), equals('A'));
        expect(PitchClass.gSharp.toString(), equals('G#'));
      });
    });

    group('transpose', () {
      test('transposes up by semitones', () {
        expect(PitchClass.c.transpose(1), equals(PitchClass.cSharp));
        expect(PitchClass.c.transpose(2), equals(PitchClass.d));
        expect(PitchClass.c.transpose(7), equals(PitchClass.g));
        expect(PitchClass.c.transpose(12), equals(PitchClass.c));
      });

      test('wraps around at octave', () {
        expect(PitchClass.g.transpose(5), equals(PitchClass.c));
        expect(PitchClass.b.transpose(1), equals(PitchClass.c));
        expect(PitchClass.a.transpose(3), equals(PitchClass.c));
      });

      test('handles negative semitones', () {
        expect(PitchClass.c.transpose(-1), equals(PitchClass.b));
        expect(PitchClass.c.transpose(-2), equals(PitchClass.aSharp));
        expect(PitchClass.g.transpose(-7), equals(PitchClass.c));
      });

      test('handles large values', () {
        expect(PitchClass.c.transpose(24), equals(PitchClass.c));
        expect(PitchClass.c.transpose(25), equals(PitchClass.cSharp));
        expect(PitchClass.c.transpose(-24), equals(PitchClass.c));
      });
    });

    group('parse', () {
      test('parses natural notes', () {
        expect(PitchClass.parse('C'), equals(PitchClass.c));
        expect(PitchClass.parse('D'), equals(PitchClass.d));
        expect(PitchClass.parse('E'), equals(PitchClass.e));
        expect(PitchClass.parse('F'), equals(PitchClass.f));
        expect(PitchClass.parse('G'), equals(PitchClass.g));
        expect(PitchClass.parse('A'), equals(PitchClass.a));
        expect(PitchClass.parse('B'), equals(PitchClass.b));
      });

      test('parses sharps', () {
        expect(PitchClass.parse('C#'), equals(PitchClass.cSharp));
        expect(PitchClass.parse('D#'), equals(PitchClass.dSharp));
        expect(PitchClass.parse('F#'), equals(PitchClass.fSharp));
        expect(PitchClass.parse('G#'), equals(PitchClass.gSharp));
        expect(PitchClass.parse('A#'), equals(PitchClass.aSharp));
      });

      test('parses flats as enharmonic equivalents', () {
        expect(PitchClass.parse('Db'), equals(PitchClass.cSharp));
        expect(PitchClass.parse('Eb'), equals(PitchClass.dSharp));
        expect(PitchClass.parse('Gb'), equals(PitchClass.fSharp));
        expect(PitchClass.parse('Ab'), equals(PitchClass.gSharp));
        expect(PitchClass.parse('Bb'), equals(PitchClass.aSharp));
      });

      test('parses edge case enharmonics', () {
        expect(PitchClass.parse('E#'), equals(PitchClass.f));
        expect(PitchClass.parse('Fb'), equals(PitchClass.e));
        expect(PitchClass.parse('B#'), equals(PitchClass.c));
        expect(PitchClass.parse('Cb'), equals(PitchClass.b));
      });

      test('is case insensitive', () {
        expect(PitchClass.parse('c'), equals(PitchClass.c));
        expect(PitchClass.parse('c#'), equals(PitchClass.cSharp));
        expect(PitchClass.parse('db'), equals(PitchClass.cSharp));
        expect(PitchClass.parse('BB'), equals(PitchClass.aSharp));
      });

      test('trims whitespace', () {
        expect(PitchClass.parse('  C  '), equals(PitchClass.c));
        expect(PitchClass.parse('\tF#\n'), equals(PitchClass.fSharp));
      });

      test('throws on invalid input', () {
        expect(() => PitchClass.parse('H'), throwsFormatException);
        expect(() => PitchClass.parse('X'), throwsFormatException);
        expect(() => PitchClass.parse(''), throwsFormatException);
        expect(() => PitchClass.parse('C##'), throwsFormatException);
        expect(() => PitchClass.parse('C4'), throwsFormatException);
      });
    });

    group('tryParse', () {
      test('returns pitch class on valid input', () {
        expect(PitchClass.tryParse('C'), equals(PitchClass.c));
        expect(PitchClass.tryParse('F#'), equals(PitchClass.fSharp));
      });

      test('returns null on invalid input', () {
        expect(PitchClass.tryParse('H'), isNull);
        expect(PitchClass.tryParse(''), isNull);
        expect(PitchClass.tryParse('invalid'), isNull);
      });
    });
  }, tags: ['unit']);
}
