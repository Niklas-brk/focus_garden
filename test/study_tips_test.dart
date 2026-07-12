import 'package:flutter_test/flutter_test.dart';

import 'package:focus_garden/utils/study_tips.dart';

void main() {
  group('Kategorie-Erkennung', () {
    test('Mathe (auch Uni-Module)', () {
      expect(StudyTips.categoryOf('Mathe'), TipCategory.mathe);
      expect(StudyTips.categoryOf('Mathematik'), TipCategory.mathe);
      expect(StudyTips.categoryOf('Analysis 2'), TipCategory.mathe);
      expect(StudyTips.categoryOf('Lineare Algebra'), TipCategory.mathe);
      expect(StudyTips.categoryOf('Statistik'), TipCategory.mathe);
      // „Geometrie" beginnt mit „geo" – darf NICHT bei Erdkunde landen.
      expect(StudyTips.categoryOf('Geometrie'), TipCategory.mathe);
    });

    test('Deutsch vor Fremdsprachen', () {
      expect(StudyTips.categoryOf('Deutsch'), TipCategory.deutsch);
      expect(StudyTips.categoryOf('Deutsch LK'), TipCategory.deutsch);
      expect(StudyTips.categoryOf('German'), TipCategory.deutsch);
      // „Rechtschreiben" (Grundschule) darf nicht beim „recht" der
      // Gesellschafts-Fächer landen.
      expect(StudyTips.categoryOf('Rechtschreiben'), TipCategory.deutsch);
    });

    test('Fremdsprachen', () {
      expect(StudyTips.categoryOf('Englisch'), TipCategory.sprache);
      expect(StudyTips.categoryOf('English'), TipCategory.sprache);
      expect(StudyTips.categoryOf('Französisch'), TipCategory.sprache);
      expect(StudyTips.categoryOf('Latein'), TipCategory.sprache);
      expect(StudyTips.categoryOf('Spanisch'), TipCategory.sprache);
      // „Italienisch" beginnt mit „it" – darf nicht bei Informatik landen.
      expect(StudyTips.categoryOf('Italienisch'), TipCategory.sprache);
    });

    test('Naturwissenschaften', () {
      expect(StudyTips.categoryOf('Bio'), TipCategory.nawi);
      expect(StudyTips.categoryOf('Biologie'), TipCategory.nawi);
      expect(StudyTips.categoryOf('Chemie'), TipCategory.nawi);
      expect(StudyTips.categoryOf('Physik'), TipCategory.nawi);
    });

    test('Gesellschaftsfächer', () {
      expect(StudyTips.categoryOf('Geschichte'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('Geo'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('Erdkunde'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('Geographie'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('Sozialkunde'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('Wirtschaft'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('Religion'), TipCategory.gesellschaft);
      // Gängige Kurzformen und Uni-Fächer.
      expect(StudyTips.categoryOf('Reli'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('BWL'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('Jura'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('Philosophie'), TipCategory.gesellschaft);
      expect(StudyTips.categoryOf('Psychologie'), TipCategory.gesellschaft);
    });

    test('Informatik (auch Komposita)', () {
      expect(StudyTips.categoryOf('Informatik'), TipCategory.informatik);
      expect(StudyTips.categoryOf('Info'), TipCategory.informatik);
      expect(StudyTips.categoryOf('Programmieren 1'), TipCategory.informatik);
      expect(StudyTips.categoryOf('IT'), TipCategory.informatik);
      expect(
        StudyTips.categoryOf('Wirtschaftsinformatik'),
        TipCategory.informatik,
      );
    });

    test('Unbekanntes fällt auf Allgemein zurück', () {
      expect(StudyTips.categoryOf('Kunst'), TipCategory.allgemein);
      expect(StudyTips.categoryOf('Sport'), TipCategory.allgemein);
      expect(StudyTips.categoryOf('Werken'), TipCategory.allgemein);
      expect(StudyTips.categoryOf('Musik'), TipCategory.allgemein);
      // Kein Kurz-Schlüsselwort-Fehltreffer („it" in „Arbeit" o. Ä.).
      expect(StudyTips.categoryOf('Arbeitslehre'), TipCategory.allgemein);
    });
  });

  group('Tipp-Auswahl', () {
    test('jede Kategorie hat mehrere, nicht-leere Tipps', () {
      for (final category in TipCategory.values) {
        final tips = StudyTips.tipsOf(category);
        expect(tips.length, greaterThanOrEqualTo(3),
            reason: 'Kategorie $category hat zu wenige Tipps');
        for (final tip in tips) {
          expect(tip.trim(), isNotEmpty);
        }
      }
    });

    test('Index rotiert modulo Listenlänge', () {
      final tips = StudyTips.tipsOf(TipCategory.mathe);
      expect(StudyTips.tipFor('Mathe', 0), tips.first);
      expect(StudyTips.tipFor('Mathe', tips.length), tips.first);
      expect(StudyTips.tipFor('Mathe', 1), tips[1]);
    });
  });
}
