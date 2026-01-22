import 'dart:io';

import 'package:args/args.dart';

import '../analysis.dart';
import '../capo.dart';
import '../chord.dart';
import '../fretboard_diagram.dart';
import '../interval.dart';
import '../pitch_class.dart';
import '../presets.dart';
import '../transposition.dart';
import '../voicing.dart';
import '../voicing_calculator.dart';
import 'config.dart';

/// Version of the music_theory package.
const String version = '0.1.0';

/// CLI runner for the music_theory command-line tool.
class CliRunner {
  /// Runs the CLI with the given arguments and returns an exit code.
  Future<int> run(List<String> arguments) async {
    final parser = _buildArgParser();

    ArgResults results;
    try {
      results = parser.parse(arguments);
    } on FormatException catch (e) {
      stderr.writeln('Error: ${e.message}');
      stderr.writeln();
      _printUsage(parser);
      return 64; // EX_USAGE
    }

    // Handle global flags
    if (results['help'] as bool) {
      _printUsage(parser);
      return 0;
    }

    if (results['version'] as bool) {
      print('music_theory $version');
      return 0;
    }

    // Handle subcommands
    final command = results.command;
    if (command == null) {
      _printUsage(parser);
      return 0;
    }

    switch (command.name) {
      case 'setup':
        return _runSetup(command);
      case 'chord':
        return _runChord(command);
      case 'voicings':
        return _runVoicings(command);
      case 'transpose':
        return _runTranspose(command);
      case 'analyze':
        return _runAnalyze(command);
      default:
        stderr.writeln('Unknown command: ${command.name}');
        return 64;
    }
  }

  ArgParser _buildArgParser() {
    final parser = ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show this help message.',
      )
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Show version information.',
      );

    // Setup subcommand
    parser.addCommand('setup', _buildSetupParser());

    // Chord subcommand
    parser.addCommand('chord', _buildChordParser());

    // Voicings subcommand
    parser.addCommand('voicings', _buildVoicingsParser());

    // Transpose subcommand
    parser.addCommand('transpose', _buildTransposeParser());

    // Analyze subcommand
    parser.addCommand('analyze', _buildAnalyzeParser());

    return parser;
  }

  ArgParser _buildChordParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for the chord command.',
      );
  }

  ArgParser _buildVoicingsParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for the voicings command.',
      )
      ..addOption(
        'level',
        abbr: 'l',
        help: 'Filter by difficulty: beginner, intermediate, advanced',
        valueHelp: 'level',
        allowed: ['beginner', 'intermediate', 'advanced'],
      )
      ..addOption(
        'limit',
        abbr: 'n',
        help: 'Maximum number of voicings to show',
        valueHelp: 'count',
        defaultsTo: '5',
      )
      ..addFlag(
        'compact',
        abbr: 'c',
        negatable: false,
        help: 'Show compact format instead of fretboard diagrams',
      )
      ..addOption(
        'orientation',
        abbr: 'o',
        help: 'Diagram orientation: vertical, horizontal (overrides config)',
        valueHelp: 'type',
        allowed: ['vertical', 'horizontal'],
      );
  }

  ArgParser _buildTransposeParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for the transpose command.',
      )
      ..addOption(
        'up',
        abbr: 'u',
        help: 'Transpose up by N semitones',
        valueHelp: 'semitones',
      )
      ..addOption(
        'down',
        abbr: 'd',
        help: 'Transpose down by N semitones',
        valueHelp: 'semitones',
      )
      ..addFlag(
        'suggest-capo',
        abbr: 's',
        negatable: false,
        help: 'Suggest capo positions for easier shapes',
      )
      ..addOption(
        'spelling',
        help: 'Prefer sharps or flats: sharps, flats',
        valueHelp: 'style',
        allowed: ['sharps', 'flats'],
        defaultsTo: 'sharps',
      )
      ..addOption(
        'limit',
        abbr: 'n',
        help: 'Maximum capo suggestions to show (with --suggest-capo)',
        valueHelp: 'count',
        defaultsTo: '5',
      );
  }

  ArgParser _buildAnalyzeParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for the analyze command.',
      )
      ..addFlag(
        'key-only',
        abbr: 'k',
        negatable: false,
        help: 'Show only the detected key, not Roman numerals.',
      )
      ..addOption(
        'key',
        help: 'Analyze in a specific key instead of detecting.',
        valueHelp: 'key',
      );
  }

  ArgParser _buildSetupParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for the setup command.',
      )
      ..addFlag(
        'custom',
        negatable: false,
        help: 'Create a fully custom instrument (requires --tuning).',
      )
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Name for custom instrument.',
        valueHelp: 'name',
        defaultsTo: 'Custom',
      )
      ..addOption(
        'instrument',
        abbr: 'i',
        help: 'Set instrument: guitar, bass, ukulele, cavaquinho, banjo, guitar7',
        valueHelp: 'name',
      )
      ..addOption(
        'tuning',
        abbr: 't',
        help: 'Set tuning: "EADGBE", "E2A2D3G3B3E4", or "E2 A2 D3 G3 B3 E4"',
        valueHelp: 'notes',
      )
      ..addOption(
        'frets',
        abbr: 'f',
        help: 'Fret count: "22" (uniform) or "22,22,22,22,5" (per-string).',
        valueHelp: 'count',
      )
      ..addOption(
        'capo',
        abbr: 'c',
        help: 'Set capo position (0-22).',
        valueHelp: 'fret',
      )
      ..addFlag(
        'show',
        abbr: 's',
        negatable: false,
        help: 'Show current configuration.',
      )
      ..addFlag(
        'reset',
        negatable: false,
        help: 'Reset to default (guitar, standard, no capo).',
      )
      ..addFlag(
        'list',
        abbr: 'l',
        negatable: false,
        help: 'List available instruments and tunings.',
      )
      ..addOption(
        'orientation',
        abbr: 'o',
        help: 'Diagram orientation: vertical (default) or horizontal',
        valueHelp: 'type',
        allowed: ['vertical', 'horizontal'],
      );
  }

  Future<int> _runSetup(ArgResults args) async {
    // Help
    if (args['help'] as bool) {
      _printSetupHelp();
      return 0;
    }

    // List instruments and tunings
    if (args['list'] as bool) {
      _printInstrumentsAndTunings();
      return 0;
    }

    // Reset to defaults
    if (args['reset'] as bool) {
      await MusicTheoryConfig.defaultConfig.save();
      print('Configuration reset to defaults.');
      _printConfig(MusicTheoryConfig.defaultConfig);
      return 0;
    }

    // Show current config
    if (args['show'] as bool) {
      final config = await MusicTheoryConfig.load();
      _printConfig(config);
      return 0;
    }

    final isCustom = args['custom'] as bool;

    // Check for changes
    final hasChanges = isCustom ||
        args['instrument'] != null ||
        args['tuning'] != null ||
        args['frets'] != null ||
        args['capo'] != null ||
        args['orientation'] != null;

    if (!hasChanges) {
      _printSetupHelp();
      return 0;
    }

    // Handle custom instrument creation
    if (isCustom) {
      return _setupCustomInstrument(args);
    }

    // Handle preset instrument configuration
    return _setupPresetInstrument(args);
  }

  Future<int> _setupCustomInstrument(ArgResults args) async {
    final tuning = args['tuning'] as String?;
    if (tuning == null) {
      stderr.writeln('Error: --custom requires --tuning');
      stderr.writeln('Example: music_theory setup --custom --tuning BEADGBE --frets 22');
      return 1;
    }

    final name = args['name'] as String;

    // Parse frets
    List<int>? frets;
    if (args['frets'] != null) {
      try {
        frets = parseFrets(args['frets'] as String);
      } catch (e) {
        stderr.writeln('Error: Invalid frets format "${args['frets']}"');
        stderr.writeln('Expected: "22" or "22,22,22,22,5"');
        return 1;
      }
    }

    // Parse capo
    int capo = 0;
    if (args['capo'] != null) {
      capo = int.tryParse(args['capo'] as String) ?? 0;
      if (capo < 0 || capo > 22) {
        stderr.writeln('Error: Capo must be between 0 and 22');
        return 1;
      }
    }

    // Normalize and validate tuning
    String normalizedTuning;
    try {
      normalizedTuning = normalizeTuningString(tuning);
    } catch (e) {
      stderr.writeln('Error: Invalid tuning format "$tuning"');
      stderr.writeln('Expected: "BEADGBE", "B1E2A2D3G3B3E4", or "B1 E2 A2 D3 G3 B3 E4"');
      return 1;
    }

    // Parse orientation
    DiagramOrientation orientation = DiagramOrientation.vertical;
    if (args['orientation'] != null) {
      final orientationStr = args['orientation'] as String;
      orientation = orientationStr == 'horizontal'
          ? DiagramOrientation.horizontal
          : DiagramOrientation.vertical;
    }

    final config = MusicTheoryConfig(
      instrument: name,
      tuningNotes: normalizedTuning,
      capo: capo,
      isCustom: true,
      frets: frets,
      diagramOrientation: orientation,
    );

    // Validate by building the instrument
    try {
      config.toInstrument();
    } catch (e) {
      stderr.writeln('Error: $e');
      return 1;
    }

    await config.save();
    print('Custom instrument saved.');
    _printConfig(config);
    return 0;
  }

  Future<int> _setupPresetInstrument(ArgResults args) async {
    var config = await MusicTheoryConfig.load();

    // If switching from custom to preset, clear custom flags
    if (config.isCustom && args['instrument'] != null) {
      config = config.copyWith(isCustom: false, clearFrets: true);
    }

    // Apply instrument change
    if (args['instrument'] != null) {
      final instrumentName = args['instrument'] as String;
      final available = getAvailableInstruments();
      if (!available.contains(instrumentName.toLowerCase()) &&
          !['guitar7', '7string', '7-string'].contains(instrumentName.toLowerCase())) {
        stderr.writeln('Error: Unknown instrument "$instrumentName"');
        stderr.writeln('Available: ${available.join(", ")}');
        stderr.writeln();
        stderr.writeln('Tip: Use --custom to create a custom instrument.');
        return 1;
      }
      config = MusicTheoryConfig(
        instrument: instrumentName.toLowerCase(),
      );
      // Set to standard tuning for new instrument
      config = config.copyWith(tuningName: 'standard');
    }

    // Apply tuning change - could be preset name or custom notes
    if (args['tuning'] != null) {
      final tuningInput = args['tuning'] as String;

      // First check if it's a preset tuning name
      final available = getAvailableTunings(config.instrument);
      final found = available.any(
        (t) => t.toLowerCase() == tuningInput.toLowerCase() ||
            t.toLowerCase().replaceAll(' ', '') == tuningInput.toLowerCase(),
      );

      if (found) {
        // It's a preset tuning name
        config = config.copyWith(
          tuningName: tuningInput,
          clearTuningNotes: true,
        );
      } else {
        // Treat as custom tuning notes
        try {
          final normalizedTuning = normalizeTuningString(tuningInput);
          config = config.copyWith(
            tuningNotes: normalizedTuning,
            clearTuningName: true,
          );
        } catch (e) {
          stderr.writeln('Error: "$tuningInput" is not a known tuning for ${config.instrument}');
          stderr.writeln('       and could not be parsed as custom notes.');
          stderr.writeln();
          stderr.writeln('Available tunings: ${available.join(", ")}');
          stderr.writeln('Custom format: "EADGBE" or "E2 A2 D3 G3 B3 E4"');
          return 1;
        }
      }
    }

    // Apply capo change
    if (args['capo'] != null) {
      final capoStr = args['capo'] as String;
      final capo = int.tryParse(capoStr);
      if (capo == null || capo < 0 || capo > 22) {
        stderr.writeln('Error: Capo must be a number between 0 and 22');
        return 1;
      }
      config = config.copyWith(capo: capo);
    }

    // Apply orientation change
    if (args['orientation'] != null) {
      final orientationStr = args['orientation'] as String;
      final orientation = orientationStr == 'horizontal'
          ? DiagramOrientation.horizontal
          : DiagramOrientation.vertical;
      config = config.copyWith(diagramOrientation: orientation);
    }

    // Validate the final config
    try {
      config.toInstrument();
    } catch (e) {
      stderr.writeln('Error: Invalid configuration - $e');
      return 1;
    }

    // Save and display
    await config.save();
    print('Configuration saved.');
    _printConfig(config);
    return 0;
  }

  void _printUsage(ArgParser parser) {
    print('music_theory - Music theory utilities for notes, chords, and instruments');
    print('');
    print('Usage: music_theory <command> [options]');
    print('');
    print('Commands:');
    print('  setup      Configure your instrument, tuning, and capo');
    print('  chord      Show chord notes and formula');
    print('  voicings   Show how to play a chord on your instrument');
    print('  transpose  Transpose chords up or down, suggest capo positions');
    print('  analyze    Analyze a chord progression (key, Roman numerals, patterns)');
    print('');
    print('Global options:');
    print(parser.usage);
    print('');
    print('Run "music_theory <command> --help" for more information on a command.');
  }

  void _printSetupHelp() {
    print('music_theory setup - Configure your instrument');
    print('');
    print('Usage: music_theory setup [options]');
    print('');
    print('Preset instruments:');
    print('  -i, --instrument <name>    Set instrument: guitar, bass, ukulele, etc.');
    print('  -t, --tuning <tuning>      Set tuning by name or notes');
    print('  -c, --capo <fret>          Set capo position (0-22)');
    print('');
    print('Custom instruments:');
    print('      --custom               Create a fully custom instrument');
    print('  -n, --name <name>          Name for custom instrument (default: "Custom")');
    print('  -t, --tuning <notes>       Tuning: "BEADGBE" or "B1 E2 A2 D3 G3 B3 E4"');
    print('  -f, --frets <count>        Frets: "22" or "22,22,22,22,5" (per-string)');
    print('');
    print('Display:');
    print('  -o, --orientation <type>   Diagram style: vertical (default), horizontal');
    print('');
    print('Other:');
    print('  -s, --show                 Show current configuration');
    print('      --reset                Reset to default (guitar, standard, no capo)');
    print('  -l, --list                 List all preset instruments and tunings');
    print('  -h, --help                 Show this help');
    print('');
    print('Examples:');
    print('  music_theory setup --instrument guitar --tuning "Drop D"');
    print('  music_theory setup --instrument guitar --tuning DADGAD');
    print('  music_theory setup --capo 2');
    print('  music_theory setup --custom --name "7-string" --tuning BEADGBE --frets 24');
    print('  music_theory setup --show');
  }

  void _printConfig(MusicTheoryConfig config) {
    print('');
    print('Current configuration:');
    print('  Instrument:  ${config.instrument}${config.isCustom ? " (custom)" : ""}');
    if (config.tuningNotes != null) {
      print('  Tuning:      ${config.tuningNotes}');
    } else if (config.tuningName != null) {
      print('  Tuning:      ${config.tuningName}');
    } else {
      print('  Tuning:      (default)');
    }
    if (config.frets != null && config.frets!.isNotEmpty) {
      if (config.frets!.length == 1 || config.frets!.toSet().length == 1) {
        print('  Frets:       ${config.frets!.first}');
      } else {
        print('  Frets:       ${config.frets!.join(", ")}');
      }
    }
    print('  Capo:        ${config.capo == 0 ? "none" : "fret ${config.capo}"}');
    print('  Diagrams:    ${config.diagramOrientation.name}');
    print('');
    try {
      final instrument = config.toInstrument();
      print('  Resolved:    $instrument');
    } catch (e) {
      print('  (Unable to resolve instrument: $e)');
    }
  }

  void _printInstrumentsAndTunings() {
    print('Available instruments and tunings:');
    print('');

    final instruments = [
      ('guitar', Tunings.guitar.all),
      ('bass', Tunings.bass.all),
      ('ukulele', Tunings.ukulele.all),
      ('cavaquinho', Tunings.cavaquinho.all),
      ('banjo', Tunings.banjo.all),
      ('guitar7String', Tunings.guitar7String.all),
    ];

    for (final (name, tunings) in instruments) {
      print('  $name:');
      for (final tuning in tunings) {
        final notes = tuning.strings.map((s) => s.toString()).join(' ');
        print('    ${tuning.name.padRight(20)} $notes');
      }
      print('');
    }
  }

  // ==================== Chord Command ====================

  Future<int> _runChord(ArgResults args) async {
    // Help
    if (args['help'] as bool) {
      _printChordHelp();
      return 0;
    }

    final rest = args.rest;
    if (rest.isEmpty) {
      _printChordHelp();
      return 0;
    }

    // Parse chord(s)
    if (rest.length == 1) {
      // Single chord - show info
      return _showChordInfo(rest[0]);
    } else if (rest.length == 2) {
      // Two chords - compare
      return _compareChords(rest[0], rest[1]);
    } else {
      stderr.writeln('Error: Too many arguments. Expected 1 or 2 chord names.');
      return 64;
    }
  }

  int _showChordInfo(String chordStr) {
    final chord = Chord.tryParse(chordStr);
    if (chord == null) {
      stderr.writeln('Error: Could not parse chord "$chordStr"');
      stderr.writeln();
      stderr.writeln('Expected formats: C, Am, G7, Fmaj7, Bb, F#m, etc.');
      return 1;
    }

    print('');
    print('  ${chord.name} (${chord.symbol})');
    print('');

    // Notes
    final notes = chord.pitchClasses.map((pc) => pc.name).join(' - ');
    print('  Notes:    $notes');

    // Formula with interval names
    final formula = chord.intervals
        .map((i) => i == Interval.perfectUnison ? 'R' : i.shortName)
        .join(' - ');
    print('  Formula:  $formula');
    print('');

    // Beginner-friendly explanation
    print('  Intervals:');
    for (var i = 0; i < chord.intervals.length; i++) {
      final interval = chord.intervals[i];
      final note = chord.pitchClasses[i];
      if (i == 0) {
        print('    ${note.name.padRight(3)} = Root');
      } else {
        print('    ${note.name.padRight(3)} = ${interval.friendlyName} (${interval.shortName})');
      }
    }
    print('');

    return 0;
  }

  int _compareChords(String chord1Str, String chord2Str) {
    final chord1 = Chord.tryParse(chord1Str);
    final chord2 = Chord.tryParse(chord2Str);

    if (chord1 == null) {
      stderr.writeln('Error: Could not parse chord "$chord1Str"');
      return 1;
    }
    if (chord2 == null) {
      stderr.writeln('Error: Could not parse chord "$chord2Str"');
      return 1;
    }

    print('');
    print('  Comparing ${chord1.symbol} and ${chord2.symbol}');
    print('');

    // Side by side comparison
    final notes1 = chord1.pitchClasses.map((pc) => pc.name).join(' - ');
    final notes2 = chord2.pitchClasses.map((pc) => pc.name).join(' - ');
    print('  ${chord1.symbol.padRight(12)} ${chord2.symbol}');
    print('  ${"─" * 30}');
    print('  ${notes1.padRight(12)} $notes2');
    print('');

    // Find common notes
    final set1 = chord1.pitchClasses.toSet();
    final set2 = chord2.pitchClasses.toSet();
    final common = set1.intersection(set2);

    if (common.isNotEmpty) {
      final commonStr = common.map((pc) => pc.name).join(', ');
      print('  Common notes: $commonStr');
    } else {
      print('  No common notes');
    }

    // Unique notes
    final only1 = set1.difference(set2);
    final only2 = set2.difference(set1);
    if (only1.isNotEmpty) {
      print('  Only in ${chord1.symbol}: ${only1.map((pc) => pc.name).join(", ")}');
    }
    if (only2.isNotEmpty) {
      print('  Only in ${chord2.symbol}: ${only2.map((pc) => pc.name).join(", ")}');
    }
    print('');

    return 0;
  }

  void _printChordHelp() {
    print('music_theory chord - Show chord notes and formula');
    print('');
    print('Usage: music_theory chord <chord> [chord2]');
    print('');
    print('Arguments:');
    print('  chord     A chord name like C, Am, G7, Fmaj7, Bb, F#m');
    print('  chord2    Optional second chord to compare');
    print('');
    print('Options:');
    print('  -h, --help    Show this help');
    print('');
    print('Examples:');
    print('  music_theory chord Am        Show A minor chord notes and formula');
    print('  music_theory chord Gmaj7     Show G major 7th chord');
    print('  music_theory chord C Am      Compare C major and A minor');
    print('  music_theory chord F#m Bm    Compare F# minor and B minor');
    print('');
    print('Supported chord types:');
    print('  Major:      C, Cmaj, CM');
    print('  Minor:      Cm, Cmin, C-');
    print('  Diminished: Cdim, C°');
    print('  Augmented:  Caug, C+');
    print('  Suspended:  Csus2, Csus4, Csus');
    print('  Seventh:    C7, Cmaj7, CM7, Cm7, Cdim7, Cm7b5');
    print('  Extended:   C9, Cmaj9, Cm9, Cadd9');
    print('  Sixth:      C6, Cm6');
    print('  Power:      C5');
  }

  // ==================== Voicings Command ====================

  Future<int> _runVoicings(ArgResults args) async {
    // Help
    if (args['help'] as bool) {
      _printVoicingsHelp();
      return 0;
    }

    final rest = args.rest;
    if (rest.isEmpty) {
      _printVoicingsHelp();
      return 0;
    }

    // Parse chord
    final chordStr = rest[0];
    final chord = Chord.tryParse(chordStr);
    if (chord == null) {
      stderr.writeln('Error: Could not parse chord "$chordStr"');
      stderr.writeln();
      stderr.writeln('Expected formats: C, Am, G7, Fmaj7, Bb, F#m, etc.');
      return 1;
    }

    // Load instrument config
    final config = await MusicTheoryConfig.load();
    final instrument = config.toInstrument();

    // Parse options
    final levelStr = args['level'] as String?;
    final limitStr = args['limit'] as String;
    final compact = args['compact'] as bool;
    final orientationStr = args['orientation'] as String?;

    final limit = int.tryParse(limitStr) ?? 5;

    // Determine diagram orientation (command line overrides config)
    DiagramOrientation orientation = config.diagramOrientation;
    if (orientationStr != null) {
      orientation = orientationStr == 'horizontal'
          ? DiagramOrientation.horizontal
          : DiagramOrientation.vertical;
    }

    // Determine calculator options based on level
    VoicingCalculatorOptions options;
    if (levelStr == 'beginner') {
      options = VoicingCalculatorOptions.beginner;
    } else if (levelStr == 'intermediate') {
      options = VoicingCalculatorOptions.intermediate;
    } else if (levelStr == 'advanced') {
      options = VoicingCalculatorOptions.advanced;
    } else {
      options = const VoicingCalculatorOptions();
    }

    // Find voicings
    final calculator = VoicingCalculator(instrument, options: options);
    final voicings = calculator.findVoicings(chord);

    if (voicings.isEmpty) {
      print('');
      print('  No voicings found for ${chord.symbol} on ${instrument.name}');
      print('');
      if (levelStr == 'beginner') {
        print('  Try --level intermediate or --level advanced for more options.');
      }
      return 0;
    }

    // Limit results
    final displayed = voicings.take(limit).toList();

    print('');
    print('  ${chord.name} (${chord.symbol}) on ${instrument.name}');
    print('  Found ${voicings.length} voicing${voicings.length == 1 ? "" : "s"}, showing ${displayed.length}:');
    print('');

    if (compact) {
      // Compact format
      for (var i = 0; i < displayed.length; i++) {
        final v = displayed[i];
        final notes = v.pitchClassesOn(instrument).map((p) => p.name).join('-');
        final diffLabel = _difficultyLabel(v.difficulty);
        print('  ${i + 1}. ${v.toCompactString().padRight(10)} $notes ($diffLabel)');
      }
    } else {
      // Fretboard diagram format
      final diagram = FretboardDiagram(instrument, orientation: orientation);
      for (var i = 0; i < displayed.length; i++) {
        final v = displayed[i];
        final diffLabel = _difficultyLabel(v.difficulty);
        print('  Voicing ${i + 1} ($diffLabel):');
        print(diagram.render(v, chordName: chord.symbol));
      }
    }

    print('');
    return 0;
  }

  String _difficultyLabel(VoicingDifficulty difficulty) {
    return switch (difficulty) {
      VoicingDifficulty.beginner => 'easy',
      VoicingDifficulty.intermediate => 'medium',
      VoicingDifficulty.advanced => 'hard',
    };
  }

  void _printVoicingsHelp() {
    print('music_theory voicings - Show how to play a chord');
    print('');
    print('Usage: music_theory voicings <chord> [options]');
    print('');
    print('Arguments:');
    print('  chord     A chord name like C, Am, G7, Fmaj7');
    print('');
    print('Options:');
    print('  -l, --level <level>        Filter by difficulty: beginner, intermediate, advanced');
    print('  -n, --limit <count>        Maximum voicings to show (default: 5)');
    print('  -c, --compact              Show compact format instead of diagrams');
    print('  -o, --orientation <type>   Diagram style: vertical, horizontal');
    print('  -h, --help                 Show this help');
    print('');
    print('Examples:');
    print('  music_theory voicings Am               Show Am voicings on configured instrument');
    print('  music_theory voicings G --level beginner   Show easy G voicings');
    print('  music_theory voicings C7 --limit 10   Show up to 10 C7 voicings');
    print('  music_theory voicings Dm --compact    Show voicings in compact format');
    print('');
    print('Note: Uses the instrument configured with "music_theory setup".');
    print('      Default is standard tuning guitar.');
  }

  // ==================== Transpose Command ====================

  Future<int> _runTranspose(ArgResults args) async {
    // Help
    if (args['help'] as bool) {
      _printTransposeHelp();
      return 0;
    }

    final rest = args.rest;
    if (rest.isEmpty) {
      _printTransposeHelp();
      return 0;
    }

    // Parse chord(s) - could be a single chord or a progression
    final input = rest.join(' ');
    final progression = ChordProgression.tryParse(input);
    if (progression == null || progression.isEmpty) {
      stderr.writeln('Error: Could not parse chords "$input"');
      stderr.writeln();
      stderr.writeln('Expected: Single chord (Am) or progression (C Am F G)');
      return 1;
    }

    // Parse transposition options
    final upStr = args['up'] as String?;
    final downStr = args['down'] as String?;
    final suggestCapo = args['suggest-capo'] as bool;
    final spellingStr = args['spelling'] as String;
    final limitStr = args['limit'] as String;

    final spelling = spellingStr == 'flats'
        ? SpellingPreference.flats
        : SpellingPreference.sharps;
    final limit = int.tryParse(limitStr) ?? 5;

    // Validate options
    if (upStr != null && downStr != null) {
      stderr.writeln('Error: Cannot use both --up and --down');
      return 1;
    }

    // Handle capo suggestion mode
    if (suggestCapo) {
      return _runCapoSuggestion(progression, limit);
    }

    // Handle transposition
    if (upStr == null && downStr == null) {
      // No transposition - just show the chords with spelling
      _printProgression(progression, spelling, 0);
      return 0;
    }

    int semitones;
    if (upStr != null) {
      semitones = int.tryParse(upStr) ?? 0;
      if (semitones < 0) semitones = -semitones;
    } else {
      semitones = -(int.tryParse(downStr!) ?? 0);
      if (semitones > 0) semitones = -semitones;
    }

    final transposed = progression.transpose(semitones);
    _printProgression(transposed, spelling, semitones);
    return 0;
  }

  void _printProgression(
    ChordProgression progression,
    SpellingPreference spelling,
    int semitones,
  ) {
    print('');
    if (semitones == 0) {
      print('  Chords:');
    } else if (semitones > 0) {
      print('  Transposed up $semitones semitone${semitones == 1 ? "" : "s"}:');
    } else {
      print('  Transposed down ${-semitones} semitone${semitones == -1 ? "" : "s"}:');
    }
    print('');

    final spelled = progression.spell(spelling);
    print('  ${spelled.join("  ")}');
    print('');

    // Show the notes in each chord
    for (var i = 0; i < progression.chords.length; i++) {
      final chord = progression.chords[i];
      final chordSpelling = spellChord(chord, spelling);
      final notes = chord.pitchClasses
          .map((pc) => spellPitchClass(pc, spelling))
          .join(' - ');
      print('  $chordSpelling: $notes');
    }
    print('');
  }

  Future<int> _runCapoSuggestion(ChordProgression progression, int limit) async {
    final config = await MusicTheoryConfig.load();
    final instrument = config.toInstrument();

    final suggester = CapoSuggester(instrument);
    final suggestions = suggester.suggest(progression.chords);

    print('');
    print('  Capo suggestions for: ${progression.toSymbolString()}');
    print('  on ${instrument.name}');
    print('');

    if (suggestions.isEmpty) {
      print('  No suggestions available.');
      return 0;
    }

    final displayed = suggestions.take(limit).toList();
    for (var i = 0; i < displayed.length; i++) {
      final s = displayed[i];
      final capoLabel = s.capoFret == 0 ? 'No capo' : 'Capo ${s.capoFret}';
      final shapes = s.shapeSymbols.join('  ');
      final difficulty = s.difficultyScore.toStringAsFixed(1);
      print('  ${i + 1}. $capoLabel: play $shapes (difficulty: $difficulty)');
    }
    print('');

    // Show the best suggestion with more detail
    final best = displayed.first;
    if (best.capoFret > 0) {
      print('  Best option: Put capo on fret ${best.capoFret}');
      print('  Then play these shapes:');
      for (var i = 0; i < best.shapes.length; i++) {
        print('    ${progression.chords[i].symbol} -> ${best.shapes[i].symbol}');
      }
      print('');
    }

    return 0;
  }

  void _printTransposeHelp() {
    print('music_theory transpose - Transpose chords');
    print('');
    print('Usage: music_theory transpose <chords> [options]');
    print('');
    print('Arguments:');
    print('  chords    One or more chord names: "Am" or "C Am F G"');
    print('');
    print('Options:');
    print('  -u, --up <n>          Transpose up by N semitones');
    print('  -d, --down <n>        Transpose down by N semitones');
    print('  -s, --suggest-capo    Suggest capo positions for easier shapes');
    print('      --spelling <s>    Prefer sharps or flats (default: sharps)');
    print('  -n, --limit <n>       Max capo suggestions to show (default: 5)');
    print('  -h, --help            Show this help');
    print('');
    print('Examples:');
    print('  music_theory transpose Am --up 2         Transpose Am up 2 semitones -> Bm');
    print('  music_theory transpose "C Am F G" --up 5 Transpose progression to F Dm Bb C');
    print('  music_theory transpose F --down 1        Transpose F down to E');
    print('  music_theory transpose "F Bb C" -s       Suggest capo positions');
    print('  music_theory transpose C# --spelling flats  Show as Db instead of C#');
    print('');
    print('Common transpositions:');
    print('  1 semitone  = half step     (C -> C#)');
    print('  2 semitones = whole step    (C -> D)');
    print('  5 semitones = perfect 4th   (C -> F)');
    print('  7 semitones = perfect 5th   (C -> G)');
    print('  12 semitones = octave       (C -> C)');
  }

  // ==================== Analyze Command ====================

  Future<int> _runAnalyze(ArgResults args) async {
    // Help
    if (args['help'] as bool) {
      _printAnalyzeHelp();
      return 0;
    }

    final rest = args.rest;
    if (rest.isEmpty) {
      _printAnalyzeHelp();
      return 0;
    }

    // Parse chord progression
    final input = rest.join(' ');
    final progression = ChordProgression.tryParse(input);
    if (progression == null || progression.isEmpty) {
      stderr.writeln('Error: Could not parse chords "$input"');
      stderr.writeln();
      stderr.writeln('Expected: Chord progression like "C Am F G"');
      return 1;
    }

    final keyOnly = args['key-only'] as bool;
    final specifiedKeyStr = args['key'] as String?;

    // If a specific key is provided, use it; otherwise detect
    Key? key;
    KeyDetectionResult? detection;

    if (specifiedKeyStr != null) {
      key = _parseKey(specifiedKeyStr);
      if (key == null) {
        stderr.writeln('Error: Could not parse key "$specifiedKeyStr"');
        stderr.writeln();
        stderr.writeln('Expected: "C", "Am", "F#", "Bbm", etc.');
        return 1;
      }
    } else {
      detection = progression.detectKey();
      if (detection != null) {
        key = detection.key;
      }
    }

    print('');

    // Show key detection result
    if (detection != null) {
      final confidencePct = (detection.confidence * 100).clamp(0, 100).toStringAsFixed(0);
      print('  Detected key: ${detection.key.symbol} ($confidencePct% confidence)');
    } else if (key != null) {
      print('  Key: ${key.symbol}');
    } else {
      print('  Could not determine key');
      print('');
      return 0;
    }

    if (keyOnly) {
      // Show alternative keys
      if (specifiedKeyStr == null) {
        final alternatives = progression.detectPossibleKeys();
        if (alternatives.length > 1) {
          print('');
          print('  Other possibilities:');
          for (var i = 1; i < alternatives.length; i++) {
            final alt = alternatives[i];
            final confPct = (alt.confidence * 100).clamp(0, 100).toStringAsFixed(0);
            print('    ${alt.key.symbol} ($confPct%)');
          }
        }
      }
      print('');
      return 0;
    }

    // Show Roman numeral analysis
    if (key != null) {
      print('');
      print('  Progression: ${progression.toSymbolString()}');
      print('');

      final numerals = progression.inKey(key);
      final numeralStr = numerals.map((n) => n.numeral).join('  ');
      print('  Roman numerals: $numeralStr');
      print('');

      // Show each chord with its function
      print('  Analysis:');
      for (var i = 0; i < progression.chords.length; i++) {
        final chord = progression.chords[i];
        final numeral = numerals[i];
        final function = numeral.functionName;
        print('    ${chord.symbol.padRight(8)} ${numeral.numeral.padRight(6)} $function');
      }
      print('');

      // Recognize patterns
      final patterns = ProgressionPatterns.recognize(numerals);
      if (patterns.isNotEmpty) {
        print('  Recognized patterns:');
        for (final pattern in patterns) {
          print('    • $pattern');
        }
        print('');
      }
    }

    return 0;
  }

  /// Parses a key string like "C", "Am", "F#", "Bbm".
  Key? _parseKey(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Check if it's a minor key (ends with 'm', 'min', or 'minor')
    bool isMinor = false;
    String rootStr = trimmed;

    if (trimmed.endsWith('minor')) {
      isMinor = true;
      rootStr = trimmed.substring(0, trimmed.length - 5).trim();
    } else if (trimmed.endsWith('min')) {
      isMinor = true;
      rootStr = trimmed.substring(0, trimmed.length - 3).trim();
    } else if (trimmed.endsWith('m') && !trimmed.endsWith('M')) {
      // 'm' for minor, but not 'M' for major
      isMinor = true;
      rootStr = trimmed.substring(0, trimmed.length - 1);
    }

    // Parse the root pitch class
    final root = _parsePitchClass(rootStr);
    if (root == null) return null;

    return isMinor ? Key.minor(root) : Key.major(root);
  }

  /// Parses a pitch class string like "C", "F#", "Bb".
  PitchClass? _parsePitchClass(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    try {
      return PitchClass.parse(trimmed);
    } catch (_) {
      return null;
    }
  }

  void _printAnalyzeHelp() {
    print('music_theory analyze - Analyze a chord progression');
    print('');
    print('Usage: music_theory analyze <chords> [options]');
    print('');
    print('Arguments:');
    print('  chords    A chord progression like "C Am F G"');
    print('');
    print('Options:');
    print('  -k, --key-only     Show only the detected key');
    print('      --key <key>    Analyze in a specific key (e.g., C, Am, F#)');
    print('  -h, --help         Show this help');
    print('');
    print('Examples:');
    print('  music_theory analyze "C Am F G"           Analyze pop progression');
    print('  music_theory analyze "Am G F E" --key Am  Analyze in A minor');
    print('  music_theory analyze "Dm7 G7 Cmaj7" -k    Show detected key only');
    print('');
    print('What the analysis shows:');
    print('  • Detected key (e.g., C major, A minor)');
    print('  • Roman numeral for each chord (I, IV, V, vi, etc.)');
    print('  • Chord function (tonic, dominant, subdominant)');
    print('  • Recognized patterns (50s progression, ii-V-I, etc.)');
    print('');
    print('Understanding Roman numerals:');
    print('  I   = tonic (home base, "at rest")');
    print('  ii  = supertonic (often leads to V)');
    print('  iii = mediant (connects I and V)');
    print('  IV  = subdominant (builds tension)');
    print('  V   = dominant (creates pull back to I)');
    print('  vi  = submediant (relative minor of I)');
    print('  vii° = leading tone (strong pull to I)');
    print('');
    print('Uppercase = major chord, lowercase = minor chord');
  }
}
