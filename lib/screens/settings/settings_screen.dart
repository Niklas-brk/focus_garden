import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../services/blocker_service.dart';
import '../../services/purchase_service.dart';
import '../../state/history_provider.dart';
import '../../state/settings_provider.dart';
import '../premium/premium_screen.dart';

/// Einstellungen (modal), Konzept Abschnitt 3.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Fokus-Schild ein-/ausschalten. Beim Einschalten muss die Berechtigung
  /// „Über anderen Apps anzeigen" erteilt sein, sonst bleibt der Schalter aus.
  Future<void> _onBlockerChanged(BuildContext context, bool value) async {
    final settings = context.read<SettingsProvider>();
    final blocker = context.read<BlockerService>();
    final messenger = ScaffoldMessenger.of(context);

    if (!value) {
      settings.blockerOn = false;
      await blocker.hideShield();
      return;
    }

    final granted =
        await blocker.hasPermission() || await blocker.requestPermission();
    if (granted) {
      settings.blockerOn = true;
    } else {
      settings.blockerOn = false;
      messenger.showSnackBar(
        const SnackBar(content: Text(S.blockerPermDenied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PremiumSection(premium: settings.premium),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(S.strictMode),
                  subtitle: Text(
                    S.strictModeHint,
                    style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12),
                  ),
                  value: settings.strictMode,
                  onChanged: (v) => settings.strictMode = v,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text(S.blocker),
                  subtitle: Text(
                    S.blockerHint,
                    style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12),
                  ),
                  value: settings.blockerOn,
                  onChanged: (v) => _onBlockerChanged(context, v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text(S.sounds),
                  value: settings.soundsOn,
                  onChanged: (v) => settings.soundsOn = v,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text(S.haptics),
                  value: settings.hapticsOn,
                  onChanged: (v) => settings.hapticsOn = v,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(S.appearance,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          _Card(
            child: Column(
              children: [
                _ThemeOption(
                  label: S.themeDark,
                  icon: Icons.dark_mode_rounded,
                  value: ThemeMode.dark,
                  group: settings.themeMode,
                  onSelected: (m) => settings.themeMode = m,
                ),
                const Divider(height: 1),
                _ThemeOption(
                  label: S.themeLight,
                  icon: Icons.light_mode_rounded,
                  value: ThemeMode.light,
                  group: settings.themeMode,
                  onSelected: (m) => settings.themeMode = m,
                ),
                const Divider(height: 1),
                _ThemeOption(
                  label: S.themeSystem,
                  icon: Icons.smartphone_rounded,
                  value: ThemeMode.system,
                  group: settings.themeMode,
                  onSelected: (m) => settings.themeMode = m,
                ),
              ],
            ),
          ),
          // Nur im Debug-Build: Werkzeuge zum Erzeugen von Store-Screenshots.
          // Im Release komplett wegkompiliert.
          if (kDebugMode) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text('[Debug] Screenshot-Werkzeuge',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
            _Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.auto_awesome_rounded),
                    title: const Text('Beispieldaten laden'),
                    subtitle: const Text('Garten + Statistik mit Demo füllen',
                        style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      await context.read<HistoryProvider>().seedSampleData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Beispieldaten geladen')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.workspace_premium_rounded),
                    title: const Text('Premium (Debug)'),
                    value: settings.premium,
                    onChanged: (_) => settings.debugTogglePremium(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Premium-Kachel oben in den Einstellungen: Upsell (mit „Wiederherstellen")
/// bzw. Aktiv-Hinweis (Konzept Abschnitt 7).
class _PremiumSection extends StatelessWidget {
  final bool premium;
  const _PremiumSection({required this.premium});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (premium) {
      return _Card(
        child: ListTile(
          leading: Icon(Icons.verified_rounded, color: scheme.primary),
          title: const Text(S.premiumActiveTitle),
          subtitle: Text(
            S.premiumActiveBody,
            style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
          ),
        ),
      );
    }

    return _Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.workspace_premium_rounded,
                color: scheme.primary),
            title: const Text(S.premiumUpsell),
            subtitle: Text(
              S.premiumUpsellHint,
              style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: const Text(S.premiumRestore),
            onTap: () {
              context.read<PurchaseService>().restore();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(S.premiumRestoreStarted)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode group;
  final ValueChanged<ThemeMode> onSelected;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.group,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = value == group;
    return ListTile(
      leading: Icon(icon, color: selected ? scheme.primary : null),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: scheme.primary)
          : const Icon(Icons.circle_outlined),
      onTap: () => onSelected(value),
    );
  }
}
