/// Example usage of the music_theory package.
///
/// This example demonstrates basic usage patterns for the music_theory library.
/// As features are implemented, this example will be expanded to show:
///
/// - Creating and manipulating notes
/// - Working with intervals
/// - Building and analyzing chords
/// - Transposing music
/// - Generating chord voicings for instruments
library;

// ignore_for_file: avoid_print, unused_import

import 'package:music_theory/music_theory.dart';

void main() {
  print('Music Theory Package - Example');
  print('==============================');
  print('');
  print('This package is currently a scaffold.');
  print('Features will be implemented in future releases.');
  print('');
  print('Planned features:');
  print('  - Notes and pitch classes');
  print('  - Intervals (major, minor, perfect, etc.)');
  print('  - Chords and chord types');
  print('  - Instruments and tunings');
  print('  - Transposition utilities');
  print('');

  // Future usage examples:
  //
  // final note = Note.parse('C#4');
  // final interval = Interval.majorThird;
  // final transposed = note.transpose(interval);
  // print('$note + $interval = $transposed');
  //
  // final chord = Chord.parse('Am7');
  // print('Notes in $chord: ${chord.notes}');
  //
  // final guitar = Instrument.guitar();
  // final voicings = guitar.voicings(chord);
  // for (final voicing in voicings) {
  //   print(voicing.diagram());
  // }
}
