import 'instrument.dart';
import 'voicing.dart';

/// Orientation for fretboard diagrams.
enum DiagramOrientation {
  /// Vertical: nut at top, strings as columns (traditional chord diagram).
  vertical,

  /// Horizontal: strings as rows, frets as columns.
  horizontal,
}

/// Renders ASCII fretboard diagrams for chord voicings.
class FretboardDiagram {
  /// The instrument to render for.
  final Instrument instrument;

  /// Number of frets to show in the diagram.
  final int fretsToShow;

  /// Diagram orientation.
  final DiagramOrientation orientation;

  /// Creates a fretboard diagram renderer.
  FretboardDiagram(
    this.instrument, {
    this.fretsToShow = 4,
    this.orientation = DiagramOrientation.vertical,
  });

  /// Renders a voicing as an ASCII fretboard diagram.
  String render(Voicing voicing, {String? chordName}) {
    if (voicing.positions.length != instrument.stringCount) {
      throw ArgumentError(
        'Voicing has ${voicing.positions.length} positions but instrument has ${instrument.stringCount} strings',
      );
    }

    return switch (orientation) {
      DiagramOrientation.vertical => _renderVertical(voicing, chordName),
      DiagramOrientation.horizontal => _renderHorizontal(voicing, chordName),
    };
  }

  /// Renders vertical diagram (traditional chord chart style).
  ///
  /// Example output for Am (X02210):
  /// ```
  ///        Am
  ///    E A D G B E
  ///    ╒═╤═╤═╤═╤═╕
  ///    │ │ │ │ ● │
  ///    ├─┼─┼─┼─┼─┤
  ///    │ │ ● ● │ │
  ///    ├─┼─┼─┼─┼─┤
  ///    │ │ │ │ │ │
  ///    └─┴─┴─┴─┴─┘
  ///    x     ○   ○
  /// ```
  String _renderVertical(Voicing voicing, String? chordName) {
    final buffer = StringBuffer();
    final stringCount = instrument.stringCount;
    final stringNames = _getStringNames();

    final startFret = _calculateStartFret(voicing);
    final endFret = startFret + fretsToShow - 1;
    final showNut = startFret == 0;

    // Calculate width for centering
    final diagramWidth = stringCount * 2 + 1;

    // Chord name
    if (chordName != null) {
      final padding = (diagramWidth - chordName.length) ~/ 2 + 3;
      buffer.writeln('${' ' * padding}$chordName');
    }

    // String names header
    buffer.write('   ');
    for (var i = 0; i < stringCount; i++) {
      buffer.write(' ${stringNames[i]}');
    }
    buffer.writeln();

    // Nut or top border
    buffer.write('   ');
    if (showNut) {
      buffer.write('╒');
      for (var i = 0; i < stringCount - 1; i++) {
        buffer.write('═╤');
      }
      buffer.writeln('═╕');
    } else {
      buffer.write('┌');
      for (var i = 0; i < stringCount - 1; i++) {
        buffer.write('─┬');
      }
      buffer.writeln('─┐');
    }

    // Fret rows
    for (var fret = startFret == 0 ? 1 : startFret; fret <= endFret; fret++) {
      // Fret content row
      buffer.write('   ');
      buffer.write('│');
      for (var s = 0; s < stringCount; s++) {
        final pos = voicing.positions[s];
        if (pos.isFretted && pos.fret == fret) {
          buffer.write('●');
        } else {
          buffer.write(' ');
        }
        buffer.write('│');
      }

      // Fret number on the right
      if (fret > 0) {
        buffer.write(' $fret');
      }
      buffer.writeln();

      // Fret separator (except after last fret)
      if (fret < endFret) {
        buffer.write('   ');
        buffer.write('├');
        for (var i = 0; i < stringCount - 1; i++) {
          buffer.write('─┼');
        }
        buffer.writeln('─┤');
      }
    }

    // Bottom border
    buffer.write('   ');
    buffer.write('└');
    for (var i = 0; i < stringCount - 1; i++) {
      buffer.write('─┴');
    }
    buffer.writeln('─┘');

    // Open/muted indicators at bottom
    buffer.write('   ');
    for (var s = 0; s < stringCount; s++) {
      final pos = voicing.positions[s];
      if (pos.isMuted) {
        buffer.write(' x');
      } else if (pos.isOpen) {
        buffer.write(' ○');
      } else {
        buffer.write('  ');
      }
    }
    buffer.writeln();

    return buffer.toString();
  }

  /// Renders horizontal diagram (strings as rows).
  String _renderHorizontal(Voicing voicing, String? chordName) {
    final buffer = StringBuffer();

    final startFret = _calculateStartFret(voicing);
    final endFret = startFret + fretsToShow - 1;
    final showNut = startFret == 0;
    final stringNames = _getStringNames();

    // Chord name header
    if (chordName != null) {
      final padding = ''.padLeft(3 + fretsToShow * 2);
      buffer.writeln('$padding$chordName');
    }

    // Top border
    buffer.write('   ');
    buffer.write(showNut ? '╓' : '┌');
    for (var i = 0; i < fretsToShow; i++) {
      buffer.write('───');
      buffer.write(i < fretsToShow - 1 ? '┬' : '┐');
    }
    buffer.writeln();

    // String rows (from high to low in display)
    for (var displayRow = instrument.stringCount - 1;
        displayRow >= 0;
        displayRow--) {
      final pos = voicing.positions[displayRow];
      final stringName = stringNames[displayRow].padLeft(2);

      buffer.write(stringName);
      buffer.write(showNut ? ' ║' : ' │');

      for (var fret = startFret; fret <= endFret; fret++) {
        if (pos.isMuted && fret == startFret) {
          buffer.write(' x ');
        } else if (pos.isOpen && fret == startFret) {
          buffer.write(' ○ ');
        } else if (pos.isFretted && pos.fret == fret) {
          buffer.write(' ● ');
        } else {
          buffer.write('   ');
        }
        buffer.write('│');
      }

      if (pos.isFretted && pos.fret! >= startFret && pos.fret! <= endFret) {
        buffer.write('  ${pos.fret}');
      }
      buffer.writeln();
    }

    // Bottom border
    buffer.write('   ');
    buffer.write(showNut ? '╙' : '└');
    for (var i = 0; i < fretsToShow; i++) {
      buffer.write('───');
      buffer.write(i < fretsToShow - 1 ? '┴' : '┘');
    }
    buffer.writeln();

    // Fret numbers
    buffer.write('    ');
    for (var fret = startFret; fret <= endFret; fret++) {
      final label = fret == 0 ? ' ' : fret.toString();
      buffer.write(' ${label.padLeft(1)} ');
      if (fret < endFret) buffer.write(' ');
    }
    buffer.writeln();

    return buffer.toString();
  }

  /// Renders multiple voicings side by side.
  String renderMultiple(List<Voicing> voicings, {List<String>? chordNames}) {
    if (voicings.isEmpty) return '';

    final diagrams = <List<String>>[];
    for (var i = 0; i < voicings.length; i++) {
      final name =
          chordNames != null && i < chordNames.length ? chordNames[i] : null;
      final diagram = render(voicings[i], chordName: name);
      diagrams.add(diagram.split('\n'));
    }

    final maxLines =
        diagrams.map((d) => d.length).reduce((a, b) => a > b ? a : b);

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
      return 0;
    }
    return lowest - 1;
  }

  /// Gets string names from the instrument.
  List<String> _getStringNames() {
    return instrument.strings.map((s) => s.openNote.name).toList();
  }
}

/// Renders a simple text-based voicing (no diagram).
String renderVoicingText(Voicing voicing, Instrument instrument,
    {String? chordName}) {
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
