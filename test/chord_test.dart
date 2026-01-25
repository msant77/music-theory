import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('ChordType', () {
    group('triads', () {
      test('major has correct intervals', () {
        expect(ChordType.major.intervals.length, equals(3));
        expect(ChordType.major.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.major.intervals[1].semitones, equals(4)); // M3
        expect(ChordType.major.intervals[2].semitones, equals(7)); // P5
      });

      test('minor has correct intervals', () {
        expect(ChordType.minor.intervals.length, equals(3));
        expect(ChordType.minor.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.minor.intervals[1].semitones, equals(3)); // m3
        expect(ChordType.minor.intervals[2].semitones, equals(7)); // P5
      });

      test('diminished has correct intervals', () {
        expect(ChordType.diminished.intervals.length, equals(3));
        expect(ChordType.diminished.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.diminished.intervals[1].semitones, equals(3)); // m3
        expect(ChordType.diminished.intervals[2].semitones, equals(6)); // d5
      });

      test('augmented has correct intervals', () {
        expect(ChordType.augmented.intervals.length, equals(3));
        expect(ChordType.augmented.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.augmented.intervals[1].semitones, equals(4)); // M3
        expect(ChordType.augmented.intervals[2].semitones, equals(8)); // A5
      });

      test('sus2 has correct intervals', () {
        expect(ChordType.sus2.intervals.length, equals(3));
        expect(ChordType.sus2.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.sus2.intervals[1].semitones, equals(2)); // M2
        expect(ChordType.sus2.intervals[2].semitones, equals(7)); // P5
      });

      test('sus4 has correct intervals', () {
        expect(ChordType.sus4.intervals.length, equals(3));
        expect(ChordType.sus4.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.sus4.intervals[1].semitones, equals(5)); // P4
        expect(ChordType.sus4.intervals[2].semitones, equals(7)); // P5
      });
    });

    group('seventh chords', () {
      test('dominant7 has correct intervals', () {
        expect(ChordType.dominant7.intervals.length, equals(4));
        expect(ChordType.dominant7.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.dominant7.intervals[1].semitones, equals(4)); // M3
        expect(ChordType.dominant7.intervals[2].semitones, equals(7)); // P5
        expect(ChordType.dominant7.intervals[3].semitones, equals(10)); // m7
      });

      test('major7 has correct intervals', () {
        expect(ChordType.major7.intervals.length, equals(4));
        expect(ChordType.major7.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.major7.intervals[1].semitones, equals(4)); // M3
        expect(ChordType.major7.intervals[2].semitones, equals(7)); // P5
        expect(ChordType.major7.intervals[3].semitones, equals(11)); // M7
      });

      test('minor7 has correct intervals', () {
        expect(ChordType.minor7.intervals.length, equals(4));
        expect(ChordType.minor7.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.minor7.intervals[1].semitones, equals(3)); // m3
        expect(ChordType.minor7.intervals[2].semitones, equals(7)); // P5
        expect(ChordType.minor7.intervals[3].semitones, equals(10)); // m7
      });

      test('diminished7 has correct intervals', () {
        expect(ChordType.diminished7.intervals.length, equals(4));
        expect(ChordType.diminished7.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.diminished7.intervals[1].semitones, equals(3)); // m3
        expect(ChordType.diminished7.intervals[2].semitones, equals(6)); // d5
        expect(ChordType.diminished7.intervals[3].semitones, equals(9)); // d7
      });

      test('halfDiminished7 has correct intervals', () {
        expect(ChordType.halfDiminished7.intervals.length, equals(4));
        expect(ChordType.halfDiminished7.intervals[0].semitones,
            equals(0)); // Root
        expect(
            ChordType.halfDiminished7.intervals[1].semitones, equals(3)); // m3
        expect(
            ChordType.halfDiminished7.intervals[2].semitones, equals(6)); // d5
        expect(
            ChordType.halfDiminished7.intervals[3].semitones, equals(10)); // m7
      });
    });

    group('properties', () {
      test('isTriad returns true for triads', () {
        expect(ChordType.major.isTriad, isTrue);
        expect(ChordType.minor.isTriad, isTrue);
        expect(ChordType.diminished.isTriad, isTrue);
        expect(ChordType.augmented.isTriad, isTrue);
        expect(ChordType.sus2.isTriad, isTrue);
        expect(ChordType.sus4.isTriad, isTrue);
      });

      test('isTriad returns false for seventh chords', () {
        expect(ChordType.dominant7.isTriad, isFalse);
        expect(ChordType.major7.isTriad, isFalse);
        expect(ChordType.minor7.isTriad, isFalse);
      });

      test('isSeventh returns true for seventh chords', () {
        expect(ChordType.dominant7.isSeventh, isTrue);
        expect(ChordType.major7.isSeventh, isTrue);
        expect(ChordType.minor7.isSeventh, isTrue);
        expect(ChordType.diminished7.isSeventh, isTrue);
      });

      test('isSeventh returns false for triads', () {
        expect(ChordType.major.isSeventh, isFalse);
        expect(ChordType.minor.isSeventh, isFalse);
      });

      test('isExtended returns true for extended chords', () {
        expect(ChordType.dominant9.isExtended, isTrue);
        expect(ChordType.major9.isExtended, isTrue);
        expect(ChordType.add9.isExtended, isTrue);
      });

      test('isExtended returns false for basic chords', () {
        expect(ChordType.major.isExtended, isFalse);
        expect(ChordType.dominant7.isExtended, isFalse);
      });

      test('noteCount returns correct count', () {
        expect(ChordType.major.noteCount, equals(3));
        expect(ChordType.dominant7.noteCount, equals(4));
        expect(ChordType.dominant9.noteCount, equals(5));
        expect(ChordType.power.noteCount, equals(2));
      });
    });

    group('symbols', () {
      test('has correct symbols', () {
        expect(ChordType.major.symbol, equals(''));
        expect(ChordType.minor.symbol, equals('m'));
        expect(ChordType.diminished.symbol, equals('dim'));
        expect(ChordType.augmented.symbol, equals('aug'));
        expect(ChordType.sus2.symbol, equals('sus2'));
        expect(ChordType.sus4.symbol, equals('sus4'));
        expect(ChordType.dominant7.symbol, equals('7'));
        expect(ChordType.major7.symbol, equals('maj7'));
        expect(ChordType.minor7.symbol, equals('m7'));
        expect(ChordType.halfDiminished7.symbol, equals('m7b5'));
        expect(ChordType.power.symbol, equals('5'));
      });
    });

    test('all contains all chord types', () {
      expect(ChordType.all.length, equals(27));
      expect(ChordType.all, contains(ChordType.major));
      expect(ChordType.all, contains(ChordType.minor));
      expect(ChordType.all, contains(ChordType.dominant7));
      expect(ChordType.all, contains(ChordType.dominant7b9));
      expect(ChordType.all, contains(ChordType.dominant13));
    });

    group('altered dominants', () {
      test('dominant7b9 has correct intervals', () {
        expect(ChordType.dominant7b9.intervals.length, equals(5));
        expect(ChordType.dominant7b9.intervals[0].semitones, equals(0)); // Root
        expect(ChordType.dominant7b9.intervals[1].semitones, equals(4)); // M3
        expect(ChordType.dominant7b9.intervals[2].semitones, equals(7)); // P5
        expect(ChordType.dominant7b9.intervals[3].semitones, equals(10)); // m7
        expect(ChordType.dominant7b9.intervals[4].semitones, equals(13)); // m9
      });

      test('dominant7sharp9 has correct intervals', () {
        expect(ChordType.dominant7sharp9.intervals.length, equals(5));
        expect(ChordType.dominant7sharp9.intervals[4].semitones, equals(15)); // A9
      });

      test('dominant7b13 has correct intervals', () {
        expect(ChordType.dominant7b13.intervals.length, equals(5));
        expect(ChordType.dominant7b13.intervals[4].semitones, equals(20)); // m13
      });

      test('dominant7sharp11 has correct intervals', () {
        expect(ChordType.dominant7sharp11.intervals.length, equals(5));
        expect(ChordType.dominant7sharp11.intervals[4].semitones, equals(18)); // A11
      });

      test('dominant11 has correct intervals', () {
        expect(ChordType.dominant11.intervals.length, equals(6));
        expect(ChordType.dominant11.intervals[4].semitones, equals(14)); // M9
        expect(ChordType.dominant11.intervals[5].semitones, equals(17)); // P11
      });

      test('dominant13 has correct intervals', () {
        expect(ChordType.dominant13.intervals.length, equals(6));
        expect(ChordType.dominant13.intervals[4].semitones, equals(14)); // M9
        expect(ChordType.dominant13.intervals[5].semitones, equals(21)); // M13
      });
    });
  });

  group('Chord', () {
    group('constructor', () {
      test('creates chord with root and type', () {
        const chord = Chord(PitchClass.c, ChordType.major);
        expect(chord.root, equals(PitchClass.c));
        expect(chord.type, equals(ChordType.major));
      });
    });

    group('parse', () {
      group('major chords', () {
        test('parses C', () {
          final chord = Chord.parse('C');
          expect(chord.root, equals(PitchClass.c));
          expect(chord.type, equals(ChordType.major));
        });

        test('parses Cmaj', () {
          expect(Chord.parse('Cmaj').type, equals(ChordType.major));
        });

        test('parses sharps', () {
          final chord = Chord.parse('C#');
          expect(chord.root, equals(PitchClass.cSharp));
          expect(chord.type, equals(ChordType.major));
        });

        test('parses flats', () {
          final chord = Chord.parse('Bb');
          expect(chord.root, equals(PitchClass.aSharp));
          expect(chord.type, equals(ChordType.major));
        });
      });

      group('minor chords', () {
        test('parses Am', () {
          final chord = Chord.parse('Am');
          expect(chord.root, equals(PitchClass.a));
          expect(chord.type, equals(ChordType.minor));
        });

        test('parses Amin', () {
          expect(Chord.parse('Amin').type, equals(ChordType.minor));
        });

        test('parses A-', () {
          expect(Chord.parse('A-').type, equals(ChordType.minor));
        });

        test('parses F#m', () {
          final chord = Chord.parse('F#m');
          expect(chord.root, equals(PitchClass.fSharp));
          expect(chord.type, equals(ChordType.minor));
        });
      });

      group('seventh chords', () {
        test('parses G7', () {
          final chord = Chord.parse('G7');
          expect(chord.root, equals(PitchClass.g));
          expect(chord.type, equals(ChordType.dominant7));
        });

        test('parses Cmaj7', () {
          final chord = Chord.parse('Cmaj7');
          expect(chord.root, equals(PitchClass.c));
          expect(chord.type, equals(ChordType.major7));
        });

        test('parses CM7', () {
          expect(Chord.parse('CM7').type, equals(ChordType.major7));
        });

        test('parses Am7', () {
          final chord = Chord.parse('Am7');
          expect(chord.root, equals(PitchClass.a));
          expect(chord.type, equals(ChordType.minor7));
        });

        test('parses Bdim7', () {
          final chord = Chord.parse('Bdim7');
          expect(chord.root, equals(PitchClass.b));
          expect(chord.type, equals(ChordType.diminished7));
        });

        test('parses Bm7b5', () {
          final chord = Chord.parse('Bm7b5');
          expect(chord.root, equals(PitchClass.b));
          expect(chord.type, equals(ChordType.halfDiminished7));
        });
      });

      group('other chords', () {
        test('parses Cdim', () {
          expect(Chord.parse('Cdim').type, equals(ChordType.diminished));
        });

        test('parses C°', () {
          expect(Chord.parse('C°').type, equals(ChordType.diminished));
        });

        test('parses Caug', () {
          expect(Chord.parse('Caug').type, equals(ChordType.augmented));
        });

        test('parses C+', () {
          expect(Chord.parse('C+').type, equals(ChordType.augmented));
        });

        test('parses Csus2', () {
          expect(Chord.parse('Csus2').type, equals(ChordType.sus2));
        });

        test('parses Csus4', () {
          expect(Chord.parse('Csus4').type, equals(ChordType.sus4));
        });

        test('parses Csus (defaults to sus4)', () {
          expect(Chord.parse('Csus').type, equals(ChordType.sus4));
        });

        test('parses C5 (power chord)', () {
          expect(Chord.parse('C5').type, equals(ChordType.power));
        });

        test('parses C6', () {
          expect(Chord.parse('C6').type, equals(ChordType.major6));
        });

        test('parses Cm6', () {
          expect(Chord.parse('Cm6').type, equals(ChordType.minor6));
        });

        test('parses Cadd9', () {
          expect(Chord.parse('Cadd9').type, equals(ChordType.add9));
        });

        test('parses C9', () {
          expect(Chord.parse('C9').type, equals(ChordType.dominant9));
        });
      });

      group('altered dominant chords', () {
        test('parses B7b9', () {
          final chord = Chord.parse('B7b9');
          expect(chord.root, equals(PitchClass.b));
          expect(chord.type, equals(ChordType.dominant7b9));
        });

        test('parses B7(b9) with parentheses', () {
          final chord = Chord.parse('B7(b9)');
          expect(chord.root, equals(PitchClass.b));
          expect(chord.type, equals(ChordType.dominant7b9));
        });

        test('parses E7#9', () {
          final chord = Chord.parse('E7#9');
          expect(chord.root, equals(PitchClass.e));
          expect(chord.type, equals(ChordType.dominant7sharp9));
        });

        test('parses E7(#9) with parentheses', () {
          final chord = Chord.parse('E7(#9)');
          expect(chord.type, equals(ChordType.dominant7sharp9));
        });

        test('parses A7b13', () {
          final chord = Chord.parse('A7b13');
          expect(chord.root, equals(PitchClass.a));
          expect(chord.type, equals(ChordType.dominant7b13));
        });

        test('parses A7(b13) with parentheses', () {
          final chord = Chord.parse('A7(b13)');
          expect(chord.type, equals(ChordType.dominant7b13));
        });

        test('parses D7#11', () {
          final chord = Chord.parse('D7#11');
          expect(chord.root, equals(PitchClass.d));
          expect(chord.type, equals(ChordType.dominant7sharp11));
        });

        test('parses G11', () {
          final chord = Chord.parse('G11');
          expect(chord.root, equals(PitchClass.g));
          expect(chord.type, equals(ChordType.dominant11));
        });

        test('parses C13', () {
          final chord = Chord.parse('C13');
          expect(chord.root, equals(PitchClass.c));
          expect(chord.type, equals(ChordType.dominant13));
        });
      });

      group('error handling', () {
        test('throws on empty string', () {
          expect(() => Chord.parse(''), throwsFormatException);
        });

        test('throws on invalid root', () {
          expect(() => Chord.parse('X'), throwsFormatException);
        });

        test('throws on unknown chord type', () {
          expect(() => Chord.parse('Cxyz'), throwsFormatException);
        });
      });

      test('is case insensitive for root', () {
        expect(Chord.parse('c').root, equals(PitchClass.c));
        expect(Chord.parse('C').root, equals(PitchClass.c));
      });

      test('trims whitespace', () {
        expect(Chord.parse('  Am  ').root, equals(PitchClass.a));
      });
    });

    group('tryParse', () {
      test('returns chord on valid input', () {
        expect(Chord.tryParse('Am'), isNotNull);
      });

      test('returns null on invalid input', () {
        expect(Chord.tryParse(''), isNull);
        expect(Chord.tryParse('Xyz'), isNull);
      });
    });

    group('pitchClasses', () {
      test('C major has C, E, G', () {
        final chord = Chord.parse('C');
        expect(chord.pitchClasses,
            equals([PitchClass.c, PitchClass.e, PitchClass.g]));
      });

      test('A minor has A, C, E', () {
        final chord = Chord.parse('Am');
        expect(chord.pitchClasses,
            equals([PitchClass.a, PitchClass.c, PitchClass.e]));
      });

      test('G7 has G, B, D, F', () {
        final chord = Chord.parse('G7');
        expect(
          chord.pitchClasses,
          equals([PitchClass.g, PitchClass.b, PitchClass.d, PitchClass.f]),
        );
      });

      test('F#m has F#, A, C#', () {
        final chord = Chord.parse('F#m');
        expect(
          chord.pitchClasses,
          equals([PitchClass.fSharp, PitchClass.a, PitchClass.cSharp]),
        );
      });
    });

    group('notesFromOctave', () {
      test('C major from octave 4', () {
        final chord = Chord.parse('C');
        final notes = chord.notesFromOctave(4);
        expect(notes.length, equals(3));
        expect(notes[0], equals(Note.parse('C4')));
        expect(notes[1], equals(Note.parse('E4')));
        expect(notes[2], equals(Note.parse('G4')));
      });

      test('Am from octave 3', () {
        final chord = Chord.parse('Am');
        final notes = chord.notesFromOctave(3);
        expect(notes[0], equals(Note.parse('A3')));
        expect(notes[1], equals(Note.parse('C4'))); // Crosses octave
        expect(notes[2], equals(Note.parse('E4')));
      });
    });

    group('symbol', () {
      test('returns chord symbol', () {
        expect(Chord.parse('C').symbol, equals('C'));
        expect(Chord.parse('Am').symbol, equals('Am'));
        expect(Chord.parse('G7').symbol, equals('G7'));
        expect(Chord.parse('Cmaj7').symbol, equals('Cmaj7'));
        expect(Chord.parse('F#m').symbol, equals('F#m'));
        expect(Chord.parse('Bb').symbol, equals('A#')); // Normalized to sharp
      });
    });

    group('name', () {
      test('returns full chord name', () {
        expect(Chord.parse('C').name, equals('C major'));
        expect(Chord.parse('Am').name, equals('A minor'));
        expect(Chord.parse('G7').name, equals('G dominant 7th'));
        expect(Chord.parse('Cmaj7').name, equals('C major 7th'));
      });
    });

    group('transpose', () {
      test('transposes chord up', () {
        final c = Chord.parse('C');
        final d = c.transpose(2);
        expect(d.root, equals(PitchClass.d));
        expect(d.type, equals(ChordType.major));
      });

      test('transposes chord down', () {
        final am = Chord.parse('Am');
        final gm = am.transpose(-2);
        expect(gm.root, equals(PitchClass.g));
        expect(gm.type, equals(ChordType.minor));
      });

      test('preserves chord type', () {
        final cmaj7 = Chord.parse('Cmaj7');
        final dmaj7 = cmaj7.transpose(2);
        expect(dmaj7.type, equals(ChordType.major7));
      });
    });

    group('equality', () {
      test('equal chords are equal', () {
        final c1 = Chord.parse('Am');
        final c2 = Chord.parse('Am');
        expect(c1, equals(c2));
        expect(c1.hashCode, equals(c2.hashCode));
      });

      test('different roots are not equal', () {
        expect(Chord.parse('Am'), isNot(equals(Chord.parse('Bm'))));
      });

      test('different types are not equal', () {
        expect(Chord.parse('A'), isNot(equals(Chord.parse('Am'))));
      });
    });

    group('toString', () {
      test('returns symbol', () {
        expect(Chord.parse('Am').toString(), equals('Am'));
        expect(Chord.parse('G7').toString(), equals('G7'));
      });
    });
  });

  group('PitchClassChordExtension', () {
    test('majorChord creates major chord', () {
      final chord = PitchClass.c.majorChord;
      expect(chord.root, equals(PitchClass.c));
      expect(chord.type, equals(ChordType.major));
    });

    test('minorChord creates minor chord', () {
      final chord = PitchClass.a.minorChord;
      expect(chord.root, equals(PitchClass.a));
      expect(chord.type, equals(ChordType.minor));
    });

    test('chord creates chord with specified type', () {
      final chord = PitchClass.g.chord(ChordType.dominant7);
      expect(chord.root, equals(PitchClass.g));
      expect(chord.type, equals(ChordType.dominant7));
    });
  });
}
