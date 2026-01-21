import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('Tuning', () {
    group('constructor', () {
      test('creates tuning with name and strings', () {
        const tuning = Tuning(
          name: 'Test',
          strings: [
            StringConfig(openNote: PitchClass.e, octave: 2),
            StringConfig(openNote: PitchClass.a, octave: 2),
          ],
        );
        expect(tuning.name, equals('Test'));
        expect(tuning.stringCount, equals(2));
      });
    });

    group('parse', () {
      test('parses space-separated notes', () {
        final tuning = Tuning.parse('Custom', 'E2 A2 D3 G3 B3 E4');
        expect(tuning.name, equals('Custom'));
        expect(tuning.stringCount, equals(6));
        expect(tuning.strings[0].openNote, equals(PitchClass.e));
        expect(tuning.strings[0].octave, equals(2));
        expect(tuning.strings[5].openNote, equals(PitchClass.e));
        expect(tuning.strings[5].octave, equals(4));
      });

      test('accepts custom fret count', () {
        final tuning = Tuning.parse('Bass', 'E1 A1 D2 G2', fretCount: 20);
        for (final string in tuning.strings) {
          expect(string.fretCount, equals(20));
        }
      });

      test('handles sharps and flats', () {
        final tuning = Tuning.parse('Test', 'F#3 Bb3');
        expect(tuning.strings[0].openNote, equals(PitchClass.fSharp));
        expect(tuning.strings[1].openNote, equals(PitchClass.aSharp));
      });
    });

    group('applyTo', () {
      test('applies tuning to instrument', () {
        final dropD = Tunings.guitar.dropD.applyTo(Instruments.guitar);
        expect(dropD.strings[0].openNote, equals(PitchClass.d));
        expect(dropD.strings[0].octave, equals(2));
        expect(dropD.name, equals('Guitar'));
      });

      test('throws if string count mismatch', () {
        expect(
          () => Tunings.bass.standard.applyTo(Instruments.guitar),
          throwsArgumentError,
        );
      });
    });

    group('toString', () {
      test('shows name and notes', () {
        expect(
          Tunings.guitar.standard.toString(),
          equals('Standard (E2 A2 D3 G3 B3 E4)'),
        );
      });
    });

    group('equality', () {
      test('equal tunings are equal', () {
        final a = Tuning.parse('Test', 'E2 A2 D3 G3 B3 E4');
        final b = Tuning.parse('Test', 'E2 A2 D3 G3 B3 E4');
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different names are not equal', () {
        final a = Tuning.parse('A', 'E2 A2 D3 G3 B3 E4');
        final b = Tuning.parse('B', 'E2 A2 D3 G3 B3 E4');
        expect(a, isNot(equals(b)));
      });

      test('different notes are not equal', () {
        final a = Tuning.parse('Test', 'E2 A2 D3 G3 B3 E4');
        final b = Tuning.parse('Test', 'D2 A2 D3 G3 B3 E4');
        expect(a, isNot(equals(b)));
      });
    });
  }, tags: ['unit']);

  group('Tunings presets', () {
    group('guitar', () {
      test('standard has correct notes', () {
        expect(Tunings.guitar.standard.stringCount, equals(6));
        expect(
            Tunings.guitar.standard.strings[0].openNote, equals(PitchClass.e));
        expect(
            Tunings.guitar.standard.strings[5].openNote, equals(PitchClass.e));
      });

      test('dropD has low D', () {
        expect(Tunings.guitar.dropD.strings[0].openNote, equals(PitchClass.d));
        expect(Tunings.guitar.dropD.strings[0].octave, equals(2));
      });

      test('dropC has low C', () {
        expect(Tunings.guitar.dropC.strings[0].openNote, equals(PitchClass.c));
      });

      test('openG has correct notes', () {
        final notes =
            Tunings.guitar.openG.strings.map((s) => s.openNote).toList();
        expect(
            notes,
            equals([
              PitchClass.d,
              PitchClass.g,
              PitchClass.d,
              PitchClass.g,
              PitchClass.b,
              PitchClass.d,
            ]));
      });

      test('openD has correct notes', () {
        final notes =
            Tunings.guitar.openD.strings.map((s) => s.openNote).toList();
        expect(
            notes,
            equals([
              PitchClass.d,
              PitchClass.a,
              PitchClass.d,
              PitchClass.fSharp,
              PitchClass.a,
              PitchClass.d,
            ]));
      });

      test('dadgad has correct notes', () {
        final notes =
            Tunings.guitar.dadgad.strings.map((s) => s.openNote).toList();
        expect(
            notes,
            equals([
              PitchClass.d,
              PitchClass.a,
              PitchClass.d,
              PitchClass.g,
              PitchClass.a,
              PitchClass.d,
            ]));
      });

      test('halfStepDown is all flats', () {
        final notes =
            Tunings.guitar.halfStepDown.strings.map((s) => s.openNote).toList();
        expect(
            notes,
            equals([
              PitchClass.dSharp,
              PitchClass.gSharp,
              PitchClass.cSharp,
              PitchClass.fSharp,
              PitchClass.aSharp,
              PitchClass.dSharp,
            ]));
      });

      test('all contains all 6-string tunings', () {
        expect(Tunings.guitar.all.length, equals(13));
        for (final tuning in Tunings.guitar.all) {
          expect(tuning.stringCount, equals(6));
        }
      });
    });

    group('bass', () {
      test('standard has 4 strings', () {
        expect(Tunings.bass.standard.stringCount, equals(4));
      });

      test('standard has 20 frets', () {
        for (final string in Tunings.bass.standard.strings) {
          expect(string.fretCount, equals(20));
        }
      });

      test('dropD has low D', () {
        expect(Tunings.bass.dropD.strings[0].openNote, equals(PitchClass.d));
      });

      test('all contains all bass tunings', () {
        expect(Tunings.bass.all.length, equals(3));
        for (final tuning in Tunings.bass.all) {
          expect(tuning.stringCount, equals(4));
        }
      });
    });

    group('ukulele', () {
      test('standard is reentrant G C E A', () {
        final notes =
            Tunings.ukulele.standard.strings.map((s) => s.openNote).toList();
        expect(
            notes,
            equals([
              PitchClass.g,
              PitchClass.c,
              PitchClass.e,
              PitchClass.a,
            ]));
        // Reentrant: G is high (octave 4)
        expect(Tunings.ukulele.standard.strings[0].octave, equals(4));
      });

      test('lowG has low G', () {
        expect(Tunings.ukulele.lowG.strings[0].octave, equals(3));
      });

      test('baritone like guitar top 4', () {
        final notes =
            Tunings.ukulele.baritone.strings.map((s) => s.openNote).toList();
        expect(
            notes,
            equals([
              PitchClass.d,
              PitchClass.g,
              PitchClass.b,
              PitchClass.e,
            ]));
      });

      test('all contains all ukulele tunings', () {
        expect(Tunings.ukulele.all.length, equals(4));
        for (final tuning in Tunings.ukulele.all) {
          expect(tuning.stringCount, equals(4));
        }
      });
    });

    group('cavaquinho', () {
      test('standard is D G B D', () {
        final notes =
            Tunings.cavaquinho.standard.strings.map((s) => s.openNote).toList();
        expect(
            notes,
            equals([
              PitchClass.d,
              PitchClass.g,
              PitchClass.b,
              PitchClass.d,
            ]));
      });

      test('has 17 frets', () {
        for (final string in Tunings.cavaquinho.standard.strings) {
          expect(string.fretCount, equals(17));
        }
      });

      test('all contains all cavaquinho tunings', () {
        expect(Tunings.cavaquinho.all.length, equals(2));
      });
    });

    group('banjo', () {
      test('openG is G D G B D', () {
        final notes =
            Tunings.banjo.openG.strings.map((s) => s.openNote).toList();
        expect(
            notes,
            equals([
              PitchClass.g,
              PitchClass.d,
              PitchClass.g,
              PitchClass.b,
              PitchClass.d,
            ]));
      });

      test('all contains all banjo tunings', () {
        expect(Tunings.banjo.all.length, equals(3));
        for (final tuning in Tunings.banjo.all) {
          expect(tuning.stringCount, equals(5));
        }
      });
    });

    group('guitar7String', () {
      test('standard has low B', () {
        expect(Tunings.guitar7String.standard.stringCount, equals(7));
        expect(Tunings.guitar7String.standard.strings[0].openNote,
            equals(PitchClass.b));
        expect(Tunings.guitar7String.standard.strings[0].octave, equals(1));
      });

      test('dropA has low A', () {
        expect(Tunings.guitar7String.dropA.strings[0].openNote,
            equals(PitchClass.a));
        expect(Tunings.guitar7String.dropA.strings[0].octave, equals(1));
      });

      test('all contains all 7-string tunings', () {
        expect(Tunings.guitar7String.all.length, equals(2));
        for (final tuning in Tunings.guitar7String.all) {
          expect(tuning.stringCount, equals(7));
        }
      });
    });
  }, tags: ['unit']);

  group('Instruments presets', () {
    test('guitar has 6 strings in standard tuning', () {
      expect(Instruments.guitar.name, equals('Guitar'));
      expect(Instruments.guitar.stringCount, equals(6));
      expect(Instruments.guitar.strings[0].openNote, equals(PitchClass.e));
      expect(Instruments.guitar.strings[5].openNote, equals(PitchClass.e));
    });

    test('bass has 4 strings with 20 frets', () {
      expect(Instruments.bass.stringCount, equals(4));
      for (final string in Instruments.bass.strings) {
        expect(string.fretCount, equals(20));
      }
    });

    test('ukulele has 4 strings with 15 frets', () {
      expect(Instruments.ukulele.stringCount, equals(4));
      for (final string in Instruments.ukulele.strings) {
        expect(string.fretCount, equals(15));
      }
    });

    test('cavaquinho has 4 strings with 17 frets', () {
      expect(Instruments.cavaquinho.stringCount, equals(4));
      for (final string in Instruments.cavaquinho.strings) {
        expect(string.fretCount, equals(17));
      }
    });

    test('banjo has 5 strings', () {
      expect(Instruments.banjo.stringCount, equals(5));
    });

    test('guitar7String has 7 strings', () {
      expect(Instruments.guitar7String.stringCount, equals(7));
    });

    test('all contains all instruments', () {
      expect(Instruments.all.length, equals(6));
    });
  }, tags: ['unit']);
}
