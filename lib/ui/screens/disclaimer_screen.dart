import 'package:flutter/material.dart';

import '../../services/persistence_service.dart';
import '../../services/settings_service.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/glow_button.dart';

/// Plain-language disclaimer shown for a game that teaches kids about a serious
/// illness and a not-yet-real diagnostic test. Reachable any time from the home
/// menu and Settings, and surfaced once on first launch (see
/// [showFirstRunIntro]).
const String kDisclaimerBody =
    'PDAC Immune Defense is an educational game made to help you learn how the '
    'immune system works and how scientists study pancreatic cancer. It is NOT '
    'medical advice.\n\n'
    'The saliva ("spit") test for catching pancreatic cancer early is a real '
    'research idea that scientists are still studying - it is not a test you can '
    'get today. Real cancer is complicated, and this game keeps things simple so '
    'the science is fun to learn.\n\n'
    'If you ever feel worried about your health, or someone you care about, talk '
    'to a trusted adult or a doctor.\n\n'
    'This game does not use real money - all "gold" is earned by playing.';

/// A standalone, scrollable disclaimer / about page.
class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.backgroundDeep,
      appBar: AppBar(
        title: Text('About & Safety', style: AppTypography.headline),
        backgroundColor: AppPalette.backgroundTissue,
        iconTheme: const IconThemeData(color: AppPalette.textPrimary),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A quick note before you play',
                  style: AppTypography.headline,
                ),
                const SizedBox(height: 16),
                Text(kDisclaimerBody, style: AppTypography.body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One-time first-run intro: the disclaimer plus quick accessibility/sound
/// toggles, so the strong accessibility features aren't buried for the kids who
/// need them. Marks [PersistenceService.setDisclaimerSeen] on dismissal.
Future<void> showFirstRunIntro(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _FirstRunIntroDialog(),
  );
  await PersistenceService.instance.setDisclaimerSeen(true);
}

class _FirstRunIntroDialog extends StatelessWidget {
  const _FirstRunIntroDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppPalette.backgroundTissue,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome!', style: AppTypography.headline),
              const SizedBox(height: 12),
              Text(kDisclaimerBody, style: AppTypography.body),
              const SizedBox(height: 20),
              Text('How do you want to play?', style: AppTypography.bodyStrong),
              const SizedBox(height: 4),
              Text(
                'You can change these any time in Settings.',
                style: AppTypography.label,
              ),
              const SizedBox(height: 8),
              const _QuickToggles(),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: GlowButton(
                  label: "Let's go",
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickToggles extends StatelessWidget {
  const _QuickToggles();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SettingsData>(
      valueListenable: SettingsService.instance,
      builder: (context, settings, _) {
        return Column(
          children: [
            _IntroToggle(
              icon: Icons.format_size,
              title: 'Larger text',
              value: settings.textScale > 1.0,
              onChanged: (on) => SettingsService.instance.update(
                (s) => s.copyWith(textScale: on ? 1.3 : 1.0),
              ),
            ),
            _IntroToggle(
              icon: Icons.category_outlined,
              title: 'Shape labels on enemies',
              subtitle: 'Read enemy type by shape, not just color',
              value: settings.shapeLabels,
              onChanged: (on) => SettingsService.instance.update(
                (s) => s.copyWith(shapeLabels: on),
              ),
            ),
            _IntroToggle(
              icon: Icons.motion_photos_off,
              title: 'Reduce motion',
              value: settings.reduceMotion,
              onChanged: (on) => SettingsService.instance.update(
                (s) => s.copyWith(reduceMotion: on),
              ),
            ),
            _IntroToggle(
              icon: Icons.volume_off,
              title: 'Mute all sound',
              value: settings.muteAll,
              onChanged: (on) => SettingsService.instance.update(
                (s) => s.copyWith(muteAll: on),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A themed first-run toggle row matching the Settings screen's switch style
/// (icon + bodyStrong label + player-core thumb), so the very first screen a
/// new student sees looks like the same app as everything after it.
class _IntroToggle extends StatelessWidget {
  const _IntroToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppPalette.textSecondary, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.bodyStrong),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTypography.label),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppPalette.playerCore,
          ),
        ],
      ),
    );
  }
}
