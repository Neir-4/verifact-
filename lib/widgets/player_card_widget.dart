import 'package:flutter/material.dart';
import '../models/player_model.dart';
import 'follower_progress_bar.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? const Color(0xFF162D93).withValues(alpha: 0.4)
            : const Color(0xFF1A1953),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrentTurn
              ? const Color(0xFF162D93)
              : Colors.white12,
          width: isCurrentTurn ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with initial
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF162D93),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  player.name.isNotEmpty
                      ? player.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFABD2FB),
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
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '#$rank',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFABD2FB),
                              ),
                            ),
                          ),
                        Flexible(
                          child: Text(
                            player.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFDF9F1),
                            ),
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Jejak Digital mini tally
                        if (player.totalCards > 0) ...[
                          _tally(
                            Icons.check_circle_outline,
                            Colors.green.shade400,
                            player.credibleCount,
                          ),
                          const SizedBox(width: 6),
                          _tally(
                            Icons.cancel_outlined,
                            Colors.red.shade400,
                            player.violationCount,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Badges (right side)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (player.shadowbanned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade900,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: Colors.deepPurple.shade400, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_off,
                              size: 10, color: Colors.deepPurple.shade200),
                          const SizedBox(width: 3),
                          Text(
                            'Shadowban',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade200,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isUploader) ...[
                    const SizedBox(height: 4),
                    _roleBadge('UPLOADER', const Color(0xFF162D93)),
                  ],
                  if (isAccuser) ...[
                    const SizedBox(height: 4),
                    _roleBadge('PENUDUH', Colors.orange.shade800),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          FollowerProgressBar(followers: player.followers),
        ],
      ),
    );
  }

  Widget _tally(IconData icon, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _roleBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color == const Color(0xFF162D93)
              ? const Color(0xFFABD2FB)
              : Colors.white,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
