import 'instrument.dart';
import 'voicing.dart';

/// Renders ASCII fretboard diagrams for chord voicings.
class FretboardDiagram {
  /// The instrument to render for.
  final Instrument instrument;

  /// Number of frets to show in the diagram.
  final int fretsToShow;

  /// Creates a fretboard diagram renderer.
  FretboardDiagram(this.instrument, {this.fretsToShow = 4});

  /// Renders a voicing as an ASCII fretboard diagram.
  ///
  /// Example output for Am (X02210):
  /// ```
  ///      Am
  ///   ╓───┬───┬───┐
  /// e ║ ○ │   │   │
  /// B ║ ● │   │   │  1
  /// G ║   │ ● │   │  2
  /// D ║   │ ● │   │  2
  /// A ║ ○ │   │   │
  /// E ║ x │   │   │
  ///   ╙───┴───┴───┘
  ///       1   2   3
  /// ```
  String render(Voicing voicing, {String? chordName}) {
    if (voicing.positions.length != instrument.stringCount) {
      throw ArgumentError(
        'Voicing has ${voicing.positions.length} positions but instrument has ${instrument.stringCount} strings',
      );
    }

    final buffer = StringBuffer();

    // Determine fret range to display
    final startFret = _calculateStartFret(voicing);
    final endFret = startFret + fretsToShow - 1;
    final showNut = startFret == 0;

    // Chord name header
    if (chordName != null) {
      final padding = ''.padLeft(3 + fretsToShow * 2);
      buffer.writeln('$padding$chordName');
    }

    // Get string names (reversed for display - high strings at top)
    final stringNames = _getStringNames();

    // Top border
    buffer.writeln(_renderTopBorder(showNut));

    // String rows (from high to low in display)
    for (var displayRow = instrument.stringCount - 1; displayRow >= 0; displayRow--) {
      final stringIndex = displayRow; // String index in voicing
      final pos = voicing.positions[stringIndex];
      final stringName = stringNames[stringIndex].padLeft(2);

      buffer.write(stringName);
      buffer.write(showNut ? ' ║' : ' │');

      for (var fret = startFret; fret <= endFret; fret++) {
        final cell = _renderCell(pos, fret, startFret);
        buffer.write(cell);
        buffer.write(fret < endFret ? '│' : '│');
      }

      // Show fret number if fretted
      if (pos.isFretted && pos.fret! >= startFret && pos.fret! <= endFret) {
        buffer.write('  ${pos.fret}');
      }

      buffer.writeln();
    }

    // Bottom border
    buffer.writeln(_renderBottomBorder(showNut));

    // Fret numbers
    buffer.writeln(_renderFretNumbers(startFret, endFret));

    return buffer.toString();
  }

  /// Renders multiple voicings side by side.
  String renderMultiple(List<Voicing> voicings, {List<String>? chordNames}) {
    if (voicings.isEmpty) return '';

    final diagrams = <List<String>>[];
    for (var i = 0; i < voicings.length; i++) {
      final name = chordNames != null && i < chordNames.length ? chordNames[i] : null;
      final diagram = render(voicings[i], chordName: name);
      diagrams.add(diagram.split('\n'));
    }

    // Find max lines
    final maxLines = diagrams.map((d) => d.length).reduce((a, b) => a > b ? a : b);

    // Combine side by side
    final buffer = StringBuffer();
    for (var line = 0; line < maxLines; line++) {
      for (var i = 0; i < diagrams.length; i++) {
        if (line < diagrams[i].length) {
          buffer.write(diagrams[i][line].padRight(20));
        } else {
          buffer.write(''.padRight(20));
        }
        if (i < diagrams.length - 1) buffer.write('  ');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Calculates the starting fret for display.
  int _calculateStartFret(Voicing voicing) {
    final lowest = voicing.lowestFret;
    if (lowest == null || lowest <= fretsToShow) {
      return 0; // Show from nut
    }
    return lowest - 1; // Show one fret before lowest
  }

  /// Gets string names from the instrument.
  List<String> _getStringNames() {
    return instrument.strings.map((s) => s.openNote.name).toList();
  }

  /// Renders the top border of the diagram.
  String _renderTopBorder(bool showNut) {
    final buffer = StringBuffer();
    buffer.write('   ');
    buffer.write(showNut ? '╓' : '┌');
    for (var i = 0; i < fretsToShow; i++) {
      buffer.write('───');
      buffer.write(i < fretsToShow - 1 ? '┬' : (showNut ? '┐' : '┐'));
    }
    return buffer.toString();
  }

  /// Renders the bottom border of the diagram.
  String _renderBottomBorder(bool showNut) {
    final buffer = StringBuffer();
    buffer.write('   ');
    buffer.write(showNut ? '╙' : '└');
    for (var i = 0; i < fretsToShow; i++) {
      buffer.write('───');
      buffer.write(i < fretsToShow - 1 ? '┴' : (showNut ? '┘' : '┘'));
    }
    return buffer.toString();
  }

  /// Renders a single cell in the fretboard.
  String _renderCell(StringPosition pos, int fret, int startFret) {
    if (pos.isMuted) {
      if (fret == startFret) return ' x ';
      return '   ';
    }

    if (pos.isOpen && fret == startFret) {
      return ' ○ ';
    }

    if (pos.isFretted && pos.fret == fret) {
      return ' ● ';
    }

    return '   ';
  }

  /// Renders the fret number labels.
  String _renderFretNumbers(int startFret, int endFret) {
    final buffer = StringBuffer();
    buffer.write('    ');
    for (var fret = startFret; fret <= endFret; fret++) {
      final label = fret == 0 ? ' ' : fret.toString();
      buffer.write(' ${label.padLeft(1)} ');
      if (fret < endFret) buffer.write(' ');
    }
    return buffer.toString();
  }
}

/// Renders a simple text-based voicing (no diagram).
String renderVoicingText(Voicing voicing, Instrument instrument, {String? chordName}) {
  final buffer = StringBuffer();

  if (chordName != null) {
    buffer.write('$chordName: ');
  }

  buffer.write(voicing.toCompactString());
  buffer.write(' (');

  final notes = <String>[];
  for (var i = 0; i < voicing.positions.length; i++) {
    final pos = voicing.positions[i];
    if (pos.isPlayed) {
      final note = instrument.soundingNoteAt(i, pos.fret!);
      notes.add(note.name);
    }
  }
  buffer.write(notes.join('-'));
  buffer.write(')');

  return buffer.toString();
}
