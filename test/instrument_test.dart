import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('StringConfig', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const config = StringConfig(openNote: PitchClass.e, octave: 2);
        expect(config.openNote, equals(PitchClass.e));
        expect(config.octave, equals(2));
        expect(config.fretCount, equals(22)); // default
      });

      test('accepts custom fret count', () {
        const config = StringConfig(
          openNote: PitchClass.g,
          octave: 4,
          fretCount: 15,
        );
        expect(config.fretCount, equals(15));
      });
    });

    group('parse', () {
      test('parses note with octave', () {
        final config = StringConfig.parse('E2');
        expect(config.openNote, equals(PitchClass.e));
        expect(config.octave, equals(2));
      });

      test('parses sharps', () {
        final config = StringConfig.parse('F#3');
        expect(config.openNote, equals(PitchClass.fSharp));
        expect(config.octave, equals(3));
      });

      test('parses flats', () {
        final config = StringConfig.parse('Bb4');
        expect(config.openNote, equals(PitchClass.aSharp));
        expect(config.octave, equals(4));
      });

      test('accepts custom fret count', () {
        final config = StringConfig.parse('G3', fretCount: 20);
        expect(config.fretCount, equals(20));
      });

      test('throws on invalid format', () {
        expect(() => StringConfig.parse('E'), throwsFormatException);
        expect(() => StringConfig.parse('2'), throwsFormatException);
        expect(() => StringConfig.parse('EE2'), throwsFormatException);
        expect(() => StringConfig.parse(''), throwsFormatException);
      });
    });

    group('noteAtFret', () {
      test('returns open note at fret 0', () {
        const config = StringConfig(openNote: PitchClass.e, octave: 2);
        expect(config.noteAtFret(0), equals(PitchClass.e));
      });

      test('returns transposed note at higher frets', () {
        const config = StringConfig(openNote: PitchClass.e, octave: 2);
        expect(config.noteAtFret(1), equals(PitchClass.f));
        expect(config.noteAtFret(2), equals(PitchClass.fSharp));
        expect(config.noteAtFret(5), equals(PitchClass.a));
        expect(config.noteAtFret(12), equals(PitchClass.e));
      });

      test('throws on negative fret', () {
        const config = StringConfig(openNote: PitchClass.e, octave: 2);
        expect(() => config.noteAtFret(-1), throwsRangeError);
      });

      test('throws on fret beyond fretCount', () {
        const config = StringConfig(openNote: PitchClass.e, octave: 2);
        expect(() => config.noteAtFret(23), throwsRangeError);
      });
    });

    group('toString', () {
      test('returns note with octave', () {
        const config = StringConfig(openNote: PitchClass.e, octave: 2);
        expect(config.toString(), equals('E2'));
      });

      test('includes sharp in name', () {
        const config = StringConfig(openNote: PitchClass.fSharp, octave: 3);
        expect(config.toString(), equals('F#3'));
      });
    });

    group('equality', () {
      test('equal configs are equal', () {
        const a = StringConfig(openNote: PitchClass.e, octave: 2);
        const b = StringConfig(openNote: PitchClass.e, octave: 2);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different notes are not equal', () {
        const a = StringConfig(openNote: PitchClass.e, octave: 2);
        const b = StringConfig(openNote: PitchClass.a, octave: 2);
        expect(a, isNot(equals(b)));
      });

      test('different octaves are not equal', () {
        const a = StringConfig(openNote: PitchClass.e, octave: 2);
        const b = StringConfig(openNote: PitchClass.e, octave: 3);
        expect(a, isNot(equals(b)));
      });

      test('different fret counts are not equal', () {
        const a = StringConfig(openNote: PitchClass.e, octave: 2);
        const b = StringConfig(openNote: PitchClass.e, octave: 2, fretCount: 20);
        expect(a, isNot(equals(b)));
      });
    });
  }, tags: ['unit']);

  group('Instrument', () {
    group('constructor', () {
      test('creates custom instrument', () {
        const mandolin = Instrument(
          name: 'Mandolin',
          strings: [
            StringConfig(openNote: PitchClass.g, octave: 3, fretCount: 20),
            StringConfig(openNote: PitchClass.d, octave: 4, fretCount: 20),
            StringConfig(openNote: PitchClass.a, octave: 4, fretCount: 20),
            StringConfig(openNote: PitchClass.e, octave: 5, fretCount: 20),
          ],
        );

        expect(mandolin.name, equals('Mandolin'));
        expect(mandolin.stringCount, equals(4));
      });
    });

    group('withTuning', () {
      test('creates copy with new tuning', () {
        final dropD = Instruments.guitar.withTuning([
          const StringConfig(openNote: PitchClass.d, octave: 2),
          const StringConfig(openNote: PitchClass.a, octave: 2),
          const StringConfig(openNote: PitchClass.d, octave: 3),
          const StringConfig(openNote: PitchClass.g, octave: 3),
          const StringConfig(openNote: PitchClass.b, octave: 3),
          const StringConfig(openNote: PitchClass.e, octave: 4),
        ]);

        expect(dropD.strings[0].openNote, equals(PitchClass.d));
        expect(dropD.name, equals('Guitar'));
      });

      test('throws if string count does not match', () {
        expect(
          () => Instruments.guitar.withTuning([
            const StringConfig(openNote: PitchClass.d, octave: 2),
          ]),
          throwsArgumentError,
        );
      });
    });

    group('withTuningFromString', () {
      test('parses tuning string', () {
        final dropD =
            Instruments.guitar.withTuningFromString('D2 A2 D3 G3 B3 E4');
        expect(dropD.strings[0].openNote, equals(PitchClass.d));
        expect(dropD.strings[0].octave, equals(2));
      });

      test('preserves fret counts', () {
        final retuned = Instruments.bass.withTuningFromString('B0 E1 A1 D2');
        expect(retuned.strings[0].fretCount, equals(20));
      });

      test('throws if note count does not match', () {
        expect(
          () => Instruments.guitar.withTuningFromString('E2 A2 D3'),
          throwsArgumentError,
        );
      });
    });

    group('equality', () {
      test('equal instruments are equal', () {
        const a = Instruments.guitar;
        const b = Instruments.guitar;
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different instruments are not equal', () {
        expect(Instruments.guitar, isNot(equals(Instruments.bass)));
      });

      test('same instrument with different tuning is not equal', () {
        final dropD =
            Instruments.guitar.withTuningFromString('D2 A2 D3 G3 B3 E4');
        expect(Instruments.guitar, isNot(equals(dropD)));
      });
    });
  }, tags: ['unit']);
}
