import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  late Instrument guitar;

  setUp(() {
    guitar = Instruments.guitar;
  });

  group('FretboardDiagram', () {
    group('render', () {
      test('renders open position chord', () {
        final diagram = FretboardDiagram(guitar);
        final voicing = Voicing.parse('X02210'); // Am
        final result = diagram.render(voicing);

        expect(result, contains('○')); // Open strings
        expect(result, contains('●')); // Fretted notes
        expect(result, contains('x')); // Muted string
      });

      test('renders chord name when provided', () {
        final diagram = FretboardDiagram(guitar);
        final voicing = Voicing.parse('X02210');
        final result = diagram.render(voicing, chordName: 'Am');

        expect(result, contains('Am'));
      });

      test('renders fret numbers on the side', () {
        final diagram = FretboardDiagram(guitar);
        final voicing = Voicing.parse('X02210');
        final result = diagram.render(voicing);

        expect(result, contains('1')); // Fret 1
        expect(result, contains('2')); // Fret 2
      });

      test('renders string names', () {
        final diagram = FretboardDiagram(guitar);
        final voicing = Voicing.parse('X02210');
        final result = diagram.render(voicing);

        expect(result, contains('E')); // E strings
        expect(result, contains('A'));
        expect(result, contains('D'));
        expect(result, contains('G'));
        expect(result, contains('B'));
      });

      test('shows nut for open position chords', () {
        final diagram = FretboardDiagram(guitar);
        final voicing = Voicing.parse('022100'); // E major
        final result = diagram.render(voicing);

        // Nut is shown with ╓ and ╙
        expect(result, contains('╓'));
        expect(result, contains('╙'));
      });

      test('does not show nut for higher position chords', () {
        final diagram = FretboardDiagram(guitar);
        final voicing = Voicing.parse('X-5-7-7-7-5'); // A barre chord
        final result = diagram.render(voicing);

        // Regular border for higher positions
        expect(result, contains('┌'));
        expect(result, contains('└'));
      });

      test('renders voicing with high frets', () {
        final diagram = FretboardDiagram(guitar);
        final voicing = Voicing.parse('X-0-10-10-9-0');
        final result = diagram.render(voicing);

        // Should show fret numbers in the range
        expect(result, contains('9'));
        expect(result, contains('10'));
      });

      test('throws if voicing does not match instrument string count', () {
        final diagram = FretboardDiagram(guitar);
        final voicing = Voicing.parse('0000'); // 4 strings

        expect(
          () => diagram.render(voicing),
          throwsArgumentError,
        );
      });
    });

    group('renderMultiple', () {
      test('renders multiple voicings', () {
        final diagram = FretboardDiagram(guitar);
        final voicings = [
          Voicing.parse('X02210'),
          Voicing.parse('022100'),
        ];
        final result = diagram.renderMultiple(voicings, chordNames: ['Am', 'E']);

        expect(result, contains('Am'));
        expect(result, contains('E'));
      });

      test('returns empty string for empty list', () {
        final diagram = FretboardDiagram(guitar);
        final result = diagram.renderMultiple([]);

        expect(result, isEmpty);
      });
    });

    group('with different instruments', () {
      test('renders ukulele voicing', () {
        final ukulele = Instruments.ukulele;
        final diagram = FretboardDiagram(ukulele);
        final voicing = Voicing.parse('0003'); // C major
        final result = diagram.render(voicing, chordName: 'C');

        expect(result, contains('C'));
        expect(result, contains('●'));
      });
    });
  });

  group('renderVoicingText', () {
    test('renders voicing as text', () {
      final voicing = Voicing.parse('X02210');
      final result = renderVoicingText(voicing, guitar);

      expect(result, contains('X02210'));
      expect(result, contains('A')); // Notes
      expect(result, contains('C'));
      expect(result, contains('E'));
    });

    test('includes chord name when provided', () {
      final voicing = Voicing.parse('X02210');
      final result = renderVoicingText(voicing, guitar, chordName: 'Am');

      expect(result, contains('Am:'));
    });
  });
}
