import 'dart:io';

import 'package:args/args.dart';

import '../chord.dart';
import '../fretboard_diagram.dart';
import '../interval.dart';
import '../presets.dart';
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
        args['capo'] != null;

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

    final config = MusicTheoryConfig(
      instrument: name,
      tuningNotes: normalizedTuning,
      capo: capo,
      isCustom: true,
      frets: frets,
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

    final limit = int.tryParse(limitStr) ?? 5;

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
      final diagram = FretboardDiagram(instrument);
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
    print('  -l, --level <level>   Filter by difficulty: beginner, intermediate, advanced');
    print('  -n, --limit <count>   Maximum voicings to show (default: 5)');
    print('  -c, --compact         Show compact format instead of diagrams');
    print('  -h, --help            Show this help');
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
}
