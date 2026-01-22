import 'chord.dart';
import 'instrument.dart';
import 'pitch_class.dart';
import 'transposition.dart';

/// A suggestion for using a capo to simplify chord shapes.
class CapoSuggestion {
  /// The fret to place the capo on (0 = no capo).
  final int capoFret;

  /// The chord shapes to play with this capo position.
  ///
  /// These are the transposed chords that would be played as if they were
  /// the original chords (the capo handles the transposition).
  final List<Chord> shapes;

  /// The original chords this suggestion applies to.
  final List<Chord> originalChords;

  /// A difficulty score for this suggestion (lower is easier).
  final double difficultyScore;

  /// Creates a capo suggestion.
  const CapoSuggestion({
    required this.capoFret,
    required this.shapes,
    required this.originalChords,
    required this.difficultyScore,
  });

  /// Returns the shape symbols as a list of strings.
  List<String> get shapeSymbols => shapes.map((c) => c.symbol).toList();

  /// Returns a human-readable description of this suggestion.
  String get description {
    if (capoFret == 0) {
      return 'No capo needed';
    }
    return 'Capo fret $capoFret: play ${shapeSymbols.join(", ")}';
  }

  @override
  String toString() => description;
}

/// Suggests capo positions to simplify chord shapes.
///
/// The algorithm finds capo positions where the transposed chord shapes
/// are easier to play (typically open position chords).
class CapoSuggester {
  /// The instrument to suggest capo positions for.
  final Instrument instrument;

  /// Maximum capo fret to consider.
  final int maxCapoFret;

  /// Creates a capo suggester for the given instrument.
  CapoSuggester(
    this.instrument, {
    this.maxCapoFret = 12,
  });

  /// Suggests capo positions for a list of chords.
  ///
  /// Returns suggestions sorted by difficulty (easiest first).
  List<CapoSuggestion> suggest(List<Chord> chords) {
    if (chords.isEmpty) return [];

    final suggestions = <CapoSuggestion>[];

    // Try each capo position from 0 (no capo) to maxCapoFret
    for (var capo = 0; capo <= maxCapoFret; capo++) {
      // Transpose chords down by capo amount to get the shapes to play
      final shapes = chords.map((c) => c.transpose(-capo)).toList();

      // Calculate difficulty for these shapes
      final difficulty = _calculateDifficulty(shapes);

      suggestions.add(CapoSuggestion(
        capoFret: capo,
        shapes: shapes,
        originalChords: chords,
        difficultyScore: difficulty,
      ));
    }

    // Sort by difficulty (easiest first)
    suggestions.sort((a, b) => a.difficultyScore.compareTo(b.difficultyScore));

    return suggestions;
  }

  /// Suggests capo positions for a chord progression.
  List<CapoSuggestion> suggestForProgression(ChordProgression progression) {
    return suggest(progression.chords);
  }

  /// Returns the best (easiest) capo suggestion for the given chords.
  CapoSuggestion? suggestBest(List<Chord> chords) {
    final suggestions = suggest(chords);
    return suggestions.isNotEmpty ? suggestions.first : null;
  }

  /// Calculates the total difficulty score for a set of chord shapes.
  double _calculateDifficulty(List<Chord> shapes) {
    var total = 0.0;
    for (final shape in shapes) {
      total += _chordShapeDifficulty(shape);
    }
    return total;
  }

  /// Returns a difficulty score for a chord shape.
  ///
  /// Lower scores indicate easier chords. Open position chords like
  /// C, G, D, E, A, Am, Em, Dm are considered easier.
  double _chordShapeDifficulty(Chord chord) {
    final root = chord.root;
    final type = chord.type;

    // Check if this is a common open chord shape
    if (_isEasyOpenChord(root, type)) {
      return 1.0;
    }

    // Check if this is a moderately difficult open chord
    if (_isModerateOpenChord(root, type)) {
      return 2.0;
    }

    // Check if this is a simple barre chord (E or A shape)
    if (_isSimpleBarreChord(root, type)) {
      return 3.0;
    }

    // Other chords are considered more difficult
    return 4.0;
  }

  /// Checks if a chord is an easy open position chord.
  ///
  /// These are the "cowboy chords" that beginners learn first.
  bool _isEasyOpenChord(PitchClass root, ChordType type) {
    // Easy major chords: C, G, D, E, A
    if (type == ChordType.major) {
      return root == PitchClass.c ||
          root == PitchClass.g ||
          root == PitchClass.d ||
          root == PitchClass.e ||
          root == PitchClass.a;
    }

    // Easy minor chords: Am, Em, Dm
    if (type == ChordType.minor) {
      return root == PitchClass.a ||
          root == PitchClass.e ||
          root == PitchClass.d;
    }

    // Easy 7th chords: G7, C7, D7, E7, A7
    if (type == ChordType.dominant7) {
      return root == PitchClass.g ||
          root == PitchClass.c ||
          root == PitchClass.d ||
          root == PitchClass.e ||
          root == PitchClass.a;
    }

    // Easy minor 7th: Am7, Em7, Dm7
    if (type == ChordType.minor7) {
      return root == PitchClass.a ||
          root == PitchClass.e ||
          root == PitchClass.d;
    }

    return false;
  }

  /// Checks if a chord is a moderately difficult open chord.
  bool _isModerateOpenChord(PitchClass root, ChordType type) {
    // F major is playable in open position but requires partial barre
    if (type == ChordType.major && root == PitchClass.f) {
      return true;
    }

    // B7 is an open chord shape
    if (type == ChordType.dominant7 && root == PitchClass.b) {
      return true;
    }

    // Fmaj7 is relatively easy
    if (type == ChordType.major7 && root == PitchClass.f) {
      return true;
    }

    // Cmaj7, Dmaj7, Amaj7 are playable open shapes
    if (type == ChordType.major7) {
      return root == PitchClass.c ||
          root == PitchClass.d ||
          root == PitchClass.a;
    }

    return false;
  }

  /// Checks if a chord would be a simple barre chord shape.
  ///
  /// E-shape and A-shape barres are more manageable than others.
  bool _isSimpleBarreChord(PitchClass root, ChordType type) {
    // Any major or minor chord can be played as an E or A shape barre
    return type == ChordType.major || type == ChordType.minor;
  }
}

/// Extension methods for capo suggestions on chord lists.
extension ChordListCapoExtension on List<Chord> {
  /// Suggests capo positions for these chords.
  List<CapoSuggestion> suggestCapo(Instrument instrument) {
    return CapoSuggester(instrument).suggest(this);
  }

  /// Returns the best capo suggestion for these chords.
  CapoSuggestion? bestCapoSuggestion(Instrument instrument) {
    return CapoSuggester(instrument).suggestBest(this);
  }
}

/// Extension methods for capo suggestions on chord progressions.
extension ChordProgressionCapoExtension on ChordProgression {
  /// Suggests capo positions for this progression.
  List<CapoSuggestion> suggestCapo(Instrument instrument) {
    return CapoSuggester(instrument).suggestForProgression(this);
  }

  /// Returns the best capo suggestion for this progression.
  CapoSuggestion? bestCapoSuggestion(Instrument instrument) {
    return CapoSuggester(instrument).suggestBest(chords);
  }
}

/// Common capo positions for specific chord scenarios.
class CommonCapoPositions {
  CommonCapoPositions._();

  /// Common capo positions that turn difficult chords into easy ones.
  ///
  /// Format: {original chord root: {target shape root: capo fret}}
  static const Map<PitchClass, Map<PitchClass, int>> majorTransformations = {
    // F major -> E shape with capo 1, D shape with capo 3, C shape with capo 5
    PitchClass.f: {
      PitchClass.e: 1,
      PitchClass.d: 3,
      PitchClass.c: 5,
    },
    // Bb major -> A shape with capo 1, G shape with capo 3
    PitchClass.aSharp: {
      PitchClass.a: 1,
      PitchClass.g: 3,
    },
    // Eb major -> D shape with capo 1, C shape with capo 3
    PitchClass.dSharp: {
      PitchClass.d: 1,
      PitchClass.c: 3,
    },
    // Ab major -> G shape with capo 1
    PitchClass.gSharp: {
      PitchClass.g: 1,
    },
    // Db major -> C shape with capo 1
    PitchClass.cSharp: {
      PitchClass.c: 1,
    },
    // Gb/F# major -> E shape with capo 2
    PitchClass.fSharp: {
      PitchClass.e: 2,
    },
    // B major -> A shape with capo 2
    PitchClass.b: {
      PitchClass.a: 2,
    },
  };

  /// Returns capo positions that would turn the given chord into an easier shape.
  static List<int> forChord(Chord chord) {
    if (chord.type != ChordType.major) {
      // For non-major chords, calculate based on semitone distance
      return _calculateCapoPositions(chord);
    }

    final transformations = majorTransformations[chord.root];
    if (transformations == null) {
      // Already an easy chord
      return [0];
    }

    return transformations.values.toList()..sort();
  }

  /// Calculates capo positions based on semitone distance to easy chords.
  static List<int> _calculateCapoPositions(Chord chord) {
    final easyRoots = chord.type == ChordType.minor
        ? [PitchClass.a, PitchClass.e, PitchClass.d]
        : [
            PitchClass.c,
            PitchClass.g,
            PitchClass.d,
            PitchClass.e,
            PitchClass.a
          ];

    final positions = <int>[];
    for (final easyRoot in easyRoots) {
      // Calculate how many frets of capo to get from easyRoot to chord.root
      var semitones = chord.root.index - easyRoot.index;
      if (semitones < 0) semitones += 12;
      if (semitones > 0 && semitones <= 12) {
        positions.add(semitones);
      }
    }

    positions.sort();
    return positions;
  }
}
