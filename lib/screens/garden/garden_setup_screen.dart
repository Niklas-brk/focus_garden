import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../models/focus_session.dart';
import '../../models/garden_theme.dart';
import '../../models/plant_catalog.dart';
import '../../state/history_provider.dart';
import '../../state/settings_provider.dart';
import '../../widgets/plant_sprite.dart';
import '../premium/premium_screen.dart';
import 'garden_scene_screen.dart';

/// „Garten einrichten": Name vergeben, Hintergrund-Thema wählen und die
/// gesammelten Pflanzen per Ziehen umsortieren. Alles rein lokal (offline).
class GardenSetupScreen extends StatefulWidget {
  const GardenSetupScreen({super.key});

  @override
  State<GardenSetupScreen> createState() => _GardenSetupScreenState();
}

class _GardenSetupScreenState extends State<GardenSetupScreen> {
  late final TextEditingController _nameController;
  SettingsProvider? _settings;

  // Lokale, während des Anordnens stabile Kopie der Garten-Pflanzen.
  late List<FocusSession> _plants;

  @override
  void initState() {
    super.initState();
    final history = context.read<HistoryProvider>();
    _plants = List.of(history.garden);
    _nameController =
        TextEditingController(text: context.read<SettingsProvider>().gardenName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settings = context.read<SettingsProvider>();
  }

  void _saveName() {
    _settings?.gardenName = _nameController.text;
  }

  @override
  void dispose() {
    _saveName();
    _nameController.dispose();
    super.dispose();
  }

  // onReorderItem liefert newIndex bereits um das an oldIndex entfernte
  // Element korrigiert – daher kein manuelles -1 mehr nötig.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _plants.removeAt(oldIndex);
      _plants.insert(newIndex, item);
    });
    context
        .read<HistoryProvider>()
        .setGardenOrder(_plants.map((s) => s.id).toList());
  }

  void _selectTheme(GardenTheme theme) {
    final settings = context.read<SettingsProvider>();
    if (theme.isPremium && !settings.premium) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
      return;
    }
    settings.gardenThemeId = theme.id;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.gardenSetupTitle),
        actions: [
          TextButton(
            onPressed: () {
              _saveName();
              Navigator.of(context).pop();
            },
            child: Text(S.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // --- Als Wallpaper gestalten (Garten-Szene) -------------------
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GardenSceneScreen()),
            ),
            icon: const Icon(Icons.wallpaper_rounded),
            label: Text(S.sceneEntry),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Name -----------------------------------------------------
          _SectionLabel(S.gardenNameLabel),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _saveName(),
            decoration: InputDecoration(
              hintText: S.gardenNameHint,
              filled: true,
              fillColor: scheme.surface,
              prefixIcon: const Icon(Icons.local_florist_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Hintergrund-Thema ---------------------------------------
          _SectionLabel(S.gardenBackground),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: GardenThemes.all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final theme = GardenThemes.all[i];
                return _ThemeSwatch(
                  theme: theme,
                  selected: settings.gardenThemeId == theme.id,
                  locked: theme.isPremium && !settings.premium,
                  onTap: () => _selectTheme(theme),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // --- Pflanzen anordnen ---------------------------------------
          _SectionLabel(S.gardenArrange),
          if (_plants.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                S.gardenArrangeEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 2),
              child: Text(
                S.gardenArrangeHint,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _plants.length,
              onReorderItem: _onReorder,
              itemBuilder: (context, i) {
                final session = _plants[i];
                return _ArrangeTile(
                  key: ValueKey(session.id),
                  index: i,
                  session: session,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final GardenTheme theme;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gradient = theme.gradient;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 92,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 84,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? scheme.primary : Colors.transparent,
                  width: 3,
                ),
                gradient: gradient != null
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: gradient,
                      )
                    : null,
                color: gradient == null ? scheme.surface : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (theme.isDefault)
                    Icon(Icons.wb_sunny_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.5)),
                  if (locked)
                    const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.lock_rounded,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  if (selected)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.check_circle_rounded,
                            size: 20, color: scheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              theme.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrangeTile extends StatelessWidget {
  final int index;
  final FocusSession session;
  const _ArrangeTile({super.key, required this.index, required this.session});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final plant = PlantCatalog.byId(session.plantId);
    final d = session.endTime;
    final date = '${d.day}. ${S.monthNames[d.month - 1]}';

    return Padding(
      key: ValueKey('pad_${session.id}'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            PlantSprite(plant: plant, stage: 4, size: 44),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(plant.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(date,
                      style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(Icons.drag_handle_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
