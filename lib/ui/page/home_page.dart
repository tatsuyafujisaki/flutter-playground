import 'package:flutter_playground/ui/extension/build_context_extension.dart';
import 'package:flutter_playground/ui/page/google_maps_page.dart';
import 'package:flutter_playground/ui/page/livekit_room_page.dart';
import 'package:flutter_playground/ui/page/web_view_page.dart';
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
          _PageButton(
            label: context.l10n.googleMapsPageTitle,
            builder: (_) => const GoogleMapsPage(),
          ),
          _PageButton(
            label: context.l10n.liveKitPageTitle,
            builder: (_) => const LiveKitRoomPage(),
          ),
          _PageButton(
            label: context.l10n.webViewPageTitle,
            builder: (_) => const WebViewPage(url: 'https://flutter.dev'),
          ),
        ],
      ),
    ),
  );
}

class const _PageButton({
  required final String label,
  required final WidgetBuilder builder,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: () =>
        Navigator.push(context, MaterialPageRoute<void>(builder: builder)),
    child: Text(label),
  );
}
