import 'package:flutter_playground/ui/page/google_maps_page.dart';
import 'package:material_ui/material_ui.dart';

/// The initial page shown on app launch, which links to [GoogleMapsPage].
class HomePage extends StatelessWidget {
  /// Creates a [HomePage].
  const new({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: FilledButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const GoogleMapsPage())),
        child: const Text('Google Maps'),
      ),
    ),
  );
}
