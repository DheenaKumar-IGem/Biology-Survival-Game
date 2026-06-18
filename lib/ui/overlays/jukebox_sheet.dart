import 'package:flutter/material.dart';

import '../../services/audio_service.dart';
import '../../services/music_library.dart';
import '../../services/settings_service.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// Opens the jukebox: pick a background track (or Off). Selecting a track
/// switches the music live and persists the choice; the sheet stays open so the
/// player can audition before closing.
Future<void> showJukebox(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _JukeboxSheet(),
  );
}

class _JukeboxSheet extends StatefulWidget {
  const _JukeboxSheet();

  @override
  State<_JukeboxSheet> createState() => _JukeboxSheetState();
}

class _JukeboxSheetState extends State<_JukeboxSheet> {
  late final Future<List<MusicTrack>> _tracks = discoverMusicTracks();

  Future<void> _select(MusicTrack track) async {
    await SettingsService.instance.update(
      (s) => s.copyWith(musicTrackId: track.id),
    );
    await AudioService.instance.applySelectedMusic();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
          decoration: BoxDecoration(
            gradient: AppPalette.backgroundGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppPalette.surfaceLight.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 8, 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.music_note,
                      color: AppPalette.playerCore,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Jukebox', style: AppTypography.displayMedium),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppPalette.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pick the music you want - it changes right away.',
                    style: AppTypography.label,
                  ),
                ),
              ),
              Flexible(
                child: FutureBuilder<List<MusicTrack>>(
                  future: _tracks,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final tracks = snap.data!;
                    return ValueListenableBuilder<SettingsData>(
                      valueListenable: SettingsService.instance,
                      builder: (context, settings, _) {
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 2, 12, 14),
                          shrinkWrap: true,
                          itemCount: tracks.length,
                          itemBuilder: (context, i) {
                            final track = tracks[i];
                            return _TrackRow(
                              track: track,
                              selected: track.id == settings.musicTrackId,
                              onTap: () => _select(track),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.track,
    required this.selected,
    required this.onTap,
  });

  final MusicTrack track;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = track.isOff
        ? AppPalette.textSecondary
        : AppPalette.playerCore;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected
            ? accent.withValues(alpha: 0.14)
            : AppPalette.backgroundDeep.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.8)
                    : AppPalette.surfaceLight.withValues(alpha: 0.6),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  track.isOff ? Icons.music_off : Icons.music_note,
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(track.label, style: AppTypography.bodyStrong),
                ),
                if (selected)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        track.isOff ? Icons.check : Icons.play_arrow,
                        color: accent,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        track.isOff ? 'Selected' : 'Playing',
                        style: AppTypography.label.copyWith(color: accent),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
