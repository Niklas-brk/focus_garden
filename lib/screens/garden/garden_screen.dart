import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../models/focus_session.dart';
import '../../models/garden_theme.dart';
import '../../models/plant_catalog.dart';
import '../../state/history_provider.dart';
import '../../state/settings_provider.dart';
import '../../widgets/plant_sprite.dart';
import 'flex_card_screen.dart';
import 'garden_setup_screen.dart';

/// Garten-Tab: Raster gesammelter Pflanzen mit Wochen-Zusammenfassung,
/// Monatsfilter, Hintergrund-Thema und Flex-Card-Button (Konzept Abschnitt 4).
class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  DateTime? _monthFilter; // null = alle

  String _monthLabel(DateTime m) => '${S.monthNames[m.month - 1]} ${m.year}';

  String _dateLabel(DateTime d) => '${d.day}. ${S.monthNames[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final stats = history.stats;
    final months = history.availableMonths;

    final gTheme = GardenThemes.byId(settings.gardenThemeId);
    final tileColor = gTheme.tileColor ?? scheme.surface;
    final onColor = gTheme.onColor ?? scheme.onSurface;

    var garden = history.garden;
    if (_monthFilter != null) {
      garden = garden
          .where((s) =>
              s.endTime.year == _monthFilter!.year &&
              s.endTime.month == _monthFilter!.month)
          .toList();
    }

    final content = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _WeekSummary(
              minutes: stats.weekMinutes,
              plants: stats.weekBlooms,
              tileColor: tileColor,
              onColor: onColor,
            ),
          ),
        ),
        if (months.isNotEmpty)
          SliverToBoxAdapter(
            child: _MonthFilterBar(
              months: months,
              selected: _monthFilter,
              labelBuilder: _monthLabel,
              onSelected: (m) => setState(() => _monthFilter = m),
              tileColor: tileColor,
              onColor: onColor,
            ),
          ),
        if (garden.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyGarden(onColor: onColor),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _GardenTile(
                  session: garden[i],
                  dateLabel: _dateLabel(garden[i].endTime),
                  tileColor: tileColor,
                  onColor: onColor,
                ),
                childCount: garden.length,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: _GardenAction(
                    icon: Icons.tune_rounded,
                    label: S.gardenSetup,
                    onColor: onColor,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const GardenSetupScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GardenAction(
                    icon: Icons.ios_share_rounded,
                    label: S.createFlexCard,
                    onColor: onColor,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FlexCardScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    // Hintergrund-Thema: Verlauf hinter den Garten legen. „Standard" (kein
    // Verlauf) zeigt den normalen App-Hintergrund.
    if (gTheme.gradient == null) return content;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gTheme.gradient!,
        ),
      ),
      child: content,
    );
  }
}

class _WeekSummary extends StatelessWidget {
  final int minutes;
  final int plants;
  final Color tileColor;
  final Color onColor;
  const _WeekSummary({
    required this.minutes,
    required this.plants,
    required this.tileColor,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.weekSummary,
                    style: TextStyle(
                        color: onColor.withValues(alpha: 0.6), fontSize: 13)),
                const SizedBox(height: 4),
                Text('$minutes ${S.minutesShort}',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: onColor)),
              ],
            ),
          ),
          Column(
            children: [
              Text('$plants',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary)),
              Text(S.plantsCount,
                  style: TextStyle(
                      color: onColor.withValues(alpha: 0.6), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthFilterBar extends StatelessWidget {
  final List<DateTime> months;
  final DateTime? selected;
  final String Function(DateTime) labelBuilder;
  final ValueChanged<DateTime?> onSelected;
  final Color tileColor;
  final Color onColor;

  const _MonthFilterBar({
    required this.months,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
    required this.tileColor,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: S.filterAll,
            selected: selected == null,
            onTap: () => onSelected(null),
            tileColor: tileColor,
            onColor: onColor,
          ),
          for (final m in months)
            _Chip(
              label: labelBuilder(m),
              selected: selected != null &&
                  selected!.year == m.year &&
                  selected!.month == m.month,
              onTap: () => onSelected(m),
              tileColor: tileColor,
              onColor: onColor,
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color tileColor;
  final Color onColor;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.tileColor,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? scheme.primary : tileColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? scheme.onPrimary : onColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GardenTile extends StatelessWidget {
  final FocusSession session;
  final String dateLabel;
  final Color tileColor;
  final Color onColor;
  const _GardenTile({
    required this.session,
    required this.dateLabel,
    required this.tileColor,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    final plant = PlantCatalog.byId(session.plantId);
    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlantSprite(plant: plant, stage: 4, size: 74),
          const SizedBox(height: 2),
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 11,
              color: onColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aktion unten im Garten (Einrichten / Flex-Card) – liest auf jedem
/// Hintergrund-Thema durch die durchgereichte [onColor].
class _GardenAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color onColor;
  final VoidCallback onPressed;
  const _GardenAction({
    required this.icon,
    required this.label,
    required this.onColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: onColor,
        side: BorderSide(color: onColor.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _EmptyGarden extends StatelessWidget {
  final Color onColor;
  const _EmptyGarden({required this.onColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_florist_outlined,
                size: 64, color: onColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              S.gardenEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: onColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
