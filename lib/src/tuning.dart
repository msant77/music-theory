import 'instrument.dart';

/// A named tuning configuration for a stringed instrument.
///
/// Tunings define the open notes for each string. Use the [Tuning] constructor
/// or [Tuning.parse] factory to create custom tunings.
///
/// For preset tunings, see [Tunings] in `presets.dart`.
class Tuning {
  /// Display name of the tuning.
  final String name;

  /// String configurations from lowest to highest pitch.
  final List<StringConfig> strings;

  /// Creates a tuning with the given [name] and [strings].
  const Tuning({
    required this.name,
    required this.strings,
  });

  /// Number of strings in this tuning.
  int get stringCount => strings.length;

  /// Parses a tuning from a space-separated string of notes.
  ///
  /// Example: `Tuning.parse('Drop D', 'D2 A2 D3 G3 B3 E4')`
  factory Tuning.parse(String name, String notes, {int fretCount = 22}) {
    final noteList = notes.trim().split(RegExp(r'\s+'));
    final strings = noteList
        .map((n) => StringConfig.parse(n, fretCount: fretCount))
        .toList();
    return Tuning(name: name, strings: strings);
  }

  /// Applies this tuning to an instrument.
  ///
  /// Throws [ArgumentError] if string counts don't match.
  Instrument applyTo(Instrument instrument) {
    if (strings.length != instrument.stringCount) {
      throw ArgumentError(
        'Tuning has ${strings.length} strings, '
        'but ${instrument.name} has ${instrument.stringCount}',
      );
    }
    return instrument.withTuning(strings);
  }

  @override
  String toString() {
    final notes = strings.map((s) => s.toString()).join(' ');
    return '$name ($notes)';
  }

  @override
  bool operator ==(Object other) =>
      other is Tuning &&
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
