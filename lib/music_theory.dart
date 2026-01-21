/// Music theory library for notes, intervals, chords, and instruments.
///
/// This library provides a foundation for working with music theory concepts
/// in Dart applications. It includes support for:
///
/// - Notes and pitch classes
/// - Intervals (major, minor, perfect, augmented, diminished)
/// - Chords and chord voicings
/// - Instruments and tunings
/// - Transposition
///
/// ## Usage
///
/// ```dart
/// import 'package:music_theory/music_theory.dart';
///
/// // Use preset instruments (seed data)
/// final guitar = Instruments.guitar;
/// print(guitar); // Guitar (E2 A2 D3 G3 B3 E4)
///
/// // Apply a preset tuning
/// final dropD = Tunings.guitar.dropD.applyTo(guitar);
///
/// // Create your own instrument
/// final mandolin = Instrument(
///   name: 'Mandolin',
///   strings: [
///     StringConfig(openNote: PitchClass.g, octave: 3),
///     StringConfig(openNote: PitchClass.d, octave: 4),
///     StringConfig(openNote: PitchClass.a, octave: 4),
///     StringConfig(openNote: PitchClass.e, octave: 5),
///   ],
/// );
///
/// // Or parse a custom tuning
/// final openC = Tuning.parse('Open C', 'C2 G2 C3 G3 C4 E4');
///
/// // Get note at a fret position
/// final lowE = guitar.strings[0];
/// print(lowE.noteAtFret(5)); // A
///
/// // Browse available tunings
/// for (final tuning in Tunings.guitar.all) {
///   print(tuning); // Standard (E2 A2 D3 G3 B3 E4), etc.
/// }
/// ```
library music_theory;

export 'src/pitch_class.dart';
export 'src/instrument.dart';
export 'src/tuning.dart';
export 'src/presets.dart';
