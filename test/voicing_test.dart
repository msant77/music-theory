import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('StringPosition', () {
    group('constructors', () {
      test('default constructor creates position with fret', () {
        const pos = StringPosition(fret: 2);
        expect(pos.fret, equals(2));
        expect(pos.finger, isNull);
      });

      test('constructor with finger', () {
        const pos = StringPosition(fret: 3, finger: 2);
        expect(pos.fret, equals(3));
        expect(pos.finger, equals(2));
      });

      test('muted constructor creates muted position', () {
        const pos = StringPosition.muted();
        expect(pos.fret, isNull);
        expect(pos.isMuted, isTrue);
      });

      test('open constructor creates open position', () {
        const pos = StringPosition.open();
        expect(pos.fret, equals(0));
        expect(pos.isOpen, isTrue);
      });

      test('fretted constructor creates fretted position', () {
        const pos = StringPosition.fretted(5, finger: 3);
        expect(pos.fret, equals(5));
        expect(pos.finger, equals(3));
        expect(pos.isFretted, isTrue);
      });
    });

    group('properties', () {
      test('isMuted returns true for muted strings', () {
        expect(const StringPosition.muted().isMuted, isTrue);
        expect(const StringPosition().isMuted, isTrue);
      });

      test('isMuted returns false for played strings', () {
        expect(const StringPosition.open().isMuted, isFalse);
        expect(const StringPosition.fretted(3).isMuted, isFalse);
      });

      test('isOpen returns true for open strings', () {
        expect(const StringPosition.open().isOpen, isTrue);
        expect(const StringPosition(fret: 0).isOpen, isTrue);
      });

      test('isOpen returns false for fretted/muted strings', () {
        expect(const StringPosition.muted().isOpen, isFalse);
        expect(const StringPosition.fretted(3).isOpen, isFalse);
      });

      test('isFretted returns true for fretted strings', () {
        expect(const StringPosition.fretted(1).isFretted, isTrue);
        expect(const StringPosition(fret: 5).isFretted, isTrue);
      });

      test('isFretted returns false for open/muted strings', () {
        expect(const StringPosition.muted().isFretted, isFalse);
        expect(const StringPosition.open().isFretted, isFalse);
      });

      test('isPlayed returns true for non-muted strings', () {
        expect(const StringPosition.open().isPlayed, isTrue);
        expect(const StringPosition.fretted(3).isPlayed, isTrue);
      });

      test('isPlayed returns false for muted strings', () {
        expect(const StringPosition.muted().isPlayed, isFalse);
      });
    });

    group('toString', () {
      test('muted returns X', () {
        expect(const StringPosition.muted().toString(), equals('X'));
      });

      test('open returns O', () {
        expect(const StringPosition.open().toString(), equals('O'));
      });

      test('fretted returns fret number', () {
        expect(const StringPosition.fretted(3).toString(), equals('3'));
        expect(const StringPosition.fretted(12).toString(), equals('12'));
      });
    });

    group('equality', () {
      test('equal positions are equal', () {
        expect(const StringPosition(fret: 2),
            equals(const StringPosition(fret: 2)));
        expect(
            const StringPosition.muted(), equals(const StringPosition.muted()));
      });

      test('different positions are not equal', () {
        expect(const StringPosition(fret: 2),
            isNot(equals(const StringPosition(fret: 3))));
        expect(const StringPosition.muted(),
            isNot(equals(const StringPosition.open())));
      });

      test('positions with different fingers are not equal', () {
        expect(
          const StringPosition(fret: 2, finger: 1),
          isNot(equals(const StringPosition(fret: 2, finger: 2))),
        );
      });
    });
  });

  group('Barre', () {
    test('creates barre with required fields', () {
      const barre = Barre(fret: 1, fromString: 0, toIndex: 5);
      expect(barre.fret, equals(1));
      expect(barre.fromString, equals(0));
      expect(barre.toIndex, equals(5));
      expect(barre.finger, equals(1)); // default
    });

    test('creates barre with custom finger', () {
      const barre = Barre(fret: 3, fromString: 1, toIndex: 4, finger: 2);
      expect(barre.finger, equals(2));
    });

    test('stringCount returns number of strings covered', () {
      const barre = Barre(fret: 1, fromString: 0, toIndex: 5);
      expect(barre.stringCount, equals(6));

      const partial = Barre(fret: 2, fromString: 2, toIndex: 4);
      expect(partial.stringCount, equals(3));
    });

    test('equality', () {
      const b1 = Barre(fret: 1, fromString: 0, toIndex: 5);
      const b2 = Barre(fret: 1, fromString: 0, toIndex: 5);
      const b3 = Barre(fret: 2, fromString: 0, toIndex: 5);

      expect(b1, equals(b2));
      expect(b1, isNot(equals(b3)));
    });
  });

  group('Voicing', () {
    group('constructors', () {
      test('creates voicing from positions', () {
        const voicing = Voicing(positions: [
          StringPosition.muted(),
          StringPosition.open(),
          StringPosition.fretted(2),
          StringPosition.fretted(2),
          StringPosition.fretted(1),
          StringPosition.open(),
        ]);
        expect(voicing.stringCount, equals(6));
      });

      test('fromFrets creates voicing from fret numbers', () {
        final voicing = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(voicing.positions[0].isMuted, isTrue);
        expect(voicing.positions[1].isOpen, isTrue);
        expect(voicing.positions[2].fret, equals(2));
      });

      test('fromFrets treats -1 as muted', () {
        final voicing = Voicing.fromFrets([-1, 0, 2, 2, 1, 0]);
        expect(voicing.positions[0].isMuted, isTrue);
      });
    });

    group('parse', () {
      test('parses compact string', () {
        final voicing = Voicing.parse('X02210');
        expect(voicing.positions[0].isMuted, isTrue);
        expect(voicing.positions[1].isOpen, isTrue);
        expect(voicing.positions[2].fret, equals(2));
        expect(voicing.positions[3].fret, equals(2));
        expect(voicing.positions[4].fret, equals(1));
        expect(voicing.positions[5].isOpen, isTrue);
      });

      test('parses lowercase x', () {
        final voicing = Voicing.parse('x02210');
        expect(voicing.positions[0].isMuted, isTrue);
      });

      test('parses O as open', () {
        final voicing = Voicing.parse('XO221O');
        expect(voicing.positions[1].isOpen, isTrue);
        expect(voicing.positions[5].isOpen, isTrue);
      });

      test('parses hyphen-delimited string for multi-digit frets', () {
        final voicing = Voicing.parse('X-0-10-10-9-0');
        expect(voicing.positions[2].fret, equals(10));
        expect(voicing.positions[3].fret, equals(10));
        expect(voicing.positions[4].fret, equals(9));
      });

      test('parses space-delimited string', () {
        final voicing = Voicing.parse('X 0 10 10 9 0');
        expect(voicing.positions[2].fret, equals(10));
      });

      test('throws on empty string', () {
        expect(() => Voicing.parse(''), throwsFormatException);
        expect(() => Voicing.parse('   '), throwsFormatException);
      });
    });

    group('properties', () {
      test('playedStringCount counts non-muted strings', () {
        final voicing = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(voicing.playedStringCount, equals(5));
      });

      test('mutedStringCount counts muted strings', () {
        final voicing = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(voicing.mutedStringCount, equals(1));
      });

      test('frettedStringCount counts fretted strings', () {
        final voicing = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(voicing.frettedStringCount, equals(3));
      });

      test('lowestFret returns lowest fretted position', () {
        final voicing = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(voicing.lowestFret, equals(1));
      });

      test('lowestFret returns null for all open/muted', () {
        final voicing = Voicing.fromFrets([null, 0, 0, 0, 0, 0]);
        expect(voicing.lowestFret, isNull);
      });

      test('highestFret returns highest fretted position', () {
        final voicing = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(voicing.highestFret, equals(2));
      });

      test('fretSpan calculates span correctly', () {
        final voicing = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(voicing.fretSpan, equals(1)); // 2 - 1 = 1

        final wide = Voicing.fromFrets([3, 3, 5, 5, 5, 3]);
        expect(wide.fretSpan, equals(2)); // 5 - 3 = 2
      });

      test('fretSpan returns 0 for all open', () {
        final voicing = Voicing.fromFrets([0, 0, 0, 0, 0, 0]);
        expect(voicing.fretSpan, equals(0));
      });

      test('isAllOpen returns true for all open/muted voicings', () {
        final voicing = Voicing.fromFrets([null, 0, 0, 0, 0, 0]);
        expect(voicing.isAllOpen, isTrue);
      });

      test('isAllOpen returns false if any fretted', () {
        final voicing = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(voicing.isAllOpen, isFalse);
      });

      test('requiresBarre returns true if barre is set', () {
        const voicing = Voicing(
          positions: [
            StringPosition.fretted(1),
            StringPosition.fretted(3),
            StringPosition.fretted(3),
            StringPosition.fretted(2),
            StringPosition.fretted(1),
            StringPosition.fretted(1),
          ],
          barre: Barre(fret: 1, fromString: 0, toIndex: 5),
        );
        expect(voicing.requiresBarre, isTrue);
      });
    });

    group('difficultyScore', () {
      test('open chords have low difficulty', () {
        // Am chord - open position
        final am = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(am.difficultyScore, lessThan(30));
        expect(am.difficulty, equals(VoicingDifficulty.beginner));
      });

      test('barre chords have higher difficulty', () {
        // F major barre chord
        const f = Voicing(
          positions: [
            StringPosition.fretted(1),
            StringPosition.fretted(3),
            StringPosition.fretted(3),
            StringPosition.fretted(2),
            StringPosition.fretted(1),
            StringPosition.fretted(1),
          ],
          barre: Barre(fret: 1, fromString: 0, toIndex: 5),
        );
        expect(f.difficultyScore, greaterThan(30));
      });

      test('wide stretches increase difficulty', () {
        final narrow = Voicing.fromFrets([3, 3, 3, 3, 3, 3]);
        final wide = Voicing.fromFrets([3, 3, 6, 6, 6, 3]);

        expect(wide.difficultyScore, greaterThan(narrow.difficultyScore));
      });

      test('higher positions increase difficulty', () {
        final low = Voicing.fromFrets([1, 1, 1, 1, 1, 1]);
        final high = Voicing.fromFrets([10, 10, 10, 10, 10, 10]);

        expect(high.difficultyScore, greaterThan(low.difficultyScore));
      });
    });

    group('fingersRequired', () {
      test('returns 0 for all open/muted voicing', () {
        final voicing = Voicing.fromFrets([null, 0, 0, 0, 0, 0]);
        expect(voicing.fingersRequired, equals(0));
      });

      test('counts unique frets for simple voicing', () {
        // Am: X02210 - frets 1 and 2 used, so 2 fingers at different frets
        // Actually: 2,2,1 = frets 1 and 2 used
        // lowest fret = 1 (1 string), frets above: 2 (2 strings)
        // = 1 + 2 = 3 fingers
        final am = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(am.fingersRequired, equals(3));
      });

      test('treats multiple strings at lowest fret as potential barre', () {
        // Voicing with 3 strings at fret 5, 1 string at fret 7
        // = 1 finger (barre) + 1 finger = 2 fingers
        final voicing = Voicing.fromFrets([5, 5, 5, null, 7, null]);
        expect(voicing.fingersRequired, equals(2));
      });

      test('counts multiple strings at higher frets individually', () {
        // Fret 2 on strings 0,1 (valid barre) + fret 3 on strings 2,3 = 1 + 2 = 3
        final voicing = Voicing.fromFrets([2, 2, 3, 3, null, null]);
        expect(voicing.fingersRequired, equals(3));
      });

      test('invalid barre when higher fret in range', () {
        // X2323X = strings 1,3 at fret 2, strings 2,4 at fret 3
        // Barre from string 1 to 3 is invalid because string 2 is at fret 3
        // So: strings 1,3 at fret 2 = 2 fingers, strings 2,4 at fret 3 = 2 fingers = 4 total
        final voicing = Voicing.fromFrets([null, 2, 3, 2, 3, null]);
        expect(voicing.fingersRequired, equals(4));
      });

      test(
          'voicing with 5 fretted strings at different frets requires 5 fingers',
          () {
        // X23231 = 5 fretted strings at frets 2,3,2,3,1
        // lowest = 1 (1 string), 2 (2 strings), 3 (2 strings) = 1 + 2 + 2 = 5
        final voicing = Voicing.fromFrets([null, 2, 3, 2, 3, 1]);
        expect(voicing.fingersRequired, equals(5));
      });
    });

    group('pitchClassesOn', () {
      late Instrument guitar;

      setUp(() {
        guitar = Instruments.guitar;
      });

      test('returns pitch classes for Am chord', () {
        // Am: X02210
        final am = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        final pitches = am.pitchClassesOn(guitar);

        expect(pitches.length, equals(5));
        expect(pitches, contains(PitchClass.a)); // open A
        expect(pitches, contains(PitchClass.e)); // D + 2 frets = E
        expect(pitches, contains(PitchClass.a)); // G + 2 frets = A
        expect(pitches, contains(PitchClass.c)); // B + 1 fret = C
        expect(pitches, contains(PitchClass.e)); // open e
      });

      test('returns pitch classes for C chord', () {
        // C: X32010
        final c = Voicing.fromFrets([null, 3, 2, 0, 1, 0]);
        final pitches = c.pitchClassesOn(guitar);

        expect(pitches.toSet(),
            containsAll([PitchClass.c, PitchClass.e, PitchClass.g]));
      });

      test('throws if voicing does not match instrument string count', () {
        final voicing = Voicing.fromFrets([0, 0, 0, 0]); // 4 strings
        expect(
          () => voicing.pitchClassesOn(guitar), // 6 strings
          throwsArgumentError,
        );
      });
    });

    group('playsChord', () {
      late Instrument guitar;

      setUp(() {
        guitar = Instruments.guitar;
      });

      test('returns true for correct Am voicing', () {
        final am = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        final chord = Chord.parse('Am');

        expect(am.playsChord(chord, guitar), isTrue);
      });

      test('returns true for correct C voicing', () {
        final c = Voicing.fromFrets([null, 3, 2, 0, 1, 0]);
        final chord = Chord.parse('C');

        expect(c.playsChord(chord, guitar), isTrue);
      });

      test('returns false if root is missing', () {
        // E major notes but no E root
        final noRoot = Voicing.fromFrets([null, null, 1, 2, 2, null]);
        final chord = Chord.parse('E');

        expect(noRoot.playsChord(chord, guitar), isFalse);
      });

      test('returns false if wrong notes are played', () {
        final am = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        final chord = Chord.parse('C');

        // Am voicing doesn't play C chord (has A as root, not C)
        expect(am.playsChord(chord, guitar), isFalse);
      });
    });

    group('toCompactString', () {
      test('returns compact string', () {
        final voicing = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        expect(voicing.toCompactString(), equals('X02210'));
      });

      test('handles double-digit frets', () {
        final voicing = Voicing.fromFrets([null, 0, 10, 10, 9, 0]);
        expect(voicing.toCompactString(), equals('X0(10)(10)90'));
      });
    });

    group('equality', () {
      test('equal voicings are equal', () {
        final v1 = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        final v2 = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);

        expect(v1, equals(v2));
      });

      test('different voicings are not equal', () {
        final v1 = Voicing.fromFrets([null, 0, 2, 2, 1, 0]);
        final v2 = Voicing.fromFrets([0, 0, 2, 2, 1, 0]);

        expect(v1, isNot(equals(v2)));
      });
    });
  });

  group('VoicingDifficulty', () {
    test('has three levels', () {
      expect(VoicingDifficulty.values.length, equals(3));
      expect(VoicingDifficulty.values, contains(VoicingDifficulty.beginner));
      expect(
          VoicingDifficulty.values, contains(VoicingDifficulty.intermediate));
      expect(VoicingDifficulty.values, contains(VoicingDifficulty.advanced));
    });
  });
}
