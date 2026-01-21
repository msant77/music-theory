# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Dart package for music theory - notes, intervals, chords, instruments, and transposition. This package is designed to support the chordo app and ICLF ecosystem by providing programmatic access to music theory concepts.

## Build & Test Commands

```bash
# Get dependencies
dart pub get

# Run all tests
dart test

# Run a single test file
dart test test/music_theory_test.dart

# Run tests by tag (tags defined in dart_test.yaml: unit, integration)
dart test -t unit

# Analyze code
dart analyze

# Format code
dart format lib/ bin/ test/ example/
```

## CLI Usage

```bash
# Show help
dart run bin/music_theory.dart --help

# Show version
dart run bin/music_theory.dart --version
```

Future CLI commands (planned):
- `transpose` - Transpose notes or chords
- `analyze` - Analyze chord progressions
- `voicings` - Show chord voicings for instruments

## Architecture

The library follows a clean separation between music theory concepts:

```
lib/
├── music_theory.dart     # Public API - exports all modules
└── src/
    ├── note.dart         # (planned) Note and pitch class representation
    ├── interval.dart     # (planned) Musical intervals
    ├── chord.dart        # (planned) Chord construction and analysis
    ├── instrument.dart   # (planned) Instrument definitions and tunings
    └── transposition.dart # (planned) Transposition utilities

bin/
└── music_theory.dart     # CLI entry point
```

### Planned Features

- **Notes**: Pitch classes (C, C#, D, etc.), octave notation (C4), enharmonic equivalents
- **Intervals**: Major, minor, perfect, augmented, diminished intervals
- **Chords**: Chord construction, chord types, inversions, extensions
- **Instruments**: Guitar, piano, ukulele with standard/alternate tunings
- **Voicings**: Fingering diagrams, chord shapes for instruments
- **Transposition**: Key changes, capo calculations

## Quality Standards

This package follows the same quality standards as iclf-parser:
- 95% minimum test coverage
- Strict static analysis (see analysis_options.yaml)
- Zero tolerance for analyzer warnings
- Public API documentation required

## Local CI

Run checks locally before committing:

```bash
./scripts/ci.sh          # Full suite: format, analyze, test, coverage
./scripts/ci.sh quick    # Fast check: format + analyze only
./scripts/ci.sh test     # Run tests with coverage
./scripts/ci.sh help     # Show all commands
```

Setup pre-commit hooks:
```bash
./scripts/setup-hooks.sh
```
