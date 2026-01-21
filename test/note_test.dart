import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('Note', () {
    group('constructor', () {
      test('creates note with pitch class and octave', () {
        final note = Note(PitchClass.c, 4);
        expect(note.pitchClass, equals(PitchClass.c));
        expect(note.octave, equals(4));
      });

      test('allows negative octaves', () {
        final note = Note(PitchClass.c, -1);
        expect(note.octave, equals(-1));
      });

      test('allows high octaves', () {
        final note = Note(PitchClass.g, 9);
        expect(note.octave, equals(9));
      });
    });

    group('constants', () {
      test('middleC is C4', () {
        expect(Note.middleC.pitchClass, equals(PitchClass.c));
        expect(Note.middleC.octave, equals(4));
        expect(Note.middleC.midiNumber, equals(60));
      });

      test('a440 is A4', () {
        expect(Note.a440.pitchClass, equals(PitchClass.a));
        expect(Note.a440.octave, equals(4));
        expect(Note.a440.midiNumber, equals(69));
      });
    });

    group('midiNumber', () {
      test('C4 is MIDI 60', () {
        expect(Note(PitchClass.c, 4).midiNumber, equals(60));
      });

      test('A4 is MIDI 69', () {
        expect(Note(PitchClass.a, 4).midiNumber, equals(69));
      });

      test('C-1 is MIDI 0', () {
        expect(Note(PitchClass.c, -1).midiNumber, equals(0));
      });

      test('G9 is MIDI 127', () {
        expect(Note(PitchClass.g, 9).midiNumber, equals(127));
      });

      test('C5 is MIDI 72', () {
        expect(Note(PitchClass.c, 5).midiNumber, equals(72));
      });

      test('B3 is MIDI 59', () {
        expect(Note(PitchClass.b, 3).midiNumber, equals(59));
      });

      test('E2 (guitar low E) is MIDI 40', () {
        expect(Note(PitchClass.e, 2).midiNumber, equals(40));
      });
    });

    group('fromMidi', () {
      test('MIDI 60 is C4', () {
        final note = Note.fromMidi(60);
        expect(note.pitchClass, equals(PitchClass.c));
        expect(note.octave, equals(4));
      });

      test('MIDI 69 is A4', () {
        final note = Note.fromMidi(69);
        expect(note.pitchClass, equals(PitchClass.a));
        expect(note.octave, equals(4));
      });

      test('MIDI 0 is C-1', () {
        final note = Note.fromMidi(0);
        expect(note.pitchClass, equals(PitchClass.c));
        expect(note.octave, equals(-1));
      });

      test('MIDI 127 is G9', () {
        final note = Note.fromMidi(127);
        expect(note.pitchClass, equals(PitchClass.g));
        expect(note.octave, equals(9));
      });

      test('throws on negative MIDI number', () {
        expect(() => Note.fromMidi(-1), throwsRangeError);
      });

      test('throws on MIDI number > 127', () {
        expect(() => Note.fromMidi(128), throwsRangeError);
      });

      test('round-trips through MIDI', () {
        for (var midi = 0; midi <= 127; midi++) {
          final note = Note.fromMidi(midi);
          expect(note.midiNumber, equals(midi));
        }
      });
    });

    group('parse', () {
      test('parses natural notes', () {
        expect(Note.parse('C4'), equals(Note(PitchClass.c, 4)));
        expect(Note.parse('D5'), equals(Note(PitchClass.d, 5)));
        expect(Note.parse('E2'), equals(Note(PitchClass.e, 2)));
      });

      test('parses sharps', () {
        expect(Note.parse('C#4'), equals(Note(PitchClass.cSharp, 4)));
        expect(Note.parse('F#3'), equals(Note(PitchClass.fSharp, 3)));
        expect(Note.parse('G#5'), equals(Note(PitchClass.gSharp, 5)));
      });

      test('parses flats', () {
        expect(Note.parse('Db4'), equals(Note(PitchClass.cSharp, 4)));
        expect(Note.parse('Bb3'), equals(Note(PitchClass.aSharp, 3)));
        expect(Note.parse('Eb5'), equals(Note(PitchClass.dSharp, 5)));
      });

      test('parses negative octaves', () {
        expect(Note.parse('C-1'), equals(Note(PitchClass.c, -1)));
        expect(Note.parse('G#-1'), equals(Note(PitchClass.gSharp, -1)));
      });

      test('is case insensitive', () {
        expect(Note.parse('c4'), equals(Note(PitchClass.c, 4)));
        expect(Note.parse('C#4'), equals(Note.parse('c#4')));
        expect(Note.parse('DB4'), equals(Note.parse('db4')));
      });

      test('trims whitespace', () {
        expect(Note.parse('  C4  '), equals(Note(PitchClass.c, 4)));
      });

      test('throws on empty string', () {
        expect(() => Note.parse(''), throwsFormatException);
      });

      test('throws on missing octave', () {
        expect(() => Note.parse('C'), throwsFormatException);
        expect(() => Note.parse('C#'), throwsFormatException);
      });

      test('throws on invalid pitch class', () {
        expect(() => Note.parse('H4'), throwsFormatException);
        expect(() => Note.parse('X4'), throwsFormatException);
      });

      test('throws on invalid octave', () {
        expect(() => Note.parse('Cabc'), throwsFormatException);
      });
    });

    group('tryParse', () {
      test('returns note on valid input', () {
        expect(Note.tryParse('C4'), equals(Note(PitchClass.c, 4)));
      });

      test('returns null on invalid input', () {
        expect(Note.tryParse('invalid'), isNull);
        expect(Note.tryParse(''), isNull);
        expect(Note.tryParse('C'), isNull);
      });
    });

    group('transpose', () {
      test('transposes up within octave', () {
        final c4 = Note(PitchClass.c, 4);
        expect(c4.transpose(4), equals(Note(PitchClass.e, 4)));
      });

      test('transposes down within octave', () {
        final e4 = Note(PitchClass.e, 4);
        expect(e4.transpose(-4), equals(Note(PitchClass.c, 4)));
      });

      test('transposes up across octave boundary', () {
        final g4 = Note(PitchClass.g, 4);
        expect(g4.transpose(5), equals(Note(PitchClass.c, 5)));
      });

      test('transposes down across octave boundary', () {
        final c4 = Note(PitchClass.c, 4);
        expect(c4.transpose(-1), equals(Note(PitchClass.b, 3)));
      });

      test('transposes by octave', () {
        final c4 = Note(PitchClass.c, 4);
        expect(c4.transpose(12), equals(Note(PitchClass.c, 5)));
        expect(c4.transpose(-12), equals(Note(PitchClass.c, 3)));
      });

      test('transposes by zero', () {
        final c4 = Note(PitchClass.c, 4);
        expect(c4.transpose(0), equals(c4));
      });

      test('throws on out-of-range result', () {
        final lowC = Note(PitchClass.c, -1);
        expect(() => lowC.transpose(-1), throwsRangeError);

        final highG = Note(PitchClass.g, 9);
        expect(() => highG.transpose(1), throwsRangeError);
      });
    });

    group('semitonesTo', () {
      test('calculates positive interval', () {
        final c4 = Note(PitchClass.c, 4);
        final e4 = Note(PitchClass.e, 4);
        expect(c4.semitonesTo(e4), equals(4));
      });

      test('calculates negative interval', () {
        final e4 = Note(PitchClass.e, 4);
        final c4 = Note(PitchClass.c, 4);
        expect(e4.semitonesTo(c4), equals(-4));
      });

      test('calculates interval across octaves', () {
        final c4 = Note(PitchClass.c, 4);
        final c5 = Note(PitchClass.c, 5);
        expect(c4.semitonesTo(c5), equals(12));
      });

      test('returns zero for same note', () {
        final c4 = Note(PitchClass.c, 4);
        expect(c4.semitonesTo(c4), equals(0));
      });
    });

    group('frequency', () {
      test('A4 is 440 Hz', () {
        expect(Note.a440.frequency, closeTo(440.0, 0.001));
      });

      test('A5 is 880 Hz (one octave up)', () {
        final a5 = Note(PitchClass.a, 5);
        expect(a5.frequency, closeTo(880.0, 0.001));
      });

      test('A3 is 220 Hz (one octave down)', () {
        final a3 = Note(PitchClass.a, 3);
        expect(a3.frequency, closeTo(220.0, 0.001));
      });

      test('C4 (middle C) is approximately 261.63 Hz', () {
        expect(Note.middleC.frequency, closeTo(261.63, 0.01));
      });
    });

    group('comparison operators', () {
      test('lower note is less than higher note', () {
        final c4 = Note(PitchClass.c, 4);
        final d4 = Note(PitchClass.d, 4);
        expect(c4 < d4, isTrue);
        expect(d4 < c4, isFalse);
      });

      test('compares across octaves', () {
        final b3 = Note(PitchClass.b, 3);
        final c4 = Note(PitchClass.c, 4);
        expect(b3 < c4, isTrue);
      });

      test('equal notes are not less than', () {
        final c4a = Note(PitchClass.c, 4);
        final c4b = Note(PitchClass.c, 4);
        expect(c4a < c4b, isFalse);
        expect(c4a <= c4b, isTrue);
      });

      test('greater than operator', () {
        final d4 = Note(PitchClass.d, 4);
        final c4 = Note(PitchClass.c, 4);
        expect(d4 > c4, isTrue);
        expect(c4 > d4, isFalse);
      });

      test('greater than or equal operator', () {
        final c4a = Note(PitchClass.c, 4);
        final c4b = Note(PitchClass.c, 4);
        expect(c4a >= c4b, isTrue);
      });

      test('compareTo returns correct ordering', () {
        final c4 = Note(PitchClass.c, 4);
        final d4 = Note(PitchClass.d, 4);
        final c4b = Note(PitchClass.c, 4);

        expect(c4.compareTo(d4), lessThan(0));
        expect(d4.compareTo(c4), greaterThan(0));
        expect(c4.compareTo(c4b), equals(0));
      });
    });

    group('arithmetic operators', () {
      test('+ adds semitones', () {
        final c4 = Note(PitchClass.c, 4);
        expect(c4 + 4, equals(Note(PitchClass.e, 4)));
      });

      test('- subtracts semitones', () {
        final e4 = Note(PitchClass.e, 4);
        expect(e4 - 4, equals(Note(PitchClass.c, 4)));
      });
    });

    group('equality', () {
      test('equal notes are equal', () {
        final c4a = Note(PitchClass.c, 4);
        final c4b = Note(PitchClass.c, 4);
        expect(c4a, equals(c4b));
        expect(c4a.hashCode, equals(c4b.hashCode));
      });

      test('different pitch classes are not equal', () {
        final c4 = Note(PitchClass.c, 4);
        final d4 = Note(PitchClass.d, 4);
        expect(c4, isNot(equals(d4)));
      });

      test('different octaves are not equal', () {
        final c4 = Note(PitchClass.c, 4);
        final c5 = Note(PitchClass.c, 5);
        expect(c4, isNot(equals(c5)));
      });

      test('enharmonic equivalents with same MIDI are equal', () {
        // C# and Db are the same PitchClass internally (cSharp)
        final cSharp4 = Note.parse('C#4');
        final db4 = Note.parse('Db4');
        expect(cSharp4, equals(db4));
      });
    });

    group('name', () {
      test('returns pitch class and octave', () {
        expect(Note(PitchClass.c, 4).name, equals('C4'));
        expect(Note(PitchClass.cSharp, 4).name, equals('C#4'));
        expect(Note(PitchClass.b, 3).name, equals('B3'));
      });

      test('handles negative octaves', () {
        expect(Note(PitchClass.c, -1).name, equals('C-1'));
      });
    });

    group('toString', () {
      test('returns name', () {
        final note = Note(PitchClass.c, 4);
        expect(note.toString(), equals('C4'));
      });
    });

    group('guitar standard tuning notes', () {
      test('low E is E2 (MIDI 40)', () {
        final lowE = Note.parse('E2');
        expect(lowE.midiNumber, equals(40));
      });

      test('A string is A2 (MIDI 45)', () {
        final a = Note.parse('A2');
        expect(a.midiNumber, equals(45));
      });

      test('D string is D3 (MIDI 50)', () {
        final d = Note.parse('D3');
        expect(d.midiNumber, equals(50));
      });

      test('G string is G3 (MIDI 55)', () {
        final g = Note.parse('G3');
        expect(g.midiNumber, equals(55));
      });

      test('B string is B3 (MIDI 59)', () {
        final b = Note.parse('B3');
        expect(b.midiNumber, equals(59));
      });

      test('high E is E4 (MIDI 64)', () {
        final highE = Note.parse('E4');
        expect(highE.midiNumber, equals(64));
      });
    });
  }, tags: ['unit']);
}
