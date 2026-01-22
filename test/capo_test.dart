import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  late Instrument guitar;

  setUp(() {
    guitar = Instruments.guitar;
  });

  group('CapoSuggestion', () {
    test('has correct properties', () {
      final suggestion = CapoSuggestion(
        capoFret: 2,
        shapes: [Chord.parse('A'), Chord.parse('D')],
        originalChords: [Chord.parse('B'), Chord.parse('E')],
        difficultyScore: 2.0,
      );

      expect(suggestion.capoFret, 2);
      expect(suggestion.shapes.length, 2);
      expect(suggestion.originalChords.length, 2);
      expect(suggestion.difficultyScore, 2.0);
    });

    test('shapeSymbols returns correct symbols', () {
      final suggestion = CapoSuggestion(
        capoFret: 1,
        shapes: [Chord.parse('E'), Chord.parse('Am')],
        originalChords: [Chord.parse('F'), Chord.parse('Bbm')],
        difficultyScore: 2.0,
      );

      expect(suggestion.shapeSymbols, ['E', 'Am']);
    });

    test('description for capo position', () {
      final suggestion = CapoSuggestion(
        capoFret: 3,
        shapes: [Chord.parse('C'), Chord.parse('G')],
        originalChords: [Chord.parse('Eb'), Chord.parse('Bb')],
        difficultyScore: 2.0,
      );

      expect(suggestion.description, 'Capo fret 3: play C, G');
    });

    test('description for no capo', () {
      final suggestion = CapoSuggestion(
        capoFret: 0,
        shapes: [Chord.parse('C'), Chord.parse('G')],
        originalChords: [Chord.parse('C'), Chord.parse('G')],
        difficultyScore: 2.0,
      );

      expect(suggestion.description, 'No capo needed');
    });

    test('toString returns description', () {
      final suggestion = CapoSuggestion(
        capoFret: 1,
        shapes: [Chord.parse('E')],
        originalChords: [Chord.parse('F')],
        difficultyScore: 1.0,
      );

      expect(suggestion.toString(), 'Capo fret 1: play E');
    });
  });

  group('CapoSuggester', () {
    group('suggest', () {
      test('returns empty list for empty chords', () {
        final suggester = CapoSuggester(guitar);
        final suggestions = suggester.suggest([]);
        expect(suggestions, isEmpty);
      });

      test('suggests capo for F major -> E shape', () {
        final suggester = CapoSuggester(guitar);
        final suggestions = suggester.suggest([Chord.parse('F')]);

        // Should include capo 1 with E shape
        final capo1 = suggestions.firstWhere((s) => s.capoFret == 1);
        expect(capo1.shapes.first.root, PitchClass.e);
        expect(capo1.shapes.first.type, ChordType.major);
      });

      test('suggests capo for Bb major -> A shape', () {
        final suggester = CapoSuggester(guitar);
        final suggestions = suggester.suggest([Chord.parse('Bb')]);

        // Should include capo 1 with A shape
        final capo1 = suggestions.firstWhere((s) => s.capoFret == 1);
        expect(capo1.shapes.first.root, PitchClass.a);
      });

      test('sorts suggestions by difficulty', () {
        final suggester = CapoSuggester(guitar);
        final suggestions =
            suggester.suggest([Chord.parse('F'), Chord.parse('Bb')]);

        // Should be sorted by difficulty
        for (var i = 1; i < suggestions.length; i++) {
          expect(
            suggestions[i].difficultyScore,
            greaterThanOrEqualTo(suggestions[i - 1].difficultyScore),
          );
        }
      });

      test('handles multiple chords', () {
        final suggester = CapoSuggester(guitar);
        final suggestions = suggester.suggest([
          Chord.parse('F'),
          Chord.parse('Bb'),
          Chord.parse('C'),
        ]);

        expect(suggestions, isNotEmpty);
        // Each suggestion should have 3 shapes
        for (final suggestion in suggestions) {
          expect(suggestion.shapes.length, 3);
        }
      });

      test('respects maxCapoFret', () {
        final suggester = CapoSuggester(guitar, maxCapoFret: 5);
        final suggestions = suggester.suggest([Chord.parse('F')]);

        // Should have at most 6 suggestions (0-5)
        expect(suggestions.length, 6);
        for (final suggestion in suggestions) {
          expect(suggestion.capoFret, lessThanOrEqualTo(5));
        }
      });

      test('easy chords without capo score well', () {
        final suggester = CapoSuggester(guitar);
        final suggestions = suggester.suggest([
          Chord.parse('C'),
          Chord.parse('G'),
          Chord.parse('Am'),
        ]);

        // No capo (position 0) should be among the best
        final noCapo = suggestions.firstWhere((s) => s.capoFret == 0);
        expect(noCapo.difficultyScore, lessThanOrEqualTo(3.0));
      });
    });

    group('suggestForProgression', () {
      test('works with chord progression', () {
        final suggester = CapoSuggester(guitar);
        final prog = ChordProgression.parse('F Bb C');
        final suggestions = suggester.suggestForProgression(prog);

        expect(suggestions, isNotEmpty);
      });
    });

    group('suggestBest', () {
      test('returns best suggestion', () {
        final suggester = CapoSuggester(guitar);
        final best = suggester.suggestBest([Chord.parse('F')]);

        expect(best, isNotNull);
        // E shape with capo 1 should be among the best options for F
        expect(best!.difficultyScore, lessThanOrEqualTo(2.0));
      });

      test('returns null for empty chords', () {
        final suggester = CapoSuggester(guitar);
        final best = suggester.suggestBest([]);

        expect(best, isNull);
      });
    });
  });

  group('chord difficulty scoring', () {
    test('easy open chords score lowest', () {
      final suggester = CapoSuggester(guitar);

      // C, G, D, E, A major should all score 1.0 total for single chord
      for (final root in ['C', 'G', 'D', 'E', 'A']) {
        final suggestions = suggester.suggest([Chord.parse(root)]);
        final noCapo = suggestions.firstWhere((s) => s.capoFret == 0);
        expect(noCapo.difficultyScore, 1.0, reason: '$root should score 1.0');
      }
    });

    test('easy minor chords score lowest', () {
      final suggester = CapoSuggester(guitar);

      // Am, Em, Dm should score 1.0
      for (final chord in ['Am', 'Em', 'Dm']) {
        final suggestions = suggester.suggest([Chord.parse(chord)]);
        final noCapo = suggestions.firstWhere((s) => s.capoFret == 0);
        expect(noCapo.difficultyScore, 1.0, reason: '$chord should score 1.0');
      }
    });

    test('F major scores higher than easy chords', () {
      final suggester = CapoSuggester(guitar);
      final suggestions = suggester.suggest([Chord.parse('F')]);
      final noCapo = suggestions.firstWhere((s) => s.capoFret == 0);

      expect(noCapo.difficultyScore, greaterThan(1.0));
    });

    test('barre chords score higher than open chords', () {
      final suggester = CapoSuggester(guitar);

      // B major requires a barre
      final bSuggestions = suggester.suggest([Chord.parse('B')]);
      final bNoCapo = bSuggestions.firstWhere((s) => s.capoFret == 0);

      // C major is open
      final cSuggestions = suggester.suggest([Chord.parse('C')]);
      final cNoCapo = cSuggestions.firstWhere((s) => s.capoFret == 0);

      expect(bNoCapo.difficultyScore, greaterThan(cNoCapo.difficultyScore));
    });
  });

  group('extension methods', () {
    test('List<Chord>.suggestCapo works', () {
      final chords = [Chord.parse('F'), Chord.parse('C')];
      final suggestions = chords.suggestCapo(guitar);

      expect(suggestions, isNotEmpty);
    });

    test('List<Chord>.bestCapoSuggestion works', () {
      final chords = [Chord.parse('F'), Chord.parse('C')];
      final best = chords.bestCapoSuggestion(guitar);

      expect(best, isNotNull);
    });

    test('ChordProgression.suggestCapo works', () {
      final prog = ChordProgression.parse('F Bb C');
      final suggestions = prog.suggestCapo(guitar);

      expect(suggestions, isNotEmpty);
    });

    test('ChordProgression.bestCapoSuggestion works', () {
      final prog = ChordProgression.parse('F Bb C');
      final best = prog.bestCapoSuggestion(guitar);

      expect(best, isNotNull);
    });
  });

  group('CommonCapoPositions', () {
    test('forChord returns positions for F major', () {
      final positions = CommonCapoPositions.forChord(Chord.parse('F'));

      expect(positions, contains(1)); // E shape
      expect(positions, contains(3)); // D shape
      expect(positions, contains(5)); // C shape
    });

    test('forChord returns positions for Bb major', () {
      final positions = CommonCapoPositions.forChord(Chord.parse('Bb'));

      expect(positions, contains(1)); // A shape
      expect(positions, contains(3)); // G shape
    });

    test('forChord returns positions for B major', () {
      final positions = CommonCapoPositions.forChord(Chord.parse('B'));

      expect(positions, contains(2)); // A shape
    });

    test('forChord returns [0] for easy chords', () {
      final positions = CommonCapoPositions.forChord(Chord.parse('C'));

      expect(positions, [0]);
    });

    test('forChord works for minor chords', () {
      final positions = CommonCapoPositions.forChord(Chord.parse('F#m'));

      // Should suggest positions to reach Am, Em, or Dm shapes
      expect(positions, isNotEmpty);
    });
  });

  group('real-world scenarios', () {
    test('F-Bb-C progression suggests capo 1 with E-A-B shapes or capo 3', () {
      final suggester = CapoSuggester(guitar);
      final suggestions = suggester.suggest([
        Chord.parse('F'),
        Chord.parse('Bb'),
        Chord.parse('C'),
      ]);

      // Capo 1: E, A, B (B is harder)
      // Capo 3: D, G, A (all easy)
      // Capo 5: C, F, G (F is moderate)

      final capo3 = suggestions.firstWhere((s) => s.capoFret == 3);
      expect(capo3.shapeSymbols, ['D', 'G', 'A']);
    });

    test('key of Bb suggests capo to play in key of A shapes', () {
      final suggester = CapoSuggester(guitar);
      final suggestions = suggester.suggest([
        Chord.parse('Bb'),
        Chord.parse('Eb'),
        Chord.parse('F'),
      ]);

      // With capo 1, these become A, D, E - all easy!
      final capo1 = suggestions.firstWhere((s) => s.capoFret == 1);
      expect(capo1.shapeSymbols, ['A', 'D', 'E']);
      expect(capo1.difficultyScore, 3.0); // 3 easy chords = 1.0 each
    });

    test('already easy chords suggest no capo as best', () {
      final suggester = CapoSuggester(guitar);
      final best = suggester.suggestBest([
        Chord.parse('G'),
        Chord.parse('C'),
        Chord.parse('D'),
        Chord.parse('Em'),
      ]);

      // These are already easy open chords
      expect(best!.capoFret, 0);
    });
  });
}
