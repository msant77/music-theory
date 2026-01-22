import 'package:music_theory/music_theory.dart';
import 'package:test/test.dart';

void main() {
  group('IntervalQuality', () {
    test('has correct symbols', () {
      expect(IntervalQuality.diminished.symbol, equals('d'));
      expect(IntervalQuality.minor.symbol, equals('m'));
      expect(IntervalQuality.perfect.symbol, equals('P'));
      expect(IntervalQuality.major.symbol, equals('M'));
      expect(IntervalQuality.augmented.symbol, equals('A'));
    });

    test('has correct names', () {
      expect(IntervalQuality.diminished.name, equals('diminished'));
      expect(IntervalQuality.minor.name, equals('minor'));
      expect(IntervalQuality.perfect.name, equals('perfect'));
      expect(IntervalQuality.major.name, equals('major'));
      expect(IntervalQuality.augmented.name, equals('augmented'));
    });
  });

  group('Interval', () {
    group('standard intervals', () {
      test('perfectUnison is 0 semitones', () {
        expect(Interval.perfectUnison.semitones, equals(0));
        expect(Interval.perfectUnison.quality, equals(IntervalQuality.perfect));
        expect(Interval.perfectUnison.number, equals(1));
      });

      test('minorSecond is 1 semitone', () {
        expect(Interval.minorSecond.semitones, equals(1));
        expect(Interval.minorSecond.quality, equals(IntervalQuality.minor));
        expect(Interval.minorSecond.number, equals(2));
      });

      test('majorSecond is 2 semitones', () {
        expect(Interval.majorSecond.semitones, equals(2));
        expect(Interval.majorSecond.quality, equals(IntervalQuality.major));
        expect(Interval.majorSecond.number, equals(2));
      });

      test('minorThird is 3 semitones', () {
        expect(Interval.minorThird.semitones, equals(3));
        expect(Interval.minorThird.quality, equals(IntervalQuality.minor));
        expect(Interval.minorThird.number, equals(3));
      });

      test('majorThird is 4 semitones', () {
        expect(Interval.majorThird.semitones, equals(4));
        expect(Interval.majorThird.quality, equals(IntervalQuality.major));
        expect(Interval.majorThird.number, equals(3));
      });

      test('perfectFourth is 5 semitones', () {
        expect(Interval.perfectFourth.semitones, equals(5));
        expect(Interval.perfectFourth.quality, equals(IntervalQuality.perfect));
        expect(Interval.perfectFourth.number, equals(4));
      });

      test('augmentedFourth (tritone) is 6 semitones', () {
        expect(Interval.augmentedFourth.semitones, equals(6));
        expect(Interval.augmentedFourth.quality,
            equals(IntervalQuality.augmented));
        expect(Interval.augmentedFourth.number, equals(4));
      });

      test('diminishedFifth (tritone) is 6 semitones', () {
        expect(Interval.diminishedFifth.semitones, equals(6));
        expect(Interval.diminishedFifth.quality,
            equals(IntervalQuality.diminished));
        expect(Interval.diminishedFifth.number, equals(5));
      });

      test('perfectFifth is 7 semitones', () {
        expect(Interval.perfectFifth.semitones, equals(7));
        expect(Interval.perfectFifth.quality, equals(IntervalQuality.perfect));
        expect(Interval.perfectFifth.number, equals(5));
      });

      test('minorSixth is 8 semitones', () {
        expect(Interval.minorSixth.semitones, equals(8));
        expect(Interval.minorSixth.quality, equals(IntervalQuality.minor));
        expect(Interval.minorSixth.number, equals(6));
      });

      test('majorSixth is 9 semitones', () {
        expect(Interval.majorSixth.semitones, equals(9));
        expect(Interval.majorSixth.quality, equals(IntervalQuality.major));
        expect(Interval.majorSixth.number, equals(6));
      });

      test('minorSeventh is 10 semitones', () {
        expect(Interval.minorSeventh.semitones, equals(10));
        expect(Interval.minorSeventh.quality, equals(IntervalQuality.minor));
        expect(Interval.minorSeventh.number, equals(7));
      });

      test('majorSeventh is 11 semitones', () {
        expect(Interval.majorSeventh.semitones, equals(11));
        expect(Interval.majorSeventh.quality, equals(IntervalQuality.major));
        expect(Interval.majorSeventh.number, equals(7));
      });

      test('perfectOctave is 12 semitones', () {
        expect(Interval.perfectOctave.semitones, equals(12));
        expect(Interval.perfectOctave.quality, equals(IntervalQuality.perfect));
        expect(Interval.perfectOctave.number, equals(8));
      });
    });

    group('aliases', () {
      test('halfStep is minorSecond', () {
        expect(Interval.halfStep, same(Interval.minorSecond));
      });

      test('wholeStep is majorSecond', () {
        expect(Interval.wholeStep, same(Interval.majorSecond));
      });

      test('tritone is augmentedFourth', () {
        expect(Interval.tritone, same(Interval.augmentedFourth));
      });

      test('octave is perfectOctave', () {
        expect(Interval.octave, same(Interval.perfectOctave));
      });
    });

    group('fromSemitones', () {
      test('creates correct simple intervals', () {
        expect(Interval.fromSemitones(0), equals(Interval.perfectUnison));
        expect(Interval.fromSemitones(1), equals(Interval.minorSecond));
        expect(Interval.fromSemitones(2), equals(Interval.majorSecond));
        expect(Interval.fromSemitones(3), equals(Interval.minorThird));
        expect(Interval.fromSemitones(4), equals(Interval.majorThird));
        expect(Interval.fromSemitones(5), equals(Interval.perfectFourth));
        expect(Interval.fromSemitones(6), equals(Interval.augmentedFourth));
        expect(Interval.fromSemitones(7), equals(Interval.perfectFifth));
        expect(Interval.fromSemitones(8), equals(Interval.minorSixth));
        expect(Interval.fromSemitones(9), equals(Interval.majorSixth));
        expect(Interval.fromSemitones(10), equals(Interval.minorSeventh));
        expect(Interval.fromSemitones(11), equals(Interval.majorSeventh));
      });

      test('creates compound intervals', () {
        final minorNinth = Interval.fromSemitones(13);
        expect(minorNinth.semitones, equals(13));
        expect(minorNinth.quality, equals(IntervalQuality.minor));
        expect(minorNinth.number, equals(9)); // 2 + 7

        final majorTenth = Interval.fromSemitones(16);
        expect(majorTenth.semitones, equals(16));
        expect(majorTenth.number, equals(10)); // 3 + 7
      });

      test('handles two octaves', () {
        final twoOctaves = Interval.fromSemitones(24);
        expect(twoOctaves.semitones, equals(24));
        expect(twoOctaves.quality, equals(IntervalQuality.perfect));
        expect(twoOctaves.number, equals(15)); // 1 + 7 + 7
      });
    });

    group('between', () {
      test('calculates interval between notes', () {
        final c4 = Note.parse('C4');
        final g4 = Note.parse('G4');
        final interval = Interval.between(c4, g4);
        expect(interval.semitones, equals(7));
        expect(interval.name, equals('perfect 5th'));
      });

      test('returns same interval regardless of order', () {
        final c4 = Note.parse('C4');
        final g4 = Note.parse('G4');
        expect(Interval.between(c4, g4), equals(Interval.between(g4, c4)));
      });

      test('calculates unison for same note', () {
        final c4 = Note.parse('C4');
        final interval = Interval.between(c4, c4);
        expect(interval, equals(Interval.perfectUnison));
      });

      test('calculates octave', () {
        final c4 = Note.parse('C4');
        final c5 = Note.parse('C5');
        final interval = Interval.between(c4, c5);
        expect(interval.semitones, equals(12));
      });

      test('calculates compound intervals', () {
        final c4 = Note.parse('C4');
        final d5 = Note.parse('D5');
        final interval = Interval.between(c4, d5);
        expect(interval.semitones, equals(14));
        expect(interval.isCompound, isTrue);
      });
    });

    group('directedSemitones', () {
      test('returns positive for ascending', () {
        final c4 = Note.parse('C4');
        final g4 = Note.parse('G4');
        expect(Interval.directedSemitones(c4, g4), equals(7));
      });

      test('returns negative for descending', () {
        final g4 = Note.parse('G4');
        final c4 = Note.parse('C4');
        expect(Interval.directedSemitones(g4, c4), equals(-7));
      });

      test('returns zero for same note', () {
        final c4 = Note.parse('C4');
        expect(Interval.directedSemitones(c4, c4), equals(0));
      });
    });

    group('properties', () {
      test('isPerfect identifies perfect intervals', () {
        expect(Interval.perfectUnison.isPerfect, isTrue);
        expect(Interval.perfectFourth.isPerfect, isTrue);
        expect(Interval.perfectFifth.isPerfect, isTrue);
        expect(Interval.perfectOctave.isPerfect, isTrue);

        expect(Interval.majorThird.isPerfect, isFalse);
        expect(Interval.minorSecond.isPerfect, isFalse);
      });

      test('isCompound identifies compound intervals', () {
        expect(Interval.perfectOctave.isCompound, isFalse);
        expect(Interval.majorThird.isCompound, isFalse);

        final minorNinth = Interval.fromSemitones(13);
        expect(minorNinth.isCompound, isTrue);
      });

      test('simple reduces compound to simple interval', () {
        final minorNinth = Interval.fromSemitones(13);
        expect(minorNinth.simple, equals(Interval.minorSecond));

        final twoOctaves = Interval.fromSemitones(24);
        expect(twoOctaves.simple, equals(Interval.perfectUnison));
      });

      test('simple returns same for simple intervals', () {
        expect(Interval.majorThird.simple, equals(Interval.majorThird));
      });
    });

    group('inversion', () {
      test('inverts major third to minor sixth', () {
        expect(Interval.majorThird.inversion, equals(Interval.minorSixth));
      });

      test('inverts minor third to major sixth', () {
        expect(Interval.minorThird.inversion, equals(Interval.majorSixth));
      });

      test('inverts perfect fourth to perfect fifth', () {
        expect(Interval.perfectFourth.inversion, equals(Interval.perfectFifth));
      });

      test('inverts perfect fifth to perfect fourth', () {
        expect(Interval.perfectFifth.inversion, equals(Interval.perfectFourth));
      });

      test('inverts minor second to major seventh', () {
        expect(Interval.minorSecond.inversion, equals(Interval.majorSeventh));
      });

      test('inverts unison to octave', () {
        // 12 - 0 = 12, but 12 % 12 = 0, so fromSemitones(12) = octave
        // Actually the inversion of unison wraps: 12 - 0 = 12
        final inv = Interval.perfectUnison.inversion;
        expect(inv.semitones, equals(12));
      });
    });

    group('friendlyName', () {
      test('returns beginner-friendly names', () {
        expect(Interval.perfectUnison.friendlyName, equals('unison'));
        expect(Interval.minorSecond.friendlyName, equals('half step'));
        expect(Interval.majorSecond.friendlyName, equals('whole step'));
        expect(Interval.minorThird.friendlyName, equals('minor third'));
        expect(Interval.majorThird.friendlyName, equals('major third'));
        expect(Interval.perfectFourth.friendlyName, equals('perfect fourth'));
        expect(Interval.augmentedFourth.friendlyName, equals('tritone'));
        expect(Interval.perfectFifth.friendlyName, equals('perfect fifth'));
        expect(Interval.minorSixth.friendlyName, equals('minor sixth'));
        expect(Interval.majorSixth.friendlyName, equals('major sixth'));
        expect(Interval.minorSeventh.friendlyName, equals('minor seventh'));
        expect(Interval.majorSeventh.friendlyName, equals('major seventh'));
      });
    });

    group('name', () {
      test('returns full interval name', () {
        expect(Interval.perfectUnison.name, equals('perfect unison'));
        expect(Interval.minorSecond.name, equals('minor 2nd'));
        expect(Interval.majorThird.name, equals('major 3rd'));
        expect(Interval.perfectFourth.name, equals('perfect 4th'));
        expect(Interval.perfectFifth.name, equals('perfect 5th'));
        expect(Interval.perfectOctave.name, equals('perfect octave'));
      });
    });

    group('shortName', () {
      test('returns abbreviated notation', () {
        expect(Interval.perfectUnison.shortName, equals('P1'));
        expect(Interval.minorSecond.shortName, equals('m2'));
        expect(Interval.majorSecond.shortName, equals('M2'));
        expect(Interval.minorThird.shortName, equals('m3'));
        expect(Interval.majorThird.shortName, equals('M3'));
        expect(Interval.perfectFourth.shortName, equals('P4'));
        expect(Interval.augmentedFourth.shortName, equals('A4'));
        expect(Interval.diminishedFifth.shortName, equals('d5'));
        expect(Interval.perfectFifth.shortName, equals('P5'));
        expect(Interval.minorSixth.shortName, equals('m6'));
        expect(Interval.majorSixth.shortName, equals('M6'));
        expect(Interval.minorSeventh.shortName, equals('m7'));
        expect(Interval.majorSeventh.shortName, equals('M7'));
        expect(Interval.perfectOctave.shortName, equals('P8'));
      });
    });

    group('operations', () {
      test('addTo transposes note up', () {
        final c4 = Note.parse('C4');
        final result = Interval.majorThird.addTo(c4);
        expect(result, equals(Note.parse('E4')));
      });

      test('subtractFrom transposes note down', () {
        final e4 = Note.parse('E4');
        final result = Interval.majorThird.subtractFrom(e4);
        expect(result, equals(Note.parse('C4')));
      });
    });

    group('comparison', () {
      test('compares by semitones', () {
        expect(Interval.minorSecond < Interval.majorSecond, isTrue);
        expect(Interval.perfectFifth > Interval.perfectFourth, isTrue);
        expect(Interval.majorThird <= Interval.majorThird, isTrue);
        expect(Interval.perfectFifth >= Interval.perfectFourth, isTrue);
      });

      test('compareTo returns correct ordering', () {
        expect(
            Interval.minorSecond.compareTo(Interval.majorSecond), lessThan(0));
        expect(Interval.perfectFifth.compareTo(Interval.perfectFourth),
            greaterThan(0));
        expect(Interval.majorThird.compareTo(Interval.majorThird), equals(0));
      });
    });

    group('equality', () {
      test('equal intervals are equal', () {
        expect(Interval.majorThird, equals(Interval.majorThird));
        expect(
          const Interval(
              semitones: 4, quality: IntervalQuality.major, number: 3),
          equals(Interval.majorThird),
        );
      });

      test('different semitones are not equal', () {
        expect(Interval.majorThird, isNot(equals(Interval.minorThird)));
      });

      test('same semitones but different quality/number are not equal', () {
        // Augmented 4th and diminished 5th both have 6 semitones
        expect(
            Interval.augmentedFourth, isNot(equals(Interval.diminishedFifth)));
      });
    });

    group('toString', () {
      test('returns name', () {
        expect(Interval.majorThird.toString(), equals('major 3rd'));
        expect(Interval.perfectFifth.toString(), equals('perfect 5th'));
      });
    });

    group('standardIntervals', () {
      test('contains all 13 standard intervals', () {
        expect(Interval.standardIntervals.length, equals(13));
      });

      test('is sorted by semitones', () {
        for (var i = 0; i < Interval.standardIntervals.length - 1; i++) {
          expect(
            Interval.standardIntervals[i].semitones,
            lessThanOrEqualTo(Interval.standardIntervals[i + 1].semitones),
          );
        }
      });
    });
  });

  group('NoteIntervalExtension', () {
    test('intervalTo calculates interval', () {
      final c4 = Note.parse('C4');
      final g4 = Note.parse('G4');
      expect(c4.intervalTo(g4), equals(Interval.perfectFifth));
    });

    test('directedIntervalTo returns signed semitones', () {
      final c4 = Note.parse('C4');
      final g4 = Note.parse('G4');
      expect(c4.directedIntervalTo(g4), equals(7));
      expect(g4.directedIntervalTo(c4), equals(-7));
    });
  });

  group('PitchClassIntervalExtension', () {
    test('semitonesTo calculates ascending interval', () {
      expect(PitchClass.c.semitonesTo(PitchClass.g), equals(7));
      expect(PitchClass.c.semitonesTo(PitchClass.e), equals(4));
    });

    test('semitonesTo wraps around', () {
      expect(PitchClass.g.semitonesTo(PitchClass.c), equals(5)); // G up to C
      expect(PitchClass.b.semitonesTo(PitchClass.c), equals(1)); // B up to C
    });

    test('semitonesTo same pitch is 0', () {
      expect(PitchClass.c.semitonesTo(PitchClass.c), equals(0));
    });
  });
}
