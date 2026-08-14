import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MusicApp {
  final String name;
  final String scheme;
  final String icon;

  const MusicApp({
    required this.name,
    required this.scheme,
    required this.icon,
  });
}

class MusicLauncherService {
  static const List<MusicApp> supportedApps = [
    MusicApp(name: 'Spotify', scheme: 'spotify', icon: '🎵'),
    MusicApp(name: 'YouTube Music', scheme: 'youtubemusic', icon: '▶️'),
    MusicApp(name: 'Apple Music', scheme: 'music', icon: '🍎'),
    MusicApp(name: 'Amazon Music', scheme: 'amznmp3', icon: '🛒'),
    MusicApp(name: 'JioSaavn', scheme: 'jiosaavn', icon: '🎧'),
    MusicApp(name: 'Wynk Music', scheme: 'wynk', icon: '🎶'),
  ];

  /// Checks which of the supported apps are actually installed on the device.
  Future<List<MusicApp>> getInstalledApps() async {
    List<MusicApp> installed = [];
    for (var app in supportedApps) {
      // Testing with basic action prefix depending on platform convention.
      // E.g. 'spotify://'
      final uri = Uri.parse('${app.scheme}://');
      if (await canLaunchUrl(uri)) {
        installed.add(app);
      }
    }
    return installed;
  }

  /// Launch the search intent for a specific music app.
  Future<void> launchAppSearch(MusicApp app, String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    Uri launchUri;

    switch (app.scheme) {
      case 'spotify':
        launchUri = Uri.parse('spotify:search:$encodedQuery');
        break;
      case 'youtubemusic':
        launchUri = Uri.parse('youtubemusic://search?q=$encodedQuery');
        break;
      case 'music': // Apple Music
        launchUri = Uri.parse('music://search?term=$encodedQuery');
        break;
      case 'amznmp3':
        launchUri = Uri.parse('amznmp3://search?keyword=$encodedQuery');
        break;
      default:
        // Generic fallback for others
        launchUri = Uri.parse('${app.scheme}://search?q=$encodedQuery');
    }

    try {
      final success = await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      if (!success) {
        _launchWebSearch(query);
      }
    } catch (e) {
      _launchWebSearch(query);
    }
  }

  /// Fallback: Search the web (YouTube is usually best for music)
  Future<void> _launchWebSearch(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final webUri = Uri.parse('https://www.youtube.com/results?search_query=$encodedQuery');
    
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to launch web search: $e');
    }
  }

  /// The main entry point for the UI. Handles detection and routing.
  Future<void> playSong(BuildContext context, String title, String artist) async {
    final query = '$title $artist';
    final installedApps = await getInstalledApps();

    if (installedApps.isEmpty) {
      // No apps found, fallback to web
      await _launchWebSearch(query);
    } else if (installedApps.length == 1) {
      // Only 1 app, open directly
      await launchAppSearch(installedApps.first, query);
    } else {
      // Multiple apps, show BottomSheet
      if (!context.mounted) return;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Play "$title"',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const Divider(),
                ...installedApps.map((app) => ListTile(
                      leading: Text(app.icon, style: const TextStyle(fontSize: 24)),
                      title: Text('Play on ${app.name}'),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: () {
                        Navigator.pop(context);
                        launchAppSearch(app, query);
                      },
                    )),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    }
  }
}
