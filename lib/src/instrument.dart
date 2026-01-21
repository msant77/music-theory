import 'pitch_class.dart';

/// Configuration for a single string on an instrument.
class StringConfig {
  /// The pitch class of the open (unfretted) string.
  final PitchClass openNote;

  /// The octave of the open string (e.g., E2 for low E on guitar).
  final int octave;

  /// Number of frets available on this string.
  final int fretCount;

  /// Creates a string configuration.
  ///
  /// [openNote] is the pitch class when unfretted.
  /// [octave] is the octave number (e.g., 2 for low E on guitar).
  /// [fretCount] defaults to 22 if not specified.
  const StringConfig({
    required this.openNote,
    required this.octave,
    this.fretCount = 22,
  });

  /// Creates a StringConfig by parsing a note string like "E2" or "G3".
  factory StringConfig.parse(String note, {int fretCount = 22}) {
    final match = RegExp(r'^([A-Ga-g][#b]?)(\d+)$').firstMatch(note);
    if (match == null) {
      throw FormatException('Invalid note format: "$note". Expected "E2", "G#3", etc.');
    }

    final pitchClass = PitchClass.parse(match.group(1)!);
    final octave = int.parse(match.group(2)!);

    return StringConfig(
      openNote: pitchClass,
      octave: octave,
      fretCount: fretCount,
    );
  }

  /// Returns the pitch class at a given fret position.
  PitchClass noteAtFret(int fret) {
    if (fret < 0 || fret > fretCount) {
      throw RangeError('Fret $fret is out of range [0, $fretCount]');
    }
    return openNote.transpose(fret);
  }

  @override
  String toString() => '${openNote.name}$octave';

  @override
  bool operator ==(Object other) =>
      other is StringConfig &&
      other.openNote == openNote &&
      other.octave == octave &&
      other.fretCount == fretCount;

  @override
  int get hashCode => Object.hash(openNote, octave, fretCount);
}

/// A stringed instrument with a specific tuning.
class Instrument {
  /// Display name of the instrument.
  final String name;

  /// Strings from lowest pitch to highest pitch.
  final List<StringConfig> strings;

  /// Creates an instrument with the given [name] and [strings].
  const Instrument({
    required this.name,
    required this.strings,
  });

  /// Number of strings on the instrument.
  int get stringCount => strings.length;

  /// Creates a copy with a different tuning.
  Instrument withTuning(List<StringConfig> newStrings) {
    if (newStrings.length != strings.length) {
      throw ArgumentError(
        'Tuning must have ${strings.length} strings, got ${newStrings.length}',
      );
    }
    return Instrument(name: name, strings: newStrings);
  }

  /// Parses a tuning string like "E2 A2 D3 G3 B3 E4" and applies it.
  Instrument withTuningFromString(String tuning) {
    final notes = tuning.trim().split(RegExp(r'\s+'));
    if (notes.length != strings.length) {
      throw ArgumentError(
        'Tuning must have ${strings.length} notes, got ${notes.length}',
      );
    }

    final newStrings = <StringConfig>[];
    for (var i = 0; i < notes.length; i++) {
      newStrings.add(StringConfig.parse(
        notes[i],
        fretCount: strings[i].fretCount,
      ));
    }

    return Instrument(name: name, strings: newStrings);
  }

  @override
  String toString() {
    final tuning = strings.map((s) => s.toString()).join(' ');
    return '$name ($tuning)';
  }

  @override
  bool operator ==(Object other) =>
      other is Instrument &&
      other.name == name &&
      _listEquals(other.strings, strings);

  @override
  int get hashCode => Object.hash(name, Object.hashAll(strings));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
