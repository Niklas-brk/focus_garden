import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../models/plant_catalog.dart';
import '../../state/settings_provider.dart';
import '../../widgets/plant_sprite.dart';

/// Kurzes Onboarding: 3 Screens, jederzeit überspringbar (Konzept Abschnitt 3).
///
/// Erklärt in drei Schritten den Kern-Loop – Fokus lässt Pflanzen wachsen,
/// App verlassen lässt sie verwelken, Erfolge landen im Garten. Beim Beenden
/// oder Überspringen merkt sich der [SettingsProvider], dass es erledigt ist.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.read<SettingsProvider>().completeOnboarding();

  void _next() {
    if (_index >= _pageCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLast = _index == _pageCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Kopfzeile: „Überspringen" (auf der letzten Seite ausgeblendet).
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: isLast ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: isLast ? null : _finish,
                  child: const Text(S.onboardSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [
                  _OnboardPage(
                    illustration: _WelcomeArt(),
                    title: S.onboard1Title,
                    body: S.onboard1Body,
                  ),
                  _OnboardPage(
                    illustration: _WiltArt(),
                    title: S.onboard2Title,
                    body: S.onboard2Body,
                  ),
                  _OnboardPage(
                    illustration: _GardenArt(),
                    title: S.onboard3Title,
                    body: S.onboard3Body,
                  ),
                ],
              ),
            ),
            // Punkte-Anzeige.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pageCount, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(isLast ? S.onboardStart : S.onboardNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Einheitliches Seitenlayout: große Illustration, Titel, Beschreibung.
class _OnboardPage extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String body;

  const _OnboardPage({
    required this.illustration,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration,
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Runder, sanft getönter Hintergrund für die Illustrationen.
class _ArtDisc extends StatelessWidget {
  final Widget child;
  const _ArtDisc({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 220,
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primary.withValues(alpha: 0.12),
      ),
      child: child,
    );
  }
}

class _WelcomeArt extends StatelessWidget {
  const _WelcomeArt();

  @override
  Widget build(BuildContext context) {
    return _ArtDisc(
      child: PlantSprite(
        plant: PlantCatalog.byId('p04'), // Sonnenblume, hell & freundlich
        stage: 4,
        size: 170,
      ),
    );
  }
}

class _WiltArt extends StatelessWidget {
  const _WiltArt();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _ArtDisc(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          PlantSprite(
            plant: PlantCatalog.byId('p01'),
            stage: 4,
            wilted: true,
            size: 170,
          ),
          // Hinweis-Abzeichen: „Handy weg" als Ursache des Verwelkens.
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.error,
              ),
              child: const Icon(
                Icons.phonelink_erase_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenArt extends StatelessWidget {
  const _GardenArt();

  @override
  Widget build(BuildContext context) {
    // Mini-Garten aus den vier Gratis-Pflanzen in voller Blüte.
    return _ArtDisc(
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          for (final plant in PlantCatalog.free)
            PlantSprite(plant: plant, stage: 4, size: 76),
        ],
      ),
    );
  }
}
