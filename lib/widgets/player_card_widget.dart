import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../theme/palette.dart';
import '../theme/app_theme.dart';
import 'follower_progress_bar.dart';

/// A single scoreboard row — used inside a RuledPanel, never its own card.
class PlayerCardWidget extends StatelessWidget {
  final Player player;
  final bool isUploader;
  final bool isAccuser;
  final bool isCurrentTurn;
  final int rank;

  const PlayerCardWidget({
    super.key,
    required this.player,
    this.isUploader = false,
    this.isAccuser = false,
    this.isCurrentTurn = false,
    this.rank = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              color: isCurrentTurn
                  ? p.brand
                  : p.brand.withValues(alpha: 0.14),
              alignment: Alignment.center,
              child: Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isCurrentTurn ? p.bandInk : p.brand,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (rank > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            '#$rank',
                            style: context.mono(fontSize: 11, color: p.inkSoft),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          player.name,
                          style: context.body.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${player.followers} Followers',
                        style: context.bodySoft.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      if (player.totalCards > 0) ...[
                        _tally(context, Icons.check_circle_outline, p.success,
                            player.credibleCount),
                        const SizedBox(width: 6),
                        _tally(context, Icons.cancel_outlined, p.crimson,
                            player.violationCount),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (player.shadowbanned)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    color: p.crimson.withValues(alpha: 0.16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_off, size: 10, color: p.crimson),
                        const SizedBox(width: 3),
                        Text(
                          'SHADOWBAN',
                          style: context.mono(fontSize: 9, color: p.crimson),
                        ),
                      ],
                    ),
                  ),
                if (isUploader) ...[
                  const SizedBox(height: 4),
                  _roleBadge(context, 'UPLOADER', p.brand),
                ],
                if (isAccuser) ...[
                  const SizedBox(height: 4),
                  _roleBadge(context, 'PENUDUH', p.warning),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        FollowerProgressBar(followers: player.followers),
      ],
    );
  }

  Widget _tally(BuildContext context, IconData icon, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text('$count', style: context.mono(fontSize: 11, color: color)),
      ],
    );
  }

  Widget _roleBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: color.withValues(alpha: 0.16),
      child: Text(label, style: context.mono(fontSize: 9, color: color)),
    );
  }
}
