import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Maps the backend's fixed `Avatar` enum (`FOX`/`OWL`/`ROBOT`/`ASTRONAUT`/`DRAGON`) to a
/// recognizable icon and a distinct color from the Nova palette — not a drawn character, but
/// crisp, instantly recognizable, and consistent with the icon-in-a-colored-circle language
/// already used for subjects elsewhere in the app.
class AvatarIcon extends StatelessWidget {
  const AvatarIcon({super.key, required this.avatar, this.size = 48});
  final String avatar;
  final double size;

  static const Map<String, (IconData, Color)> _avatars = <String, (IconData, Color)>{
    'FOX': (Icons.pets_rounded, AppTheme.novaOrange),
    'OWL': (Icons.nightlight_round, AppTheme.cosmicViolet),
    'ROBOT': (Icons.smart_toy_rounded, Color(0xff2563eb)),
    'ASTRONAUT': (Icons.rocket_launch_rounded, AppTheme.novaPink),
    'DRAGON': (Icons.whatshot_rounded, Color(0xff12883e)),
  };

  static String label(String avatar) => switch (avatar) {
        'FOX' => 'Fox',
        'OWL' => 'Owl',
        'ROBOT' => 'Robot',
        'ASTRONAUT' => 'Astronaut',
        'DRAGON' => 'Dragon',
        _ => avatar,
      };

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = _avatars[avatar] ?? _avatars['FOX']!;
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12)],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.52));
  }
}
