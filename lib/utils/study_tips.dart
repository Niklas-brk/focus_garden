import '../l10n/app_strings.dart';

/// Fach-Kategorie für die Lerntipps. Wird per Schlüsselwort aus dem frei
/// eingegebenen Fach-/Modulnamen erkannt ([StudyTips.categoryOf]);
/// [allgemein] ist der Rückfall für alles Unbekannte (Kunst, Sport …).
enum TipCategory {
  mathe,
  deutsch,
  sprache,
  nawi,
  gesellschaft,
  informatik,
  allgemein,
}

/// Reine, testbare Tipp-Logik: erkennt am Fach-Namen die Kategorie und
/// liefert daraus fachspezifische Lerntipps (Texte in [S], zweisprachig).
class StudyTips {
  /// Schlüsselwörter je Kategorie, Reihenfolge = Priorität (die erste
  /// passende Kategorie gewinnt): „Geometrie" muss vor dem „geo" der
  /// Gesellschafts-Fächer geprüft werden, „Rechtschreiben" vor „recht",
  /// „Italienisch" vor dem „it" der Informatik – und Komposita wie
  /// „Wirtschaftsinformatik" vor „wirtschaft".
  static const List<(TipCategory, List<String>)> _keywords = [
    (
      TipCategory.mathe,
      [
        'mathe', 'math', 'algebra', 'analysis', 'geometrie', 'geometry',
        'stochastik', 'statistik', 'statistics', 'calculus', 'rechnen',
      ],
    ),
    (
      TipCategory.deutsch,
      ['deutsch', 'german', 'literatur', 'literature', 'rechtschreib'],
    ),
    (
      TipCategory.sprache,
      [
        'englisch', 'english', 'französisch', 'franz', 'french',
        'latein', 'latin', 'spanisch', 'spanish', 'italienisch', 'italian',
        'russisch', 'russian', 'chinesisch', 'chinese', 'japanisch',
        'japanese', 'türkisch', 'turkish', 'vokabel', 'sprach', 'language',
      ],
    ),
    (
      TipCategory.informatik,
      [
        'informatik', 'informatics', 'info', 'computer', 'programmier',
        'programming', 'coding', 'code', 'software', 'python', 'java',
        'it', 'edv',
      ],
    ),
    (
      TipCategory.nawi,
      [
        'bio', 'chem', 'physik', 'physics', 'science', 'nawi',
        'naturwissenschaft', 'astro',
      ],
    ),
    (
      TipCategory.gesellschaft,
      [
        'geschichte', 'history', 'geo', 'erdkunde', 'geograph', 'politik',
        'politic', 'sozial', 'sowi', 'wirtschaft', 'bwl', 'vwl', 'econom',
        'ethik', 'ethic', 'reli', 'philo', 'recht', 'jura', 'law',
        'psycho', 'pädagog',
      ],
    ),
  ];

  /// Erkennt die Kategorie eines Fach-/Modulnamens. Ein Schlüsselwort passt,
  /// wenn ein Namens-Token damit BEGINNT („Mathe" → „Mathematik") oder –
  /// ab 5 Zeichen – darin vorkommt (deutsche Komposita:
  /// „Wirtschaftsinformatik" enthält „informatik").
  static TipCategory categoryOf(String subjectName) {
    final tokens = subjectName
        .toLowerCase()
        .split(RegExp(r'[^a-zäöüß]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    for (final (category, keywords) in _keywords) {
      for (final keyword in keywords) {
        for (final token in tokens) {
          final match = token.startsWith(keyword) ||
              (keyword.length >= 5 && token.contains(keyword));
          if (match) return category;
        }
      }
    }
    return TipCategory.allgemein;
  }

  /// Die Tipp-Liste einer Kategorie (aktive Sprache).
  static List<String> tipsOf(TipCategory category) {
    switch (category) {
      case TipCategory.mathe:
        return S.tipsMath;
      case TipCategory.deutsch:
        return S.tipsGerman;
      case TipCategory.sprache:
        return S.tipsLanguage;
      case TipCategory.nawi:
        return S.tipsScience;
      case TipCategory.gesellschaft:
        return S.tipsSociety;
      case TipCategory.informatik:
        return S.tipsInformatics;
      case TipCategory.allgemein:
        return S.tipsGeneral;
    }
  }

  /// Tipp für ein Fach. [index] wählt (modulo Listenlänge) den Tipp aus –
  /// z. B. Tag des Jahres plus „Nächster Tipp"-Klicks für tägliche Rotation.
  static String tipFor(String subjectName, int index) {
    final tips = tipsOf(categoryOf(subjectName));
    return tips[index % tips.length];
  }
}
