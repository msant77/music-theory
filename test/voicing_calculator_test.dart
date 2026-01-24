import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  late Instrument guitar;

  setUp(() {
    guitar = Instruments.guitar;
  });

  group('VoicingCalculatorOptions', () {
    test('default options have reasonable values', () {
      const options = VoicingCalculatorOptions();
      expect(options.maxFretSpan, equals(4));
      expect(options.maxFret, equals(12));
      expect(options.minFret, equals(0));
      expect(options.rootInBass, isTrue);
      expect(options.minStringsPlayed, equals(3));
    });

    test('beginner options are restrictive', () {
      const options = VoicingCalculatorOptions.beginner;
      expect(options.maxFretSpan, equals(3));
      expect(options.maxFret, equals(5));
      expect(options.allowInteriorMutes, isFalse);
      expect(options.maxDifficulty, equals(VoicingDifficulty.beginner));
    });

    test('advanced options are permissive', () {
      const options = VoicingCalculatorOptions.advanced;
      expect(options.maxFretSpan, equals(5));
      expect(options.maxFret, equals(12));
      expect(options.rootInBass, isFalse);
    });
  });

  group('VoicingCalculator', () {
    group('findVoicings', () {
      test('finds voicings for C major', () {
        final chord = Chord.parse('C');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        expect(voicings, isNotEmpty);

        // All voicings should play a valid C chord
        for (final voicing in voicings) {
          expect(voicing.playsChord(chord, guitar), isTrue);
        }
      });

      test('finds voicings for Am', () {
        final chord = Chord.parse('Am');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        expect(voicings, isNotEmpty);

        // Should include the standard X02210 voicing
        final standard = Voicing.parse('X02210');
        final hasStandard = voicings
            .any((v) => v.toCompactString() == standard.toCompactString());
        expect(hasStandard, isTrue);
      });

      test('finds voicings for G major', () {
        final chord = Chord.parse('G');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        expect(voicings, isNotEmpty);
      });

      test('finds voicings for D major', () {
        final chord = Chord.parse('D');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        expect(voicings, isNotEmpty);
      });

      test('finds voicings for E major', () {
        final chord = Chord.parse('E');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        expect(voicings, isNotEmpty);

        // Should include standard 022100
        final standard = Voicing.parse('022100');
        final hasStandard = voicings
            .any((v) => v.toCompactString() == standard.toCompactString());
        expect(hasStandard, isTrue);
      });

      test('voicings are sorted by difficulty', () {
        final chord = Chord.parse('C');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        for (var i = 1; i < voicings.length; i++) {
          expect(
            voicings[i].difficultyScore,
            greaterThanOrEqualTo(voicings[i - 1].difficultyScore),
          );
        }
      });

      test('respects maxFretSpan option', () {
        final chord = Chord.parse('C');
        const options = VoicingCalculatorOptions(maxFretSpan: 2);
        final calc = VoicingCalculator(guitar, options: options);
        final voicings = calc.findVoicings(chord);

        for (final voicing in voicings) {
          expect(voicing.fretSpan, lessThanOrEqualTo(2));
        }
      });

      test('respects minStringsPlayed option', () {
        final chord = Chord.parse('C');
        const options = VoicingCalculatorOptions(minStringsPlayed: 5);
        final calc = VoicingCalculator(guitar, options: options);
        final voicings = calc.findVoicings(chord);

        for (final voicing in voicings) {
          expect(voicing.playedStringCount, greaterThanOrEqualTo(5));
        }
      });

      test('respects maxMutedStrings option', () {
        final chord = Chord.parse('C');
        const options = VoicingCalculatorOptions(maxMutedStrings: 1);
        final calc = VoicingCalculator(guitar, options: options);
        final voicings = calc.findVoicings(chord);

        for (final voicing in voicings) {
          expect(voicing.mutedStringCount, lessThanOrEqualTo(1));
        }
      });

      test('respects maxFingers option', () {
        // Bm7b5 is a good test case - has many potential voicings
        final chord = Chord.parse('Bm7b5');
        const options = VoicingCalculatorOptions(
          maxDifficulty: VoicingDifficulty.intermediate,
        );
        final calc = VoicingCalculator(guitar, options: options);
        final voicings = calc.findVoicings(chord);

        // All voicings should require 4 or fewer fingers
        for (final voicing in voicings) {
          expect(
            voicing.fingersRequired,
            lessThanOrEqualTo(4),
            reason: '${voicing.toCompactString()} requires '
                '${voicing.fingersRequired} fingers',
          );
        }
      });

      test('respects rootInBass option', () {
        final chord = Chord.parse('C');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        for (final voicing in voicings) {
          // Find bass note
          for (var i = 0; i < voicing.positions.length; i++) {
            if (voicing.positions[i].isPlayed) {
              final bassPitch =
                  guitar.soundingNoteAt(i, voicing.positions[i].fret!);
              expect(bassPitch, equals(PitchClass.c));
              break;
            }
          }
        }
      });

      test('finds voicings without root in bass when option is false', () {
        final chord = Chord.parse('C');
        const options = VoicingCalculatorOptions(rootInBass: false);
        final calc = VoicingCalculator(guitar, options: options);
        final voicings = calc.findVoicings(chord);

        // Should have more voicings when inversions are allowed
        final withRootCalc = VoicingCalculator(guitar);
        final withRootVoicings = withRootCalc.findVoicings(chord);

        expect(voicings.length, greaterThanOrEqualTo(withRootVoicings.length));
      });

      test('respects maxDifficulty option', () {
        final chord = Chord.parse('C');
        const options = VoicingCalculatorOptions(
          maxDifficulty: VoicingDifficulty.beginner,
        );
        final calc = VoicingCalculator(guitar, options: options);
        final voicings = calc.findVoicings(chord);

        for (final voicing in voicings) {
          expect(voicing.difficulty, equals(VoicingDifficulty.beginner));
        }
      });
    });

    group('findEasiestVoicings', () {
      test('returns limited number of voicings', () {
        final chord = Chord.parse('C');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findEasiestVoicings(chord, limit: 3);

        expect(voicings.length, lessThanOrEqualTo(3));
      });

      test('returns easiest voicings first', () {
        final chord = Chord.parse('C');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findEasiestVoicings(chord);
        final allVoicings = calc.findVoicings(chord);

        // First few should match
        for (var i = 0; i < voicings.length && i < allVoicings.length; i++) {
          expect(voicings[i], equals(allVoicings[i]));
        }
      });
    });

    group('findVoicingsGroupedByPosition', () {
      test('groups voicings by fret position', () {
        final chord = Chord.parse('C');
        final calc = VoicingCalculator(guitar);
        final grouped = calc.findVoicingsGroupedByPosition(chord);

        expect(grouped, isNotEmpty);

        // Open position voicings should be at key 0 or low frets
        expect(grouped.keys.any((k) => k <= 3), isTrue);
      });
    });

    group('with different instruments', () {
      test('finds voicings for ukulele', () {
        const ukulele = Instruments.ukulele;
        final chord = Chord.parse('C');
        final calc = VoicingCalculator(ukulele);
        final voicings = calc.findVoicings(chord);

        expect(voicings, isNotEmpty);

        // All should have 4 positions (ukulele strings)
        for (final voicing in voicings) {
          expect(voicing.stringCount, equals(4));
        }
      });

      test('finds voicings for bass', () {
        const bass = Instruments.bass;
        final chord = Chord.parse('C');
        // Bass usually plays roots and fifths, so relax options
        const options = VoicingCalculatorOptions(
          minStringsPlayed: 2,
        );
        final calc = VoicingCalculator(bass, options: options);
        final voicings = calc.findVoicings(chord);

        expect(voicings, isNotEmpty);
      });
    });

    group('known chord shapes', () {
      test('includes standard C major shape', () {
        final chord = Chord.parse('C');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        // X32010 is the standard C shape
        final standard = Voicing.parse('X32010');
        final found = voicings
            .any((v) => v.toCompactString() == standard.toCompactString());
        expect(found, isTrue, reason: 'Should include standard C shape X32010');
      });

      test('includes standard G major shape', () {
        final chord = Chord.parse('G');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        // 320003 is a common G shape
        final standard = Voicing.parse('320003');
        final found = voicings
            .any((v) => v.toCompactString() == standard.toCompactString());
        expect(found, isTrue, reason: 'Should include G shape 320003');
      });

      test('includes standard D major shape', () {
        final chord = Chord.parse('D');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        // XX0232 is the standard D shape
        final standard = Voicing.parse('XX0232');
        final found = voicings
            .any((v) => v.toCompactString() == standard.toCompactString());
        expect(found, isTrue, reason: 'Should include standard D shape XX0232');
      });

      test('includes standard Em shape', () {
        final chord = Chord.parse('Em');
        final calc = VoicingCalculator(guitar);
        final voicings = calc.findVoicings(chord);

        // 022000 is the standard Em shape
        final standard = Voicing.parse('022000');
        final found = voicings
            .any((v) => v.toCompactString() == standard.toCompactString());
        expect(found, isTrue,
            reason: 'Should include standard Em shape 022000');
      });
    });
  });

  group('ChordVoicingExtension', () {
    test('voicingsOn returns voicings', () {
      final chord = Chord.parse('Am');
      final voicings = chord.voicingsOn(guitar);

      expect(voicings, isNotEmpty);
    });

    test('easyVoicingsOn returns beginner or intermediate voicings', () {
      final chord = Chord.parse('C');
      final voicings = chord.easyVoicingsOn(guitar, limit: 3);

      expect(voicings.length, lessThanOrEqualTo(3));
      // Should include common chords like C major (X32010) which is intermediate
      expect(voicings, isNotEmpty);

      // All should be beginner or intermediate level (not advanced)
      for (final voicing in voicings) {
        expect(
          voicing.difficulty,
          isNot(equals(VoicingDifficulty.advanced)),
        );
      }
    });
  });
}
