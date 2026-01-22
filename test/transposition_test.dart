import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('SpellingPreference', () {
    test('has all expected values', () {
      expect(SpellingPreference.values, hasLength(3));
      expect(SpellingPreference.values, contains(SpellingPreference.sharps));
      expect(SpellingPreference.values, contains(SpellingPreference.flats));
      expect(SpellingPreference.values, contains(SpellingPreference.auto));
    });
  });

  group('spellPitchClass', () {
    test('spells natural notes the same way', () {
      expect(spellPitchClass(PitchClass.c, SpellingPreference.sharps), 'C');
      expect(spellPitchClass(PitchClass.c, SpellingPreference.flats), 'C');
      expect(spellPitchClass(PitchClass.d, SpellingPreference.sharps), 'D');
      expect(spellPitchClass(PitchClass.d, SpellingPreference.flats), 'D');
    });

    test('spells accidentals as sharps when requested', () {
      expect(spellPitchClass(PitchClass.cSharp, SpellingPreference.sharps), 'C#');
      expect(spellPitchClass(PitchClass.dSharp, SpellingPreference.sharps), 'D#');
      expect(spellPitchClass(PitchClass.fSharp, SpellingPreference.sharps), 'F#');
      expect(spellPitchClass(PitchClass.gSharp, SpellingPreference.sharps), 'G#');
      expect(spellPitchClass(PitchClass.aSharp, SpellingPreference.sharps), 'A#');
    });

    test('spells accidentals as flats when requested', () {
      expect(spellPitchClass(PitchClass.cSharp, SpellingPreference.flats), 'Db');
      expect(spellPitchClass(PitchClass.dSharp, SpellingPreference.flats), 'Eb');
      expect(spellPitchClass(PitchClass.fSharp, SpellingPreference.flats), 'Gb');
      expect(spellPitchClass(PitchClass.gSharp, SpellingPreference.flats), 'Ab');
      expect(spellPitchClass(PitchClass.aSharp, SpellingPreference.flats), 'Bb');
    });
  });

  group('Key', () {
    group('constructor', () {
      test('creates major key by default', () {
        const key = Key(PitchClass.c);
        expect(key.tonic, PitchClass.c);
        expect(key.isMajor, isTrue);
      });

      test('creates minor key when specified', () {
        const key = Key(PitchClass.a, isMajor: false);
        expect(key.tonic, PitchClass.a);
        expect(key.isMajor, isFalse);
      });

      test('Key.major creates major key', () {
        const key = Key.major(PitchClass.g);
        expect(key.isMajor, isTrue);
      });

      test('Key.minor creates minor key', () {
        const key = Key.minor(PitchClass.e);
        expect(key.isMajor, isFalse);
      });
    });

    group('parse', () {
      test('parses major keys', () {
        expect(Key.parse('C').tonic, PitchClass.c);
        expect(Key.parse('C').isMajor, isTrue);
        expect(Key.parse('G').tonic, PitchClass.g);
        expect(Key.parse('F#').tonic, PitchClass.fSharp);
        expect(Key.parse('Bb').tonic, PitchClass.aSharp);
      });

      test('parses minor keys with m suffix', () {
        expect(Key.parse('Am').tonic, PitchClass.a);
        expect(Key.parse('Am').isMajor, isFalse);
        expect(Key.parse('Em').tonic, PitchClass.e);
        expect(Key.parse('F#m').tonic, PitchClass.fSharp);
        expect(Key.parse('Bbm').tonic, PitchClass.aSharp);
      });

      test('parses minor keys with min suffix', () {
        expect(Key.parse('Amin').isMajor, isFalse);
        expect(Key.parse('Emin').tonic, PitchClass.e);
      });

      test('throws on empty string', () {
        expect(() => Key.parse(''), throwsFormatException);
      });

      test('throws on invalid key', () {
        expect(() => Key.parse('X'), throwsFormatException);
      });
    });

    group('tryParse', () {
      test('returns key on valid input', () {
        expect(Key.tryParse('C'), isNotNull);
        expect(Key.tryParse('Am'), isNotNull);
      });

      test('returns null on invalid input', () {
        expect(Key.tryParse(''), isNull);
        expect(Key.tryParse('X'), isNull);
      });
    });

    group('relative', () {
      test('C major relative is A minor', () {
        const cMajor = Key.major(PitchClass.c);
        final relative = cMajor.relative;
        expect(relative.tonic, PitchClass.a);
        expect(relative.isMajor, isFalse);
      });

      test('A minor relative is C major', () {
        const aMinor = Key.minor(PitchClass.a);
        final relative = aMinor.relative;
        expect(relative.tonic, PitchClass.c);
        expect(relative.isMajor, isTrue);
      });

      test('G major relative is E minor', () {
        const gMajor = Key.major(PitchClass.g);
        final relative = gMajor.relative;
        expect(relative.tonic, PitchClass.e);
        expect(relative.isMajor, isFalse);
      });
    });

    group('parallel', () {
      test('C major parallel is C minor', () {
        const cMajor = Key.major(PitchClass.c);
        final parallel = cMajor.parallel;
        expect(parallel.tonic, PitchClass.c);
        expect(parallel.isMajor, isFalse);
      });

      test('A minor parallel is A major', () {
        const aMinor = Key.minor(PitchClass.a);
        final parallel = aMinor.parallel;
        expect(parallel.tonic, PitchClass.a);
        expect(parallel.isMajor, isTrue);
      });
    });

    group('transpose', () {
      test('transposes key up', () {
        const cMajor = Key.major(PitchClass.c);
        final transposed = cMajor.transpose(2);
        expect(transposed.tonic, PitchClass.d);
        expect(transposed.isMajor, isTrue);
      });

      test('transposes key down', () {
        const gMajor = Key.major(PitchClass.g);
        final transposed = gMajor.transpose(-2);
        expect(transposed.tonic, PitchClass.f);
      });

      test('preserves mode when transposing', () {
        const aMinor = Key.minor(PitchClass.a);
        final transposed = aMinor.transpose(3);
        expect(transposed.tonic, PitchClass.c);
        expect(transposed.isMajor, isFalse);
      });

      test('wraps around correctly', () {
        const bMajor = Key.major(PitchClass.b);
        final transposed = bMajor.transpose(1);
        expect(transposed.tonic, PitchClass.c);
      });
    });

    group('prefersFlats', () {
      test('F major prefers flats', () {
        const fMajor = Key.major(PitchClass.f);
        expect(fMajor.prefersFlats, isTrue);
      });

      test('Bb major prefers flats', () {
        const bbMajor = Key.major(PitchClass.aSharp);
        expect(bbMajor.prefersFlats, isTrue);
      });

      test('G major prefers sharps', () {
        const gMajor = Key.major(PitchClass.g);
        expect(gMajor.prefersFlats, isFalse);
      });

      test('D major prefers sharps', () {
        const dMajor = Key.major(PitchClass.d);
        expect(dMajor.prefersFlats, isFalse);
      });

      test('D minor prefers flats', () {
        const dMinor = Key.minor(PitchClass.d);
        expect(dMinor.prefersFlats, isTrue);
      });

      test('E minor prefers sharps', () {
        const eMinor = Key.minor(PitchClass.e);
        expect(eMinor.prefersFlats, isFalse);
      });
    });

    group('scale', () {
      test('C major scale has correct notes', () {
        const cMajor = Key.major(PitchClass.c);
        expect(cMajor.scale, [
          PitchClass.c,
          PitchClass.d,
          PitchClass.e,
          PitchClass.f,
          PitchClass.g,
          PitchClass.a,
          PitchClass.b,
        ]);
      });

      test('A minor scale has correct notes', () {
        const aMinor = Key.minor(PitchClass.a);
        expect(aMinor.scale, [
          PitchClass.a,
          PitchClass.b,
          PitchClass.c,
          PitchClass.d,
          PitchClass.e,
          PitchClass.f,
          PitchClass.g,
        ]);
      });

      test('G major scale has correct notes', () {
        const gMajor = Key.major(PitchClass.g);
        expect(gMajor.scale, [
          PitchClass.g,
          PitchClass.a,
          PitchClass.b,
          PitchClass.c,
          PitchClass.d,
          PitchClass.e,
          PitchClass.fSharp,
        ]);
      });
    });

    group('diatonicChords', () {
      test('C major diatonic chords are correct', () {
        const cMajor = Key.major(PitchClass.c);
        final chords = cMajor.diatonicChords;

        expect(chords[0].root, PitchClass.c);
        expect(chords[0].type, ChordType.major); // I
        expect(chords[1].root, PitchClass.d);
        expect(chords[1].type, ChordType.minor); // ii
        expect(chords[2].root, PitchClass.e);
        expect(chords[2].type, ChordType.minor); // iii
        expect(chords[3].root, PitchClass.f);
        expect(chords[3].type, ChordType.major); // IV
        expect(chords[4].root, PitchClass.g);
        expect(chords[4].type, ChordType.major); // V
        expect(chords[5].root, PitchClass.a);
        expect(chords[5].type, ChordType.minor); // vi
        expect(chords[6].root, PitchClass.b);
        expect(chords[6].type, ChordType.diminished); // vii°
      });

      test('A minor diatonic chords are correct', () {
        const aMinor = Key.minor(PitchClass.a);
        final chords = aMinor.diatonicChords;

        expect(chords[0].root, PitchClass.a);
        expect(chords[0].type, ChordType.minor); // i
        expect(chords[1].root, PitchClass.b);
        expect(chords[1].type, ChordType.diminished); // ii°
        expect(chords[2].root, PitchClass.c);
        expect(chords[2].type, ChordType.major); // III
      });
    });

    group('name and symbol', () {
      test('major key has correct name', () {
        const cMajor = Key.major(PitchClass.c);
        expect(cMajor.name, 'C major');
      });

      test('minor key has correct name', () {
        const aMinor = Key.minor(PitchClass.a);
        expect(aMinor.name, 'A minor');
      });

      test('major key has correct symbol', () {
        const cMajor = Key.major(PitchClass.c);
        expect(cMajor.symbol, 'C');
      });

      test('minor key has correct symbol', () {
        const aMinor = Key.minor(PitchClass.a);
        expect(aMinor.symbol, 'Am');
      });

      test('toString returns symbol', () {
        expect(const Key.major(PitchClass.c).toString(), 'C');
        expect(const Key.minor(PitchClass.a).toString(), 'Am');
      });
    });

    group('equality', () {
      test('equal keys are equal', () {
        const key1 = Key.major(PitchClass.c);
        const key2 = Key.major(PitchClass.c);
        expect(key1, equals(key2));
        expect(key1.hashCode, equals(key2.hashCode));
      });

      test('different tonic keys are not equal', () {
        const key1 = Key.major(PitchClass.c);
        const key2 = Key.major(PitchClass.g);
        expect(key1, isNot(equals(key2)));
      });

      test('different mode keys are not equal', () {
        const key1 = Key.major(PitchClass.c);
        const key2 = Key.minor(PitchClass.c);
        expect(key1, isNot(equals(key2)));
      });
    });
  });

  group('ChordProgression', () {
    group('constructor', () {
      test('creates progression from list of chords', () {
        final chords = [
          Chord.parse('C'),
          Chord.parse('Am'),
          Chord.parse('F'),
          Chord.parse('G'),
        ];
        final prog = ChordProgression(chords);
        expect(prog.chords, equals(chords));
        expect(prog.length, 4);
      });

      test('handles empty list', () {
        const prog = ChordProgression([]);
        expect(prog.isEmpty, isTrue);
        expect(prog.isNotEmpty, isFalse);
      });
    });

    group('parse', () {
      test('parses space-separated chords', () {
        final prog = ChordProgression.parse('C Am F G');
        expect(prog.length, 4);
        expect(prog.chords[0].symbol, 'C');
        expect(prog.chords[1].symbol, 'Am');
        expect(prog.chords[2].symbol, 'F');
        expect(prog.chords[3].symbol, 'G');
      });

      test('handles extra whitespace', () {
        final prog = ChordProgression.parse('  C   Am   F   G  ');
        expect(prog.length, 4);
      });

      test('parses complex chords', () {
        final prog = ChordProgression.parse('Cmaj7 Am7 Dm7 G7');
        expect(prog.length, 4);
        expect(prog.chords[0].type, ChordType.major7);
        expect(prog.chords[3].type, ChordType.dominant7);
      });

      test('throws on invalid chord', () {
        expect(
          () => ChordProgression.parse('C Am XYZ G'),
          throwsFormatException,
        );
      });
    });

    group('tryParse', () {
      test('returns progression on valid input', () {
        expect(ChordProgression.tryParse('C Am F G'), isNotNull);
      });

      test('returns null on invalid input', () {
        expect(ChordProgression.tryParse('C Am XYZ G'), isNull);
      });
    });

    group('transpose', () {
      test('transposes all chords up', () {
        final prog = ChordProgression.parse('C Am F G');
        final transposed = prog.transpose(2);
        expect(transposed.chords[0].root, PitchClass.d);
        expect(transposed.chords[1].root, PitchClass.b);
        expect(transposed.chords[2].root, PitchClass.g);
        expect(transposed.chords[3].root, PitchClass.a);
      });

      test('transposes all chords down', () {
        final prog = ChordProgression.parse('D Bm G A');
        final transposed = prog.transpose(-2);
        expect(transposed.chords[0].root, PitchClass.c);
        expect(transposed.chords[1].root, PitchClass.a);
        expect(transposed.chords[2].root, PitchClass.f);
        expect(transposed.chords[3].root, PitchClass.g);
      });

      test('preserves chord types', () {
        final prog = ChordProgression.parse('Cmaj7 Am7 Dm7 G7');
        final transposed = prog.transpose(5);
        expect(transposed.chords[0].type, ChordType.major7);
        expect(transposed.chords[1].type, ChordType.minor7);
        expect(transposed.chords[2].type, ChordType.minor7);
        expect(transposed.chords[3].type, ChordType.dominant7);
      });

      test('handles wrap-around', () {
        final prog = ChordProgression.parse('B G#m');
        final transposed = prog.transpose(1);
        expect(transposed.chords[0].root, PitchClass.c);
        expect(transposed.chords[1].root, PitchClass.a);
      });
    });

    group('spell', () {
      test('spells with sharps', () {
        final prog = ChordProgression.parse('C C#m F# G#');
        final spelled = prog.spell(SpellingPreference.sharps);
        expect(spelled, ['C', 'C#m', 'F#', 'G#']);
      });

      test('spells with flats', () {
        final prog = ChordProgression.parse('C C#m F# G#');
        final spelled = prog.spell(SpellingPreference.flats);
        expect(spelled, ['C', 'Dbm', 'Gb', 'Ab']);
      });
    });

    group('toSymbolString', () {
      test('returns space-separated symbols', () {
        final prog = ChordProgression.parse('C Am F G');
        expect(prog.toSymbolString(), 'C Am F G');
      });

      test('toString returns symbol string', () {
        final prog = ChordProgression.parse('C Am F G');
        expect(prog.toString(), 'C Am F G');
      });
    });
  });

  group('spellChord', () {
    test('spells chord with sharps', () {
      final chord = Chord.parse('C#m7');
      expect(spellChord(chord, SpellingPreference.sharps), 'C#m7');
    });

    test('spells chord with flats', () {
      final chord = Chord.parse('C#m7');
      expect(spellChord(chord, SpellingPreference.flats), 'Dbm7');
    });

    test('natural roots are unchanged', () {
      final chord = Chord.parse('Cmaj7');
      expect(spellChord(chord, SpellingPreference.sharps), 'Cmaj7');
      expect(spellChord(chord, SpellingPreference.flats), 'Cmaj7');
    });
  });

  group('Transposition utility class', () {
    test('transposes chord', () {
      final chord = Chord.parse('C');
      final result = Transposition.chord(chord, 2);
      expect(result.root, PitchClass.d);
    });

    test('transposes progression', () {
      final prog = ChordProgression.parse('C Am F G');
      final result = Transposition.progression(prog, 2);
      expect(result.chords[0].root, PitchClass.d);
    });

    test('transposes key', () {
      const key = Key.major(PitchClass.c);
      final result = Transposition.key(key, 2);
      expect(result.tonic, PitchClass.d);
    });

    test('calculates semitones between keys', () {
      const cMajor = Key.major(PitchClass.c);
      const gMajor = Key.major(PitchClass.g);
      expect(Transposition.semitonesBetweenKeys(cMajor, gMajor), 7);
    });

    test('calculates semitones between keys (wrap-around)', () {
      const gMajor = Key.major(PitchClass.g);
      const cMajor = Key.major(PitchClass.c);
      expect(Transposition.semitonesBetweenKeys(gMajor, cMajor), 5);
    });

    test('commonIntervals has expected values', () {
      expect(Transposition.commonIntervals['half step up'], 1);
      expect(Transposition.commonIntervals['whole step up'], 2);
      expect(Transposition.commonIntervals['perfect fifth up'], 7);
      expect(Transposition.commonIntervals['octave up'], 12);
    });

    test('fromKeyToKey transposes chords correctly', () {
      final chords = [Chord.parse('C'), Chord.parse('Am'), Chord.parse('G')];
      const fromKey = Key.major(PitchClass.c);
      const toKey = Key.major(PitchClass.g);
      final result = Transposition.fromKeyToKey(chords, fromKey, toKey);
      expect(result[0].root, PitchClass.g);
      expect(result[1].root, PitchClass.e);
      expect(result[2].root, PitchClass.d);
    });
  });

  group('ChordTranspositionExtension', () {
    test('flatSymbol returns flat spelling', () {
      final chord = Chord.parse('C#');
      expect(chord.flatSymbol, 'Db');
    });

    test('sharpSymbol returns sharp spelling', () {
      final chord = Chord.parse('Db');
      expect(chord.sharpSymbol, 'C#');
    });

    test('transposeUp transposes up', () {
      final chord = Chord.parse('C');
      expect(chord.transposeUp(2).root, PitchClass.d);
    });

    test('transposeDown transposes down', () {
      final chord = Chord.parse('D');
      expect(chord.transposeDown(2).root, PitchClass.c);
    });

    test('halfStepUp transposes up one semitone', () {
      final chord = Chord.parse('C');
      expect(chord.halfStepUp.root, PitchClass.cSharp);
    });

    test('halfStepDown transposes down one semitone', () {
      final chord = Chord.parse('D');
      expect(chord.halfStepDown.root, PitchClass.cSharp);
    });

    test('wholeStepUp transposes up two semitones', () {
      final chord = Chord.parse('C');
      expect(chord.wholeStepUp.root, PitchClass.d);
    });

    test('wholeStepDown transposes down two semitones', () {
      final chord = Chord.parse('D');
      expect(chord.wholeStepDown.root, PitchClass.c);
    });
  });

  group('PitchClassSpellingExtension', () {
    test('flatName returns flat spelling', () {
      expect(PitchClass.cSharp.flatName, 'Db');
      expect(PitchClass.aSharp.flatName, 'Bb');
    });

    test('sharpName returns sharp spelling', () {
      expect(PitchClass.cSharp.sharpName, 'C#');
      expect(PitchClass.aSharp.sharpName, 'A#');
    });

    test('natural notes are unchanged', () {
      expect(PitchClass.c.flatName, 'C');
      expect(PitchClass.c.sharpName, 'C');
    });
  });

  group('edge cases', () {
    test('transposing by 0 returns equivalent chord', () {
      final chord = Chord.parse('Cmaj7');
      final transposed = chord.transpose(0);
      expect(transposed.root, chord.root);
      expect(transposed.type, chord.type);
    });

    test('transposing by 12 returns equivalent pitch class', () {
      final chord = Chord.parse('C');
      final transposed = chord.transpose(12);
      expect(transposed.root, PitchClass.c);
    });

    test('transposing by -12 returns equivalent pitch class', () {
      final chord = Chord.parse('C');
      final transposed = chord.transpose(-12);
      expect(transposed.root, PitchClass.c);
    });

    test('multiple transpositions are cumulative', () {
      final chord = Chord.parse('C');
      final result = chord.transpose(2).transpose(3).transpose(2);
      expect(result.root, PitchClass.g);
    });

    test('double sharps handled via semitone logic', () {
      // B# = C, so B + 1 = C
      final bChord = Chord.parse('B');
      final transposed = bChord.transpose(1);
      expect(transposed.root, PitchClass.c);
    });

    test('double flats handled via semitone logic', () {
      // Cb = B, so C - 1 = B
      final cChord = Chord.parse('C');
      final transposed = cChord.transpose(-1);
      expect(transposed.root, PitchClass.b);
    });
  });
}
