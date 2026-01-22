import 'dart:convert';
import 'dart:io';

import '../fretboard_diagram.dart';
import '../instrument.dart';
import '../pitch_class.dart';
import '../presets.dart';
import '../tuning.dart';

/// Configuration for the music_theory CLI.
///
/// Stores the user's instrument setup including instrument type,
/// tuning, and capo position. Persists to `~/.config/music_theory/config.json`.
class MusicTheoryConfig {
  /// The instrument name (e.g., "guitar", "bass", or custom name).
  final String instrument;

  /// The tuning name if using a preset (e.g., "standard", "dropD").
  final String? tuningName;

  /// Custom tuning notes (e.g., "D2 A2 D3 G3 B3 E4" or "DADGBE").
  final String? tuningNotes;

  /// Capo position (0 = no capo).
  final int capo;

  /// Whether this is a fully custom instrument (not a preset).
  final bool isCustom;

  /// Fret counts for custom instruments.
  /// Can be a single value (uniform) or per-string values.
  /// Null means use default (22 frets).
  final List<int>? frets;

  /// Diagram orientation preference.
  final DiagramOrientation diagramOrientation;

  /// Creates a configuration with the given settings.
  const MusicTheoryConfig({
    required this.instrument,
    this.tuningName,
    this.tuningNotes,
    this.capo = 0,
    this.isCustom = false,
    this.frets,
    this.diagramOrientation = DiagramOrientation.vertical,
  });

  /// Default configuration: guitar with standard tuning, no capo.
  static const MusicTheoryConfig defaultConfig = MusicTheoryConfig(
    instrument: 'guitar',
    tuningName: 'standard',
  );

  /// Creates a config from JSON map.
  factory MusicTheoryConfig.fromJson(Map<String, dynamic> json) {
    final fretsJson = json['frets'];
    List<int>? frets;
    if (fretsJson is List) {
      frets = fretsJson.cast<int>();
    }

    final orientationStr = json['diagramOrientation'] as String?;
    final orientation = orientationStr == 'horizontal'
        ? DiagramOrientation.horizontal
        : DiagramOrientation.vertical;

    return MusicTheoryConfig(
      instrument: json['instrument'] as String? ?? 'guitar',
      tuningName: json['tuningName'] as String?,
      tuningNotes: json['tuningNotes'] as String?,
      capo: json['capo'] as int? ?? 0,
      isCustom: json['isCustom'] as bool? ?? false,
      frets: frets,
      diagramOrientation: orientation,
    );
  }

  /// Converts config to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'instrument': instrument,
      if (tuningName != null) 'tuningName': tuningName,
      if (tuningNotes != null) 'tuningNotes': tuningNotes,
      'capo': capo,
      if (isCustom) 'isCustom': true,
      if (frets != null) 'frets': frets,
      if (diagramOrientation != DiagramOrientation.vertical)
        'diagramOrientation': diagramOrientation.name,
    };
  }

  /// Returns the default config file path.
  static String get defaultConfigPath {
    final home = Platform.environment['HOME'] ?? '.';
    return '$home/.config/music_theory/config.json';
  }

  /// Loads config from the default path, or returns default config if not found.
  static Future<MusicTheoryConfig> load() async {
    return loadFrom(defaultConfigPath);
  }

  /// Loads config from a specific path, or returns default config if not found.
  static Future<MusicTheoryConfig> loadFrom(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return defaultConfig;
    }
    try {
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return MusicTheoryConfig.fromJson(json);
    } catch (e) {
      return defaultConfig;
    }
  }

  /// Saves config to the default path.
  Future<void> save() async {
    await saveTo(defaultConfigPath);
  }

  /// Saves config to a specific path.
  Future<void> saveTo(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final json = const JsonEncoder.withIndent('  ').convert(toJson());
    await file.writeAsString('$json\n');
  }

  /// Resolves this config to an [Instrument] object.
  ///
  /// Throws [ArgumentError] if the instrument or tuning is invalid.
  Instrument toInstrument() {
    if (isCustom) {
      return _buildCustomInstrument();
    }

    // Find the base instrument from presets
    final baseInstrument = _findInstrument(instrument);
    if (baseInstrument == null) {
      throw ArgumentError('Unknown instrument: $instrument');
    }

    // Apply tuning if specified
    Instrument result = baseInstrument;
    if (tuningNotes != null) {
      // Custom tuning from notes string
      final normalizedNotes = normalizeTuningString(tuningNotes!);
      final tuning = Tuning.parse('Custom', normalizedNotes);
      result = tuning.applyTo(result);
    } else if (tuningName != null) {
      // Preset tuning by name
      final tuning = _findTuning(instrument, tuningName!);
      if (tuning == null) {
        throw ArgumentError(
          'Unknown tuning "$tuningName" for instrument "$instrument"',
        );
      }
      result = tuning.applyTo(result);
    }

    // Apply capo
    if (capo > 0) {
      result = result.withCapo(capo);
    }

    return result;
  }

  /// Builds a fully custom instrument from config.
  Instrument _buildCustomInstrument() {
    if (tuningNotes == null) {
      throw ArgumentError('Custom instrument requires tuning notes');
    }

    final normalizedNotes = normalizeTuningString(tuningNotes!);
    final noteStrings = normalizedNotes.split(' ');
    final stringCount = noteStrings.length;

    // Determine fret counts
    List<int> fretCounts;
    if (frets == null || frets!.isEmpty) {
      fretCounts = List.filled(stringCount, 22);
    } else if (frets!.length == 1) {
      fretCounts = List.filled(stringCount, frets!.first);
    } else if (frets!.length == stringCount) {
      fretCounts = frets!;
    } else {
      throw ArgumentError(
        'Fret count (${frets!.length}) must be 1 or match string count ($stringCount)',
      );
    }

    // Build string configs
    final strings = <StringConfig>[];
    for (var i = 0; i < stringCount; i++) {
      strings.add(StringConfig.parse(noteStrings[i], fretCount: fretCounts[i]));
    }

    var result = Instrument(name: instrument, strings: strings);

    // Apply capo
    if (capo > 0) {
      result = result.withCapo(capo);
    }

    return result;
  }

  /// Creates a copy with updated values.
  MusicTheoryConfig copyWith({
    String? instrument,
    String? tuningName,
    String? tuningNotes,
    int? capo,
    bool? isCustom,
    List<int>? frets,
    DiagramOrientation? diagramOrientation,
    bool clearTuningName = false,
    bool clearTuningNotes = false,
    bool clearFrets = false,
  }) {
    return MusicTheoryConfig(
      instrument: instrument ?? this.instrument,
      tuningName: clearTuningName ? null : (tuningName ?? this.tuningName),
      tuningNotes: clearTuningNotes ? null : (tuningNotes ?? this.tuningNotes),
      capo: capo ?? this.capo,
      isCustom: isCustom ?? this.isCustom,
      frets: clearFrets ? null : (frets ?? this.frets),
      diagramOrientation: diagramOrientation ?? this.diagramOrientation,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer(instrument);
    if (isCustom) {
      buffer.write(' (custom)');
    }
    if (tuningNotes != null) {
      buffer.write(' tuning: $tuningNotes');
    } else if (tuningName != null) {
      buffer.write(' $tuningName');
    }
    if (frets != null && frets!.isNotEmpty) {
      if (frets!.length == 1 || frets!.toSet().length == 1) {
        buffer.write(' ${frets!.first} frets');
      } else {
        buffer.write(' frets: ${frets!.join(",")}');
      }
    }
    if (capo > 0) {
      buffer.write(' capo $capo');
    }
    if (diagramOrientation != DiagramOrientation.vertical) {
      buffer.write(' ${diagramOrientation.name} diagrams');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is MusicTheoryConfig &&
      other.instrument == instrument &&
      other.tuningName == tuningName &&
      other.tuningNotes == tuningNotes &&
      other.capo == capo &&
      other.isCustom == isCustom &&
      _listEquals(other.frets, frets) &&
      other.diagramOrientation == diagramOrientation;

  @override
  int get hashCode => Object.hash(
        instrument,
        tuningName,
        tuningNotes,
        capo,
        isCustom,
        frets != null ? Object.hashAll(frets!) : null,
        diagramOrientation,
      );
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Finds an instrument by name (case-insensitive).
Instrument? _findInstrument(String name) {
  final lower = name.toLowerCase();
  for (final inst in Instruments.all) {
    if (inst.name.toLowerCase() == lower) {
      return inst;
    }
  }
  // Handle aliases
  switch (lower) {
    case 'guitar7':
    case '7string':
    case '7-string':
      return Instruments.guitar7String;
    default:
      return null;
  }
}

/// Finds a tuning by name for a given instrument.
Tuning? _findTuning(String instrumentName, String tuningName) {
  final lower = tuningName.toLowerCase();
  final tunings = _getTuningsForInstrument(instrumentName);
  if (tunings == null) return null;

  for (final tuning in tunings) {
    if (tuning.name.toLowerCase() == lower) {
      return tuning;
    }
  }
  // Handle common aliases
  switch (lower) {
    case 'dropd':
    case 'drop-d':
    case 'drop_d':
      return tunings.firstWhere(
        (t) => t.name.toLowerCase() == 'drop d',
        orElse: () => tunings.first,
      );
    case 'openg':
    case 'open-g':
    case 'open_g':
      return tunings.firstWhere(
        (t) => t.name.toLowerCase() == 'open g',
        orElse: () => tunings.first,
      );
    case 'opend':
    case 'open-d':
    case 'open_d':
      return tunings.firstWhere(
        (t) => t.name.toLowerCase() == 'open d',
        orElse: () => tunings.first,
      );
    default:
      return null;
  }
}

/// Returns the list of tunings available for an instrument.
List<Tuning>? _getTuningsForInstrument(String instrumentName) {
  switch (instrumentName.toLowerCase()) {
    case 'guitar':
      return Tunings.guitar.all;
    case 'bass':
      return Tunings.bass.all;
    case 'ukulele':
      return Tunings.ukulele.all;
    case 'cavaquinho':
      return Tunings.cavaquinho.all;
    case 'banjo':
      return Tunings.banjo.all;
    case 'guitar7string':
    case 'guitar7':
    case '7string':
    case '7-string':
      return Tunings.guitar7String.all;
    default:
      return null;
  }
}

/// Returns a list of available instrument names.
List<String> getAvailableInstruments() {
  return Instruments.all.map((i) => i.name.toLowerCase()).toList();
}

/// Returns a list of available tuning names for an instrument.
List<String> getAvailableTunings(String instrumentName) {
  final tunings = _getTuningsForInstrument(instrumentName);
  if (tunings == null) return [];
  return tunings.map((t) => t.name).toList();
}

/// Normalizes a tuning string to space-separated notes with octaves.
///
/// Accepts formats:
/// - "B1 E2 A2 D3 G3 B3 E4" (already normalized)
/// - "B1E2A2D3G3B3E4" (concatenated with octaves)
/// - "BEADGBE" (without octaves - infers from position)
///
/// Returns space-separated notes with octaves (e.g., "B1 E2 A2 D3 G3 B3 E4").
String normalizeTuningString(String input) {
  final trimmed = input.trim();

  // Already space-separated?
  if (trimmed.contains(' ')) {
    return trimmed;
  }

  // Try to parse as concatenated notes with octaves (e.g., "B1E2A2D3G3B3E4")
  final withOctaves = _parseConcatenatedWithOctaves(trimmed);
  if (withOctaves != null) {
    return withOctaves;
  }

  // Parse as notes without octaves (e.g., "BEADGBE")
  return _parseNotesWithoutOctaves(trimmed);
}

/// Parses concatenated notes with octaves like "B1E2A2D3G3B3E4".
String? _parseConcatenatedWithOctaves(String input) {
  // Pattern: note letter, optional sharp/flat, digit
  final pattern = RegExp(r'([A-Ga-g][#b]?)(\d)');
  final matches = pattern.allMatches(input);

  if (matches.isEmpty) return null;

  // Verify the matches cover the entire string
  final reconstructed = matches.map((m) => m.group(0)).join();
  if (reconstructed.toLowerCase() != input.toLowerCase()) {
    return null;
  }

  return matches.map((m) {
    final note = m.group(1)!;
    // Uppercase only the letter, preserve the accidental (# or b)
    final normalized = note[0].toUpperCase() + (note.length > 1 ? note[1] : '');
    return '$normalized${m.group(2)}';
  }).join(' ');
}

/// Parses notes without octaves like "BEADGBE" and infers octaves.
///
/// Uses standard instrument conventions:
/// - Starts at octave 1-2 for bass notes
/// - Increases octave when note wraps around (e.g., G -> B stays same, B -> E goes up)
String _parseNotesWithoutOctaves(String input) {
  final notes = <String>[];
  var i = 0;

  while (i < input.length) {
    final char = input[i].toUpperCase();
    if (!RegExp(r'[A-G]').hasMatch(char)) {
      throw FormatException('Invalid note character: ${input[i]}');
    }

    var note = char;
    // Check for sharp or flat
    if (i + 1 < input.length) {
      final next = input[i + 1];
      if (next == '#' || next == 'b') {
        note += next;
        i++;
      }
    }
    notes.add(note);
    i++;
  }

  if (notes.isEmpty) {
    throw FormatException('No notes found in tuning: $input');
  }

  // Infer octaves based on typical instrument tuning patterns
  return _inferOctaves(notes);
}

/// Infers octaves for a list of note names.
///
/// Assumes lowest string is bass range and increases appropriately.
String _inferOctaves(List<String> notes) {
  final result = <String>[];

  // Determine starting octave based on string count
  // More strings typically means lower starting octave
  int octave;
  if (notes.length >= 7) {
    octave = 1; // 7+ string instruments start at B1
  } else if (notes.length >= 5) {
    octave = 2; // Guitar/banjo start around E2
  } else {
    octave = 3; // Ukulele/cavaquinho start higher
  }

  int? lastSemitone;

  for (final note in notes) {
    final pitchClass = PitchClass.parse(note);
    final semitone = pitchClass.index;

    // If this note is lower than the last, we've wrapped - increase octave
    if (lastSemitone != null && semitone <= lastSemitone) {
      octave++;
    }

    result.add('$note$octave');
    lastSemitone = semitone;
  }

  return result.join(' ');
}

/// Parses a frets string into a list of integers.
///
/// Accepts:
/// - "22" -> [22]
/// - "22,22,22,22,5" -> [22, 22, 22, 22, 5]
List<int> parseFrets(String input) {
  final trimmed = input.trim();

  if (trimmed.contains(',')) {
    return trimmed.split(',').map((s) => int.parse(s.trim())).toList();
  }

  return [int.parse(trimmed)];
}
