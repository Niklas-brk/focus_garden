// Eine einzelne Note innerhalb eines Fachs sowie deren Art (z. B. Schulaufgabe,
// Ex …). Mehrere solcher Noten werden pro Fach nach ihrer Art gewichtet zur
// Zeugnisnote verrechnet (bayerische Regel als Standard).

/// Art einer Note. In Bayern zählen Schulaufgaben (große schriftliche Arbeiten)
/// stärker als kleine Nachweise (Kurzarbeiten, Exen, mündliche Noten).
enum GradeKind { schulaufgabe, kurzarbeit, ex, muendlich }

/// Standard-Gewichtung der Noten-Arten. Schulaufgabe = 2, alle kleinen/
/// mündlichen Nachweise = 1 → ergibt die bayerische 2:1-Regel
/// (2·Ø Schulaufgaben + 1·Ø kleine) / 3. Pro Fach überschreibbar.
const Map<GradeKind, double> kDefaultGradeWeights = {
  GradeKind.schulaufgabe: 2,
  GradeKind.kurzarbeit: 1,
  GradeKind.ex: 1,
  GradeKind.muendlich: 1,
};

/// Eine eingetragene Note: ihre [kind] (Art) und der [value] (Punkte 0–15 bzw.
/// Note 1–6, je nach Bewertungssystem des Profils).
class GradeEntry {
  final GradeKind kind;
  final double value;

  const GradeEntry({required this.kind, required this.value});

  Map<String, dynamic> toMap() => {'kind': kind.name, 'value': value};

  factory GradeEntry.fromMap(Map<String, dynamic> m) => GradeEntry(
        kind: _kindFromName(m['kind'] as String?),
        value: (m['value'] as num).toDouble(),
      );

  static GradeKind _kindFromName(String? name) {
    for (final k in GradeKind.values) {
      if (k.name == name) return k;
    }
    return GradeKind.muendlich; // robuster Fallback
  }
}
