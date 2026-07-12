import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../state/history_provider.dart';
import '../../utils/stats.dart';

/// Statistik-Tab: Streak, Kennzahlen und 7-Tage-Diagramm (Konzept Abschnitt 3).
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<HistoryProvider>().stats;
    final bars = stats.last7Days();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StreakCard(streak: stats.streak),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: S.today,
                minutes: stats.todayMinutes,
                sessions: stats.todaySessions,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: S.week,
                minutes: stats.weekMinutes,
                sessions: stats.weekSessions,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: S.total,
                minutes: stats.totalMinutes,
                sessions: stats.totalSessions,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _WeekChart(bars: bars),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text('🔥', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.streak,
                  style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                S.streakDays(streak),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int minutes;
  final int sessions;

  const _StatCard({
    required this.label,
    required this.minutes,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('$minutes',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800)),
          Text(S.minutesShort,
              style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 11)),
          const SizedBox(height: 6),
          Text('$sessions ${S.sessions}',
              style: TextStyle(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  final List<DayBar> bars;
  const _WeekChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxMinutes =
        bars.map((b) => b.minutes).fold<int>(0, (m, v) => v > m ? v : m);
    final maxScale = maxMinutes < 25 ? 25 : maxMinutes;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.last7days,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bar in bars)
                  Expanded(
                    child: _Bar(
                      bar: bar,
                      fraction: bar.minutes / maxScale,
                      color: bar.isToday
                          ? scheme.primary
                          : scheme.primary.withValues(alpha: 0.45),
                      labelColor: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final DayBar bar;
  final double fraction;
  final Color color;
  final Color labelColor;

  const _Bar({
    required this.bar,
    required this.fraction,
    required this.color,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (bar.minutes > 0)
          Text('${bar.minutes}',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: labelColor)),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, value, _) => Container(
            height: (value * 96) + 4,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(bar.label,
            style: TextStyle(fontSize: 11, color: labelColor)),
      ],
    );
  }
}
