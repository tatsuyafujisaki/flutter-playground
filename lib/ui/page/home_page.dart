import 'package:flutter_playground/ui/page/google_maps_page.dart';
import 'package:flutter_playground/ui/page/livekit_room_page.dart';
import 'package:material_ui/material_ui.dart';

/// The initial page shown on app launch, which links to demo pages.
class const HomePage({super.key}) extends StatelessWidget {
  /// Creates a [HomePage].
  this;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: .min,
        spacing: 16,
        children: [
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const GoogleMapsPage()),
            ),
            child: const Text('Google Maps'),
          ),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const LiveKitRoomPage()),
            ),
            child: const Text('LiveKit'),
          ),
        ],
      ),
    ),
  );
}
