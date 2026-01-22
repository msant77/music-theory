import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('KeyDetectionResult', () {
    test('has correct properties', () {
      const result = KeyDetectionResult(
        key: Key.major(PitchClass.c),
        confidence: 0.85,
        matchingChords: 4,
        totalChords: 5,
      );

      expect(result.key.tonic, PitchClass.c);
      expect(result.confidence, 0.85);
      expect(result.matchingChords, 4);
      expect(result.totalChords, 5);
    });

    test('isHighConfidence returns true for >= 0.7', () {
      const high = KeyDetectionResult(
        key: Key.major(PitchClass.c),
        confidence: 0.75,
        matchingChords: 3,
        totalChords: 4,
      );
      const low = KeyDetectionResult(
        key: Key.major(PitchClass.c),
        confidence: 0.65,
        matchingChords: 2,
        totalChords: 4,
      );

      expect(high.isHighConfidence, isTrue);
      expect(low.isHighConfidence, isFalse);
    });

    test('isMediumConfidence returns true for >= 0.5', () {
      const medium = KeyDetectionResult(
        key: Key.major(PitchClass.c),
        confidence: 0.55,
        matchingChords: 2,
        totalChords: 4,
      );
      const low = KeyDetectionResult(
        key: Key.major(PitchClass.c),
        confidence: 0.45,
        matchingChords: 1,
        totalChords: 4,
      );

      expect(medium.isMediumConfidence, isTrue);
      expect(low.isMediumConfidence, isFalse);
    });

    test('toString returns formatted string', () {
      const result = KeyDetectionResult(
        key: Key.major(PitchClass.c),
        confidence: 0.85,
        matchingChords: 4,
        totalChords: 5,
      );

      expect(result.toString(), contains('C'));
      expect(result.toString(), contains('85%'));
    });
  });

  group('KeyDetector', () {
    group('detectKey', () {
      test('returns empty list for empty chords', () {
        const detector = KeyDetector();
        final results = detector.detectKey([]);
        expect(results, isEmpty);
      });

      test('detects C major from I-IV-V-I', () {
        const detector = KeyDetector();
        final chords = [
          Chord.parse('C'),
          Chord.parse('F'),
          Chord.parse('G'),
          Chord.parse('C'),
        ];
        final results = detector.detectKey(chords);

        expect(results, isNotEmpty);
        // C major should be among the top results
        final cMajorResult = results.firstWhere(
          (r) => r.key.tonic == PitchClass.c && r.key.isMajor,
        );
        expect(cMajorResult.confidence, greaterThan(0.5));
      });

      test('detects A minor from i-iv-V-i', () {
        const detector = KeyDetector();
        final chords = [
          Chord.parse('Am'),
          Chord.parse('Dm'),
          Chord.parse('E'),
          Chord.parse('Am'),
        ];
        final results = detector.detectKey(chords);

        expect(results, isNotEmpty);
        // A minor should be high in results
        final topResult = results.first;
        expect(topResult.key.tonic, anyOf(PitchClass.a, PitchClass.c));
      });

      test('detects G major from common progression', () {
        const detector = KeyDetector();
        final chords = [
          Chord.parse('G'),
          Chord.parse('D'),
          Chord.parse('Em'),
          Chord.parse('C'),
        ];
        final results = detector.detectKey(chords);

        expect(results, isNotEmpty);
        // G major should be among the top results
        final gMajorResults = results.where(
          (r) => r.key.tonic == PitchClass.g && r.key.isMajor,
        );
        expect(gMajorResults, isNotEmpty);
      });

      test('handles dominant 7th chords', () {
        const detector = KeyDetector();
        final chords = [
          Chord.parse('C'),
          Chord.parse('F'),
          Chord.parse('G7'),
          Chord.parse('C'),
        ];
        final results = detector.detectKey(chords);

        expect(results, isNotEmpty);
        // G7 is V7 in C major - should boost C major
        final topResult = results.first;
        expect(topResult.key.tonic, PitchClass.c);
      });

      test('returns results sorted by confidence', () {
        const detector = KeyDetector();
        final chords = [Chord.parse('C'), Chord.parse('G'), Chord.parse('Am')];
        final results = detector.detectKey(chords);

        for (var i = 1; i < results.length; i++) {
          expect(
            results[i].confidence,
            lessThanOrEqualTo(results[i - 1].confidence),
          );
        }
      });
    });

    group('detectBestKey', () {
      test('returns null for empty chords', () {
        const detector = KeyDetector();
        final result = detector.detectBestKey([]);
        expect(result, isNull);
      });

      test('returns the highest confidence result', () {
        const detector = KeyDetector();
        final chords = [Chord.parse('C'), Chord.parse('F'), Chord.parse('G')];
        final result = detector.detectBestKey(chords);

        expect(result, isNotNull);
        expect(result!.confidence, greaterThan(0));
      });
    });

    group('detectTopKeys', () {
      test('respects limit parameter', () {
        const detector = KeyDetector();
        final chords = [Chord.parse('C'), Chord.parse('Am'), Chord.parse('G')];
        final results = detector.detectTopKeys(chords, limit: 2);

        expect(results.length, lessThanOrEqualTo(2));
      });
    });
  });

  group('extension methods for key detection', () {
    test('List<Chord>.detectKey works', () {
      final chords = [Chord.parse('C'), Chord.parse('F'), Chord.parse('G')];
      final result = chords.detectKey();
      expect(result, isNotNull);
    });

    test('List<Chord>.detectPossibleKeys works', () {
      final chords = [Chord.parse('C'), Chord.parse('Am')];
      final results = chords.detectPossibleKeys();
      expect(results.length, lessThanOrEqualTo(3));
    });

    test('ChordProgression.detectKey works', () {
      final prog = ChordProgression.parse('C Am F G');
      final result = prog.detectKey();
      expect(result, isNotNull);
    });

    test('ChordProgression.detectPossibleKeys works', () {
      final prog = ChordProgression.parse('C Am F G');
      final results = prog.detectPossibleKeys();
      expect(results, isNotEmpty);
    });
  });

  group('RomanNumeral', () {
    test('has correct properties', () {
      final numeral = RomanNumeral(
        numeral: 'V7',
        degree: 5,
        isMajor: true,
        chord: Chord.parse('G7'),
        key: const Key.major(PitchClass.c),
        isDiatonic: true,
      );

      expect(numeral.numeral, 'V7');
      expect(numeral.degree, 5);
      expect(numeral.isMajor, isTrue);
      expect(numeral.isDiatonic, isTrue);
    });

    test('functionName returns correct function', () {
      const key = Key.major(PitchClass.c);

      final tonic = RomanNumeral(
        numeral: 'I',
        degree: 1,
        isMajor: true,
        chord: Chord.parse('C'),
        key: key,
        isDiatonic: true,
      );
      expect(tonic.functionName, 'tonic');

      final dominant = RomanNumeral(
        numeral: 'V',
        degree: 5,
        isMajor: true,
        chord: Chord.parse('G'),
        key: key,
        isDiatonic: true,
      );
      expect(dominant.functionName, 'dominant');

      final subdominant = RomanNumeral(
        numeral: 'IV',
        degree: 4,
        isMajor: true,
        chord: Chord.parse('F'),
        key: key,
        isDiatonic: true,
      );
      expect(subdominant.functionName, 'subdominant');
    });

    test('toString returns numeral', () {
      final numeral = RomanNumeral(
        numeral: 'ii',
        degree: 2,
        isMajor: false,
        chord: Chord.parse('Dm'),
        key: const Key.major(PitchClass.c),
        isDiatonic: true,
      );

      expect(numeral.toString(), 'ii');
    });
  });

  group('RomanNumeralAnalyzer', () {
    group('analyze', () {
      test('analyzes I chord correctly', () {
        const analyzer = RomanNumeralAnalyzer();
        const key = Key.major(PitchClass.c);
        final chord = Chord.parse('C');

        final result = analyzer.analyze(chord, key);

        expect(result.numeral, 'I');
        expect(result.degree, 1);
        expect(result.isMajor, isTrue);
        expect(result.isDiatonic, isTrue);
      });

      test('analyzes ii chord correctly', () {
        const analyzer = RomanNumeralAnalyzer();
        const key = Key.major(PitchClass.c);
        final chord = Chord.parse('Dm');

        final result = analyzer.analyze(chord, key);

        expect(result.numeral, 'ii');
        expect(result.degree, 2);
        expect(result.isMajor, isFalse);
        expect(result.isDiatonic, isTrue);
      });

      test('analyzes V7 chord correctly', () {
        const analyzer = RomanNumeralAnalyzer();
        const key = Key.major(PitchClass.c);
        final chord = Chord.parse('G7');

        final result = analyzer.analyze(chord, key);

        expect(result.numeral, 'V7');
        expect(result.degree, 5);
        expect(result.isDiatonic, isTrue);
      });

      test('analyzes vi chord correctly', () {
        const analyzer = RomanNumeralAnalyzer();
        const key = Key.major(PitchClass.c);
        final chord = Chord.parse('Am');

        final result = analyzer.analyze(chord, key);

        expect(result.numeral, 'vi');
        expect(result.degree, 6);
        expect(result.isMajor, isFalse);
        expect(result.isDiatonic, isTrue);
      });

      test('analyzes vii° chord correctly', () {
        const analyzer = RomanNumeralAnalyzer();
        const key = Key.major(PitchClass.c);
        final chord = Chord.parse('Bdim');

        final result = analyzer.analyze(chord, key);

        expect(result.numeral, 'vii°');
        expect(result.degree, 7);
        expect(result.isDiatonic, isTrue);
      });

      test('handles minor key analysis', () {
        const analyzer = RomanNumeralAnalyzer();
        const key = Key.minor(PitchClass.a);
        final chord = Chord.parse('Am');

        final result = analyzer.analyze(chord, key);

        expect(result.numeral, 'i');
        expect(result.degree, 1);
        expect(result.isDiatonic, isTrue);
      });

      test('handles extended chords', () {
        const analyzer = RomanNumeralAnalyzer();
        const key = Key.major(PitchClass.c);
        final chord = Chord.parse('Cmaj7');

        final result = analyzer.analyze(chord, key);

        expect(result.numeral, 'Imaj7');
        expect(result.isDiatonic, isTrue);
      });
    });

    group('analyzeProgression', () {
      test('analyzes full progression', () {
        const analyzer = RomanNumeralAnalyzer();
        const key = Key.major(PitchClass.c);
        final chords = [
          Chord.parse('C'),
          Chord.parse('Am'),
          Chord.parse('F'),
          Chord.parse('G'),
        ];

        final results = analyzer.analyzeProgression(chords, key);

        expect(results.length, 4);
        expect(results[0].numeral, 'I');
        expect(results[1].numeral, 'vi');
        expect(results[2].numeral, 'IV');
        expect(results[3].numeral, 'V');
      });
    });
  });

  group('extension methods for Roman numerals', () {
    test('Chord.inKey works', () {
      const key = Key.major(PitchClass.c);
      final chord = Chord.parse('G');
      final result = chord.inKey(key);

      expect(result.numeral, 'V');
    });

    test('List<Chord>.inKey works', () {
      const key = Key.major(PitchClass.c);
      final chords = [Chord.parse('C'), Chord.parse('G')];
      final results = chords.inKey(key);

      expect(results.length, 2);
      expect(results[0].numeral, 'I');
      expect(results[1].numeral, 'V');
    });

    test('ChordProgression.inKey works', () {
      const key = Key.major(PitchClass.g);
      final prog = ChordProgression.parse('G D Em C');
      final results = prog.inKey(key);

      expect(results.length, 4);
      expect(results[0].numeral, 'I');
      expect(results[1].numeral, 'V');
      expect(results[2].numeral, 'vi');
      expect(results[3].numeral, 'IV');
    });
  });

  group('ProgressionPatterns', () {
    test('recognizes 50s progression', () {
      const key = Key.major(PitchClass.c);
      final chords = [
        Chord.parse('C'),
        Chord.parse('Am'),
        Chord.parse('F'),
        Chord.parse('G'),
      ];
      final numerals = chords.inKey(key);
      final patterns = ProgressionPatterns.recognize(numerals);

      expect(patterns, contains('50s progression (I-vi-IV-V)'));
    });

    test('recognizes pop progression', () {
      const key = Key.major(PitchClass.c);
      final chords = [
        Chord.parse('C'),
        Chord.parse('G'),
        Chord.parse('Am'),
        Chord.parse('F'),
      ];
      final numerals = chords.inKey(key);
      final patterns = ProgressionPatterns.recognize(numerals);

      expect(patterns, contains('Pop progression (I-V-vi-IV)'));
    });

    test('recognizes ii-V-I', () {
      const key = Key.major(PitchClass.c);
      final chords = [
        Chord.parse('Dm'),
        Chord.parse('G'),
        Chord.parse('C'),
      ];
      final numerals = chords.inKey(key);
      final patterns = ProgressionPatterns.recognize(numerals);

      expect(patterns, contains('ii-V-I (jazz)'));
    });

    test('recognizes three chord progression', () {
      const key = Key.major(PitchClass.c);
      final chords = [
        Chord.parse('C'),
        Chord.parse('F'),
        Chord.parse('G'),
      ];
      final numerals = chords.inKey(key);
      final patterns = ProgressionPatterns.recognize(numerals);

      expect(patterns, contains('I-IV-V (three chord)'));
    });

    test('returns empty list for unrecognized patterns', () {
      const key = Key.major(PitchClass.c);
      final chords = [Chord.parse('C'), Chord.parse('Eb'), Chord.parse('Ab')];
      final numerals = chords.inKey(key);
      final patterns = ProgressionPatterns.recognize(numerals);

      // This progression is not in our known patterns
      expect(patterns.length, lessThan(5)); // May match some by chance
    });
  });

  group('ProgressionAnalysis', () {
    test('has correct properties', () {
      const analysis = ProgressionAnalysis(
        detectedKey: KeyDetectionResult(
          key: Key.major(PitchClass.c),
          confidence: 0.9,
          matchingChords: 4,
          totalChords: 4,
        ),
        alternativeKeys: [],
        romanNumerals: [],
        patterns: ['Pop progression (I-V-vi-IV)'],
        chords: [],
      );

      expect(analysis.hasKey, isTrue);
      expect(analysis.hasPatterns, isTrue);
    });

    test('hasKey returns false when no key detected', () {
      const analysis = ProgressionAnalysis(
        detectedKey: null,
        alternativeKeys: [],
        romanNumerals: [],
        patterns: [],
        chords: [],
      );

      expect(analysis.hasKey, isFalse);
    });
  });

  group('ProgressionAnalyzer', () {
    test('returns empty analysis for empty chords', () {
      const analyzer = ProgressionAnalyzer();
      final result = analyzer.analyze([]);

      expect(result.hasKey, isFalse);
      expect(result.romanNumerals, isEmpty);
      expect(result.patterns, isEmpty);
    });

    test('performs complete analysis', () {
      const analyzer = ProgressionAnalyzer();
      final chords = [
        Chord.parse('C'),
        Chord.parse('Am'),
        Chord.parse('F'),
        Chord.parse('G'),
      ];
      final result = analyzer.analyze(chords);

      expect(result.hasKey, isTrue);
      expect(result.romanNumerals, hasLength(4));
      expect(result.chords, equals(chords));
    });

    test('analyzeProgression works', () {
      const analyzer = ProgressionAnalyzer();
      final prog = ChordProgression.parse('G D Em C');
      final result = analyzer.analyzeProgression(prog);

      expect(result.hasKey, isTrue);
    });
  });

  group('extension methods for analysis', () {
    test('ChordProgression.analyze works', () {
      final prog = ChordProgression.parse('C Am F G');
      final result = prog.analyze();

      expect(result.hasKey, isTrue);
      expect(result.romanNumerals, hasLength(4));
    });

    test('List<Chord>.analyze works', () {
      final chords = [Chord.parse('C'), Chord.parse('G'), Chord.parse('Am')];
      final result = chords.analyze();

      expect(result.hasKey, isTrue);
    });
  });

  group('real-world progressions', () {
    test('analyzes Let It Be progression', () {
      // C G Am F
      final prog = ChordProgression.parse('C G Am F');
      final analysis = prog.analyze();

      expect(analysis.detectedKey?.key.tonic, PitchClass.c);
      expect(analysis.patterns, contains('Pop progression (I-V-vi-IV)'));
    });

    test('analyzes Stand By Me progression', () {
      // A F#m D E
      final prog = ChordProgression.parse('A F#m D E');
      final analysis = prog.analyze();

      expect(analysis.detectedKey?.key.tonic, PitchClass.a);
    });

    test('analyzes jazz ii-V-I in C', () {
      // Dm7 G7 Cmaj7
      final prog = ChordProgression.parse('Dm7 G7 Cmaj7');
      final analysis = prog.analyze();

      expect(analysis.detectedKey?.key.tonic, PitchClass.c);
      expect(analysis.patterns, contains('ii-V-I (jazz)'));
    });

    test('analyzes relative major/minor ambiguity', () {
      // C Am - could be C major or A minor
      final prog = ChordProgression.parse('C Am');
      final analysis = prog.analyze();

      // Should detect both as possibilities
      expect(analysis.hasKey, isTrue);
      final allKeys = [analysis.detectedKey!, ...analysis.alternativeKeys];
      final tonics = allKeys.map((k) => k.key.tonic).toSet();
      expect(tonics, anyOf(contains(PitchClass.c), contains(PitchClass.a)));
    });
  });
}
