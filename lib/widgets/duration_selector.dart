import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../state/session_provider.dart';

/// Auswahl der Fokusdauer: 4 Presets + freie Eingabe 10–180 Min
/// (Konzept Abschnitt 3).
class DurationSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const DurationSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  bool get _isCustom => !SessionProvider.presets.contains(selected);

  Future<void> _pickCustom(BuildContext context) async {
    var value = _isCustom ? selected : 30;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(S.customDuration),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value ${S.minutesShort}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Slider(
                value: value.toDouble(),
                min: SessionProvider.minCustom.toDouble(),
                max: SessionProvider.maxCustom.toDouble(),
                divisions:
                    SessionProvider.maxCustom - SessionProvider.minCustom,
                label: '$value',
                onChanged: (v) => setState(() => value = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(S.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, value),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (result != null) onSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final preset in SessionProvider.presets)
          _Pill(
            label: '$preset',
            sub: S.minutesShort,
            selected: selected == preset,
            onTap: () => onSelected(preset),
          ),
        _Pill(
          label: _isCustom ? '$selected' : S.customDuration,
          sub: _isCustom ? S.minutesShort : null,
          icon: _isCustom ? null : Icons.tune_rounded,
          selected: _isCustom,
          onTap: () => _pickCustom(context),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String? sub;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.sub,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          constraints: const BoxConstraints(minWidth: 64),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 18,
                    color: selected ? scheme.onPrimary : scheme.onSurface),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
              if (sub != null) ...[
                const SizedBox(width: 4),
                Text(
                  sub!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: (selected ? scheme.onPrimary : scheme.onSurface)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
