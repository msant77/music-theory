import 'chord.dart';
import 'pitch_class.dart';
import 'transposition.dart';

/// Result of key detection, with confidence score.
class KeyDetectionResult {
  /// The detected key.
  final Key key;

  /// Confidence score (0.0 to 1.0).
  final double confidence;

  /// Number of chords that fit this key.
  final int matchingChords;

  /// Total number of chords analyzed.
  final int totalChords;

  /// Creates a key detection result.
  const KeyDetectionResult({
    required this.key,
    required this.confidence,
    required this.matchingChords,
    required this.totalChords,
  });

  /// Whether this is a high-confidence result (>= 0.7).
  bool get isHighConfidence => confidence >= 0.7;

  /// Whether this is a medium-confidence result (>= 0.5).
  bool get isMediumConfidence => confidence >= 0.5;

  @override
  String toString() =>
      '${key.symbol} (${(confidence * 100).toStringAsFixed(0)}% confidence)';
}

/// Detects the musical key from a chord progression.
class KeyDetector {
  /// Creates a key detector.
  const KeyDetector();

  /// Detects the most likely key for a chord progression.
  ///
  /// Returns a list of possible keys sorted by confidence (highest first).
  /// The first result is the most likely key.
  List<KeyDetectionResult> detectKey(List<Chord> chords) {
    if (chords.isEmpty) return [];

    final results = <KeyDetectionResult>[];

    // Test all 24 possible keys (12 major + 12 minor)
    for (final tonic in PitchClass.values) {
      // Test major key
      final majorKey = Key.major(tonic);
      final majorScore = _scoreKey(majorKey, chords);
      results.add(majorScore);

      // Test minor key
      final minorKey = Key.minor(tonic);
      final minorScore = _scoreKey(minorKey, chords);
      results.add(minorScore);
    }

    // Sort by confidence (highest first)
    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    return results;
  }

  /// Detects the key from a chord progression object.
  List<KeyDetectionResult> detectKeyFromProgression(
      ChordProgression progression) {
    return detectKey(progression.chords);
  }

  /// Returns the most likely key, or null if no chords provided.
  KeyDetectionResult? detectBestKey(List<Chord> chords) {
    final results = detectKey(chords);
    return results.isNotEmpty ? results.first : null;
  }

  /// Returns the top N most likely keys.
  List<KeyDetectionResult> detectTopKeys(List<Chord> chords, {int limit = 3}) {
    final results = detectKey(chords);
    return results.take(limit).toList();
  }

  /// Scores how well a key fits the given chords.
  KeyDetectionResult _scoreKey(Key key, List<Chord> chords) {
    if (chords.isEmpty) {
      return KeyDetectionResult(
        key: key,
        confidence: 0.0,
        matchingChords: 0,
        totalChords: 0,
      );
    }

    var matchCount = 0;
    var totalScore = 0.0;

    final diatonicRoots = key.scale.toSet();
    final diatonicChords = key.diatonicChords;

    for (var i = 0; i < chords.length; i++) {
      final chord = chords[i];
      final isFirst = i == 0;
      final chordScore = _scoreChordInKey(
          chord, key, diatonicRoots, diatonicChords,
          isFirst: isFirst);
      totalScore += chordScore;
      if (chordScore > 0.5) matchCount++;
    }

    // Normalize score (don't clamp to allow relative comparison)
    final confidence = totalScore / chords.length;

    return KeyDetectionResult(
      key: key,
      confidence: confidence,
      matchingChords: matchCount,
      totalChords: chords.length,
    );
  }

  /// Scores how well a single chord fits in a key.
  double _scoreChordInKey(
    Chord chord,
    Key key,
    Set<PitchClass> diatonicRoots,
    List<Chord> diatonicChords, {
    bool isFirst = false,
  }) {
    var score = 0.0;

    // Check if the chord root is in the key's scale
    if (diatonicRoots.contains(chord.root)) {
      score += 0.5;
    }

    // Check if it's a diatonic chord (same root and quality)
    for (final diatonic in diatonicChords) {
      if (diatonic.root == chord.root) {
        if (_isCompatibleType(chord.type, diatonic.type)) {
          score += 0.5;
        }
        break;
      }
    }

    // Bonus for tonic chord (I or i)
    final isTonic = chord.root == key.tonic &&
        ((key.isMajor && chord.type == ChordType.major) ||
            (!key.isMajor && chord.type == ChordType.minor));
    if (isTonic) {
      score += 0.2;
      // Extra bonus if the first chord is the tonic - progressions usually start on I
      if (isFirst) {
        score += 0.3;
      }
    }

    // Bonus for dominant chord (V)
    final dominantRoot = key.tonic.transpose(7);
    if (chord.root == dominantRoot && chord.type == ChordType.major) {
      score += 0.15;
    }

    // Bonus for dominant 7th
    if (chord.root == dominantRoot && chord.type == ChordType.dominant7) {
      score += 0.2;
    }

    // Bonus for subdominant (IV or iv)
    final subdominantRoot = key.tonic.transpose(5);
    if (chord.root == subdominantRoot) {
      score += 0.1;
    }

    return score;
  }

  /// Checks if two chord types are compatible (e.g., major and major7).
  bool _isCompatibleType(ChordType actual, ChordType expected) {
    if (actual == expected) return true;

    // Major variations
    if (expected == ChordType.major) {
      return actual == ChordType.major7 ||
          actual == ChordType.dominant7 ||
          actual == ChordType.major6 ||
          actual == ChordType.add9 ||
          actual == ChordType.sus2 ||
          actual == ChordType.sus4;
    }

    // Minor variations
    if (expected == ChordType.minor) {
      return actual == ChordType.minor7 ||
          actual == ChordType.minor6 ||
          actual == ChordType.minorAdd9 ||
          actual == ChordType.minorMajor7;
    }

    // Diminished variations
    if (expected == ChordType.diminished) {
      return actual == ChordType.diminished7 ||
          actual == ChordType.halfDiminished7;
    }

    return false;
  }
}

/// Extension methods for key detection on chord lists.
extension ChordListKeyDetectionExtension on List<Chord> {
  /// Detects the most likely key for these chords.
  KeyDetectionResult? detectKey() {
    return const KeyDetector().detectBestKey(this);
  }

  /// Detects possible keys for these chords.
  List<KeyDetectionResult> detectPossibleKeys({int limit = 3}) {
    return const KeyDetector().detectTopKeys(this, limit: limit);
  }
}

/// Extension methods for key detection on chord progressions.
extension ChordProgressionKeyDetectionExtension on ChordProgression {
  /// Detects the most likely key for this progression.
  KeyDetectionResult? detectKey() {
    return const KeyDetector().detectBestKey(chords);
  }

  /// Detects possible keys for this progression.
  List<KeyDetectionResult> detectPossibleKeys({int limit = 3}) {
    return const KeyDetector().detectTopKeys(chords, limit: limit);
  }
}

/// Roman numeral representation of a chord in a key.
class RomanNumeral {
  /// The Roman numeral string (e.g., "I", "ii", "V7").
  final String numeral;

  /// The scale degree (1-7).
  final int degree;

  /// Whether this is a major chord (uppercase numeral).
  final bool isMajor;

  /// The chord this represents.
  final Chord chord;

  /// The key context.
  final Key key;

  /// Whether this chord is diatonic to the key.
  final bool isDiatonic;

  /// Creates a Roman numeral analysis.
  const RomanNumeral({
    required this.numeral,
    required this.degree,
    required this.isMajor,
    required this.chord,
    required this.key,
    required this.isDiatonic,
  });

  /// The function name (e.g., "tonic", "dominant", "subdominant").
  String get functionName {
    if (!isDiatonic) return 'non-diatonic';

    return switch (degree) {
      1 => 'tonic',
      2 => key.isMajor ? 'supertonic' : 'supertonic',
      3 => key.isMajor ? 'mediant' : 'mediant',
      4 => 'subdominant',
      5 => 'dominant',
      6 => key.isMajor ? 'submediant' : 'submediant',
      7 => key.isMajor ? 'leading tone' : 'subtonic',
      _ => 'unknown',
    };
  }

  @override
  String toString() => numeral;
}

/// Analyzes chords in terms of Roman numerals within a key.
class RomanNumeralAnalyzer {
  /// Creates a Roman numeral analyzer.
  const RomanNumeralAnalyzer();

  /// Analyzes a chord in the context of a key.
  RomanNumeral analyze(Chord chord, Key key) {
    // Find the scale degree
    final degree = _findDegree(chord.root, key);

    // Determine if it's diatonic
    final diatonicChords = key.diatonicChords;
    final isDiatonic = degree != null &&
        degree >= 1 &&
        degree <= 7 &&
        _isCompatibleWithDiatonic(chord, diatonicChords[degree - 1]);

    // Build the numeral string
    final numeral = _buildNumeral(chord, key, degree, isDiatonic);

    return RomanNumeral(
      numeral: numeral,
      degree: degree ?? 0,
      isMajor: chord.type == ChordType.major ||
          chord.type == ChordType.major7 ||
          chord.type == ChordType.dominant7 ||
          chord.type == ChordType.augmented,
      chord: chord,
      key: key,
      isDiatonic: isDiatonic,
    );
  }

  /// Analyzes a list of chords in a key.
  List<RomanNumeral> analyzeProgression(List<Chord> chords, Key key) {
    return chords.map((c) => analyze(c, key)).toList();
  }

  /// Analyzes a chord progression in a key.
  List<RomanNumeral> analyzeChordProgression(
      ChordProgression progression, Key key) {
    return analyzeProgression(progression.chords, key);
  }

  /// Finds the scale degree of a pitch class in a key (1-7, or null if not in scale).
  int? _findDegree(PitchClass root, Key key) {
    final scale = key.scale;
    for (var i = 0; i < scale.length; i++) {
      if (scale[i] == root) {
        return i + 1;
      }
    }

    // Check for chromatic alterations
    for (var i = 0; i < scale.length; i++) {
      final distance = (root.index - scale[i].index).abs();
      if (distance == 1 || distance == 11) {
        return i + 1; // Chromatic alteration of this degree
      }
    }

    return null;
  }

  /// Checks if a chord is compatible with the expected diatonic chord.
  bool _isCompatibleWithDiatonic(Chord chord, Chord diatonic) {
    if (chord.root != diatonic.root) return false;

    // Same type
    if (chord.type == diatonic.type) return true;

    // Extended versions of the same basic quality
    if (diatonic.type == ChordType.major) {
      return chord.type == ChordType.major7 ||
          chord.type == ChordType.dominant7 ||
          chord.type == ChordType.major6 ||
          chord.type == ChordType.add9;
    }

    if (diatonic.type == ChordType.minor) {
      return chord.type == ChordType.minor7 ||
          chord.type == ChordType.minor6 ||
          chord.type == ChordType.minorAdd9;
    }

    if (diatonic.type == ChordType.diminished) {
      return chord.type == ChordType.diminished7 ||
          chord.type == ChordType.halfDiminished7;
    }

    return false;
  }

  /// Builds the Roman numeral string for a chord.
  String _buildNumeral(Chord chord, Key key, int? degree, bool isDiatonic) {
    if (degree == null) {
      // Non-diatonic - use the chord symbol with a question mark
      return '?${chord.symbol}';
    }

    // Base numeral
    final baseNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'];
    var numeral = baseNumerals[degree - 1];

    // Check if it's the expected quality for this degree
    final expectedChord = key.diatonicChords[degree - 1];
    final isExpectedMajor = expectedChord.type == ChordType.major;
    final isActualMajor = chord.type == ChordType.major ||
        chord.type == ChordType.major7 ||
        chord.type == ChordType.dominant7 ||
        chord.type == ChordType.augmented;

    // Determine case and alterations
    if (!isDiatonic) {
      // Chromatic chord - check for raised/lowered
      final expectedRoot = key.scale[degree - 1];
      final actualRoot = chord.root;
      final diff = (actualRoot.index - expectedRoot.index + 12) % 12;

      if (diff == 1) {
        numeral = '#$numeral';
      } else if (diff == 11) {
        numeral = 'b$numeral';
      }
    }

    // Apply case based on chord quality
    if (!isActualMajor) {
      numeral = numeral.toLowerCase();
    }

    // Add quality suffixes
    final suffix =
        _getQualitySuffix(chord.type, isExpectedMajor, isActualMajor);
    numeral += suffix;

    return numeral;
  }

  /// Gets the suffix for chord quality.
  String _getQualitySuffix(
      ChordType type, bool expectedMajor, bool actualMajor) {
    return switch (type) {
      ChordType.major => '',
      ChordType.minor => '',
      ChordType.diminished => '°',
      ChordType.augmented => '+',
      ChordType.dominant7 => '7',
      ChordType.major7 => 'maj7',
      ChordType.minor7 => '7',
      ChordType.diminished7 => '°7',
      ChordType.halfDiminished7 => 'ø7',
      ChordType.sus2 => 'sus2',
      ChordType.sus4 => 'sus4',
      ChordType.add9 => 'add9',
      ChordType.major6 => '6',
      ChordType.minor6 => '6',
      _ => '',
    };
  }
}

/// Extension methods for Roman numeral analysis.
extension ChordRomanNumeralExtension on Chord {
  /// Analyzes this chord in the context of a key.
  RomanNumeral inKey(Key key) {
    return const RomanNumeralAnalyzer().analyze(this, key);
  }
}

/// Extension methods for Roman numeral analysis on chord lists.
extension ChordListRomanNumeralExtension on List<Chord> {
  /// Analyzes these chords in the context of a key.
  List<RomanNumeral> inKey(Key key) {
    return const RomanNumeralAnalyzer().analyzeProgression(this, key);
  }
}

/// Extension methods for Roman numeral analysis on progressions.
extension ChordProgressionRomanNumeralExtension on ChordProgression {
  /// Analyzes this progression in the context of a key.
  List<RomanNumeral> inKey(Key key) {
    return const RomanNumeralAnalyzer().analyzeChordProgression(this, key);
  }
}

/// Common chord progression patterns.
class ProgressionPatterns {
  ProgressionPatterns._();

  /// Recognizes common progression patterns and returns their names.
  static List<String> recognize(List<RomanNumeral> numerals) {
    if (numerals.isEmpty) return [];

    final patterns = <String>[];
    final sequence = numerals.map((n) => _normalizeNumeral(n.numeral)).toList();

    // Check for known patterns
    for (final entry in _knownPatterns.entries) {
      if (_matchesPattern(sequence, entry.value)) {
        patterns.add(entry.key);
      }
    }

    return patterns;
  }

  /// Known progression patterns.
  static const Map<String, List<String>> _knownPatterns = {
    '50s progression (I-vi-IV-V)': ['I', 'vi', 'IV', 'V'],
    'Pop progression (I-V-vi-IV)': ['I', 'V', 'vi', 'IV'],
    'Axis progression (vi-IV-I-V)': ['vi', 'IV', 'I', 'V'],
    'Pachelbel progression (I-V-vi-iii-IV-I-IV-V)': [
      'I',
      'V',
      'vi',
      'iii',
      'IV',
      'I',
      'IV',
      'V'
    ],
    '12-bar blues': [
      'I',
      'I',
      'I',
      'I',
      'IV',
      'IV',
      'I',
      'I',
      'V',
      'IV',
      'I',
      'V'
    ],
    'ii-V-I (jazz)': ['ii', 'V', 'I'],
    'I-IV-V (three chord)': ['I', 'IV', 'V'],
    'I-V (two chord)': ['I', 'V'],
    'Andalusian cadence (i-VII-VI-V)': ['i', 'VII', 'VI', 'V'],
    'Circle of fifths segment': ['vi', 'ii', 'V', 'I'],
  };

  /// Normalizes a numeral for pattern matching.
  static String _normalizeNumeral(String numeral) {
    // Remove extensions and alterations for basic matching
    var normalized = numeral
        .replaceAll('7', '')
        .replaceAll('maj', '')
        .replaceAll('°', '')
        .replaceAll('ø', '')
        .replaceAll('+', '')
        .replaceAll('sus2', '')
        .replaceAll('sus4', '')
        .replaceAll('add9', '')
        .replaceAll('6', '');

    // Handle sharps and flats
    if (normalized.startsWith('#') || normalized.startsWith('b')) {
      normalized = normalized.substring(1);
    }

    return normalized;
  }

  /// Checks if a sequence matches a pattern (allowing for repetition).
  static bool _matchesPattern(List<String> sequence, List<String> pattern) {
    if (sequence.length < pattern.length) return false;

    // Check if sequence starts with pattern
    for (var i = 0; i <= sequence.length - pattern.length; i++) {
      var matches = true;
      for (var j = 0; j < pattern.length; j++) {
        if (sequence[i + j].toUpperCase() != pattern[j].toUpperCase()) {
          matches = false;
          break;
        }
      }
      if (matches) return true;
    }

    return false;
  }
}

/// Complete analysis result for a chord progression.
class ProgressionAnalysis {
  /// The detected key (most likely).
  final KeyDetectionResult? detectedKey;

  /// Alternative key possibilities.
  final List<KeyDetectionResult> alternativeKeys;

  /// Roman numeral analysis in the detected key.
  final List<RomanNumeral> romanNumerals;

  /// Recognized progression patterns.
  final List<String> patterns;

  /// The original chords.
  final List<Chord> chords;

  /// Creates a progression analysis.
  const ProgressionAnalysis({
    required this.detectedKey,
    required this.alternativeKeys,
    required this.romanNumerals,
    required this.patterns,
    required this.chords,
  });

  /// Whether a key was detected.
  bool get hasKey => detectedKey != null;

  /// Whether any patterns were recognized.
  bool get hasPatterns => patterns.isNotEmpty;
}

/// Performs complete analysis of a chord progression.
class ProgressionAnalyzer {
  /// Creates a progression analyzer.
  const ProgressionAnalyzer();

  /// Analyzes a chord progression completely.
  ProgressionAnalysis analyze(List<Chord> chords) {
    if (chords.isEmpty) {
      return const ProgressionAnalysis(
        detectedKey: null,
        alternativeKeys: [],
        romanNumerals: [],
        patterns: [],
        chords: [],
      );
    }

    // Detect key
    final keyResults = const KeyDetector().detectTopKeys(chords);
    final bestKey = keyResults.isNotEmpty ? keyResults.first : null;
    final alternatives =
        keyResults.length > 1 ? keyResults.sublist(1) : <KeyDetectionResult>[];

    // Analyze Roman numerals in the best key
    List<RomanNumeral> numerals = [];
    if (bestKey != null) {
      numerals =
          const RomanNumeralAnalyzer().analyzeProgression(chords, bestKey.key);
    }

    // Recognize patterns
    final patterns = ProgressionPatterns.recognize(numerals);

    return ProgressionAnalysis(
      detectedKey: bestKey,
      alternativeKeys: alternatives,
      romanNumerals: numerals,
      patterns: patterns,
      chords: chords,
    );
  }

  /// Analyzes a chord progression object.
  ProgressionAnalysis analyzeProgression(ChordProgression progression) {
    return analyze(progression.chords);
  }
}

/// Extension for complete progression analysis.
extension ChordProgressionAnalysisExtension on ChordProgression {
  /// Performs complete analysis of this progression.
  ProgressionAnalysis analyze() {
    return const ProgressionAnalyzer().analyze(chords);
  }
}

/// Extension for complete progression analysis on chord lists.
extension ChordListAnalysisExtension on List<Chord> {
  /// Performs complete analysis of these chords.
  ProgressionAnalysis analyze() {
    return const ProgressionAnalyzer().analyze(this);
  }
}
