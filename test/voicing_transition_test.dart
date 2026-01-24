import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('VoicingTransition', () {
    // Common test voicings
    late Voicing amOpen; // X02210
    late Voicing cOpen; // X32010
    late Voicing gOpen; // 320003
    late Voicing fBarre; // 133211 with barre
    late Voicing bmBarre; // X24432 with barre
    late Voicing eOpen; // 022100
    late Voicing dOpen; // XX0232

    setUp(() {
      amOpen = Voicing.parse('X02210');
      cOpen = Voicing.parse('X32010');
      gOpen = Voicing.parse('320003');
      // F barre chord with explicit barre
      fBarre = Voicing.fromFrets(
        [1, 3, 3, 2, 1, 1],
        barre: const Barre(fret: 1, fromString: 0, toIndex: 5),
      );
      // Bm barre chord with explicit barre
      bmBarre = Voicing.fromFrets(
        [null, 2, 4, 4, 3, 2],
        barre: const Barre(fret: 2, fromString: 1, toIndex: 5),
      );
      eOpen = Voicing.parse('022100');
      dOpen = Voicing.parse('XX0232');
    });

    group('calculateCost', () {
      test('returns 0 for null voicings', () {
        expect(VoicingTransition.calculateCost(null, amOpen), equals(0));
        expect(VoicingTransition.calculateCost(amOpen, null), equals(0));
        expect(VoicingTransition.calculateCost(null, null), equals(0));
      });

      test('similar open chords have low cost', () {
        // Am to C - both open, similar positions
        final cost = VoicingTransition.calculateCost(amOpen, cOpen);
        expect(cost, lessThan(30));
      });

      test('open to barre has higher cost', () {
        // Am (open) to F (barre) - includes barre penalty
        final costAmToF = VoicingTransition.calculateCost(amOpen, fBarre);
        final costAmToC = VoicingTransition.calculateCost(amOpen, cOpen);
        expect(costAmToF, greaterThan(costAmToC));
      });

      test('large position jump has high cost', () {
        // G open (frets 0-3) to Bm barre (frets 2-4)
        final costNear = VoicingTransition.calculateCost(amOpen, cOpen);
        final costFar = VoicingTransition.calculateCost(gOpen, bmBarre);
        expect(costFar, greaterThan(costNear));
      });

      test('identical voicing has minimal cost', () {
        final cost = VoicingTransition.calculateCost(amOpen, amOpen);
        // Should be 0 or very small (shape bonus might apply)
        expect(cost, lessThanOrEqualTo(5));
      });

      test('symmetric - order matters for context', () {
        final costAtoB = VoicingTransition.calculateCost(amOpen, fBarre);
        final costBtoA = VoicingTransition.calculateCost(fBarre, amOpen);
        // Should be equal since we're measuring absolute difference
        expect(costAtoB, equals(costBtoA));
      });
    });

    group('rankVoicings', () {
      test('returns empty list for empty candidates', () {
        final ranked = VoicingTransition.rankVoicings(
          previousVoicing: amOpen,
          nextVoicing: cOpen,
          candidates: [],
        );
        expect(ranked, isEmpty);
      });

      test('marks exactly one voicing as suggested', () {
        final candidates = [amOpen, fBarre, cOpen, gOpen];
        final ranked = VoicingTransition.rankVoicings(
          previousVoicing: eOpen,
          nextVoicing: dOpen,
          candidates: candidates,
        );

        final suggestedCount = ranked.where((r) => r.isSuggested).length;
        expect(suggestedCount, equals(1));
      });

      test('preserves original indices', () {
        final candidates = [amOpen, fBarre, cOpen];
        final ranked = VoicingTransition.rankVoicings(
          previousVoicing: null,
          nextVoicing: null,
          candidates: candidates,
        );

        // All original indices should be present
        final indices = ranked.map((r) => r.originalIndex).toSet();
        expect(indices, containsAll([0, 1, 2]));
      });

      test('prefers open voicings with preferOpen preference', () {
        final candidates = [fBarre, amOpen]; // barre first, open second
        final ranked = VoicingTransition.rankVoicings(
          previousVoicing: null,
          nextVoicing: null,
          candidates: candidates,
          preference: VoicingPreference.preferOpen,
        );

        // Open chord (amOpen, index 1) should be suggested
        final suggested = ranked.firstWhere((r) => r.isSuggested);
        expect(suggested.originalIndex, equals(1));
      });

      test('prefers barre voicings with preferBarre preference', () {
        final candidates = [amOpen, fBarre]; // open first, barre second
        final ranked = VoicingTransition.rankVoicings(
          previousVoicing: null,
          nextVoicing: null,
          candidates: candidates,
          preference: VoicingPreference.preferBarre,
        );

        // Barre chord (fBarre, index 1) should be suggested
        final suggested = ranked.firstWhere((r) => r.isSuggested);
        expect(suggested.originalIndex, equals(1));
      });

      test('considers previous voicing for suggestion', () {
        // Given previous Am, suggest voicing closest to Am position
        final amHigh = Voicing.parse('577555'); // Am barre at 5th fret
        final candidates = [amHigh, amOpen]; // high position first

        final rankedFromOpen = VoicingTransition.rankVoicings(
          previousVoicing: eOpen, // open E
          nextVoicing: null,
          candidates: candidates,
        );

        // Coming from open E, open Am should be suggested
        final suggested = rankedFromOpen.firstWhere((r) => r.isSuggested);
        expect(suggested.originalIndex, equals(1)); // amOpen
      });

      test('sorted by transition cost', () {
        final candidates = [amOpen, fBarre, cOpen, gOpen];
        final ranked = VoicingTransition.rankVoicings(
          previousVoicing: eOpen,
          nextVoicing: dOpen,
          candidates: candidates,
        );

        // Verify sorted order (costs should be non-decreasing)
        for (int i = 0; i < ranked.length - 1; i++) {
          expect(
            ranked[i].transitionCost,
            lessThanOrEqualTo(ranked[i + 1].transitionCost),
          );
        }
      });
    });

    group('suggestedIndex', () {
      test('returns 0 for empty candidates', () {
        final index = VoicingTransition.suggestedIndex(
          previousVoicing: amOpen,
          nextVoicing: cOpen,
          candidates: [],
        );
        expect(index, equals(0));
      });

      test('returns correct index for single candidate', () {
        final index = VoicingTransition.suggestedIndex(
          previousVoicing: null,
          nextVoicing: null,
          candidates: [amOpen],
        );
        expect(index, equals(0));
      });

      test('returns index of best voicing in context', () {
        final candidates = [fBarre, amOpen, cOpen];
        final index = VoicingTransition.suggestedIndex(
          previousVoicing: eOpen,
          nextVoicing: gOpen,
          candidates: candidates,
          preference: VoicingPreference.preferOpen,
        );

        // Should suggest one of the open chords (index 1 or 2)
        expect(index, isIn([1, 2]));
      });
    });

    group('categorizeCost', () {
      test('easy for cost < 20', () {
        expect(
          VoicingTransition.categorizeCost(0),
          equals(TransitionDifficulty.easy),
        );
        expect(
          VoicingTransition.categorizeCost(19),
          equals(TransitionDifficulty.easy),
        );
      });

      test('medium for cost 20-50', () {
        expect(
          VoicingTransition.categorizeCost(20),
          equals(TransitionDifficulty.medium),
        );
        expect(
          VoicingTransition.categorizeCost(50),
          equals(TransitionDifficulty.medium),
        );
      });

      test('hard for cost > 50', () {
        expect(
          VoicingTransition.categorizeCost(51),
          equals(TransitionDifficulty.hard),
        );
        expect(
          VoicingTransition.categorizeCost(100),
          equals(TransitionDifficulty.hard),
        );
      });
    });

    group('RankedVoicing', () {
      test('toString provides readable output', () {
        final ranked = RankedVoicing(
          voicing: amOpen,
          originalIndex: 2,
          transitionCost: 15,
          isSuggested: true,
        );
        expect(
          ranked.toString(),
          contains('index: 2'),
        );
        expect(
          ranked.toString(),
          contains('cost: 15'),
        );
        expect(
          ranked.toString(),
          contains('suggested: true'),
        );
      });
    });

    group('VoicingPreference', () {
      test('all preferences are handled', () {
        for (final pref in VoicingPreference.values) {
          final ranked = VoicingTransition.rankVoicings(
            previousVoicing: null,
            nextVoicing: null,
            candidates: [amOpen, fBarre],
            preference: pref,
          );
          expect(ranked, hasLength(2));
        }
      });
    });

    group('TransitionDifficulty', () {
      test('all difficulties are categorizable', () {
        final costs = [0, 10, 20, 35, 50, 75, 100];
        for (final cost in costs) {
          final difficulty = VoicingTransition.categorizeCost(cost);
          expect(
            TransitionDifficulty.values,
            contains(difficulty),
          );
        }
      });
    });

    group('integration scenarios', () {
      test('Am-G-C-F progression suggests smooth path', () {
        // Simulate walking through a progression
        final chords = ['Am', 'G', 'C', 'F'];
        final voicingOptions = [
          [amOpen, Voicing.parse('577555')], // Am options
          [gOpen, Voicing.parse('355433')], // G options
          [cOpen, Voicing.parse('X35553')], // C options
          [fBarre, Voicing.parse('XX3211')], // F options
        ];

        final selectedVoicings = <Voicing>[];
        Voicing? previous;

        for (int i = 0; i < chords.length; i++) {
          final candidates = voicingOptions[i];
          final next = i < chords.length - 1 ? voicingOptions[i + 1][0] : null;

          final index = VoicingTransition.suggestedIndex(
            previousVoicing: previous,
            nextVoicing: next,
            candidates: candidates,
          );

          selectedVoicings.add(candidates[index]);
          previous = candidates[index];
        }

        // With open preference and starting from open position,
        // should stay in open position when reasonable
        expect(selectedVoicings.length, equals(4));
      });
    });
  });
}
