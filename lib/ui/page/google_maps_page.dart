import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_playground/data/model/chain_cafe.dart';
import 'package:flutter_playground/data/utils/debouncer.dart';
import 'package:flutter_playground/ui/extension/build_context_extension.dart';
import 'package:flutter_playground/ui/view_model/google_maps_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

// Hides default business POIs (including independent cafes) so only chain cafe
// markers stand out on the map.
const _hideBusinessPoisMapStyle = '''
[
  {
    "featureType": "poi.business",
    "stylers": [
      {"visibility": "off"}
    ]
  }
]
''';

// Default: Tokyo Station.
const _defaultCameraTarget = LatLng(35.6812, 139.7671);

const _cameraIdleDebounceDuration = Duration(milliseconds: 500);

/// A page that displays Google Maps with the user's location and nearby chain
/// cafes.
class const GoogleMapsPage({super.key}) extends ConsumerStatefulWidget {
  /// Creates a [GoogleMapsPage].
  this;

  @override
  ConsumerState<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends ConsumerState<GoogleMapsPage> {
  // The GoogleMap widget disposes this controller itself.
  final _controller = Completer<GoogleMapController>();
  final _cameraIdleDebouncer = Debouncer(_cameraIdleDebounceDuration);

  LatLng _cameraTarget = _defaultCameraTarget;
  var _isOpeningUrl = false;

  String get _languageCode => Localizations.localeOf(context).languageCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_loadNearbyChainCafes()),
    );
  }

  @override
  void dispose() {
    _cameraIdleDebouncer.dispose();
    super.dispose();
  }

  /// Moves the camera to the current location and searches for cafes there.
  Future<void> _loadNearbyChainCafes() async {
    final location = await ref
        .read(googleMapsViewModelProvider.notifier)
        .loadNearbyChainCafes(languageCode: _languageCode);
    if (location == null || !mounted) {
      return;
    }
    try {
      final controller = await _controller.future;
      if (mounted) {
        // Keeps the current zoom level and only moves the center.
        await controller.animateCamera(.newLatLng(location));
      }
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to move the camera',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onCameraIdle() {
    // Waits for the camera to settle so that consecutive gestures cause only
    // one search.
    _cameraIdleDebouncer.run(() {
      if (!mounted) {
        return;
      }
      unawaited(
        ref
            .read(googleMapsViewModelProvider.notifier)
            .searchChainCafesIfMoved(
              _cameraTarget,
              languageCode: _languageCode,
            ),
      );
    });
  }

  Marker _toCafeMarker(ChainCafe cafe) => Marker(
    markerId: .new(cafe.id),
    position: .new(cafe.latitude, cafe.longitude),
    infoWindow: .new(
      title: cafe.name,
      // Tapping the marker only shows the info window; tapping the info
      // window opens the cafe's website.
      onTap: () => unawaited(_openCafeUrl(cafe)),
    ),
    icon: .defaultMarkerWithHue(BitmapDescriptor.hueOrange),
  );

  Future<void> _openCafeUrl(ChainCafe cafe) async {
    if (_isOpeningUrl) {
      return;
    }
    setState(() => _isOpeningUrl = true);

    try {
      final uri =
          _parseHttpUri(cafe.websiteUri) ?? _parseHttpUri(cafe.googleMapsUri);
      if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.googleMapsNoUrlAvailable(cafe.name)),
          ),
        );
        return;
      }

      final launched = await launchUrl(uri, mode: .externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.googleMapsCouldNotOpenUrl('$uri')),
          ),
        );
      }
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to open cafe URL',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.googleMapsFailedToOpenCafeUrl('$error')),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningUrl = false);
      }
    }
  }

  Uri? _parseHttpUri(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return uri;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.listen(googleMapsViewModelProvider.select((state) => state.error), (
      _,
      error,
    ) {
      if (error == null) {
        return;
      }
      final message = switch (error.type) {
        .currentLocation => l10n.googleMapsFailedToLoadCurrentLocation(
          error.detail,
        ),
        .nearbyChainCafes => l10n.googleMapsFailedToLoadNearbyChainCafes(
          error.detail,
        ),
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    });
    final state = ref.watch(googleMapsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.googleMapsPageTitle),
        actions: [
          if (state.isLocating || state.isSearching || _isOpeningUrl)
            const Padding(
              padding: .all(16),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.googleMapsReloadTooltip,
              onPressed: _loadNearbyChainCafes,
            ),
        ],
      ),
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: const .new(
            target: _defaultCameraTarget,
            zoom: 15, // Street level.
          ),
          style: _hideBusinessPoisMapStyle,
          onMapCreated: _controller.complete,
          onCameraMove: (position) => _cameraTarget = position.target,
          onCameraIdle: _onCameraIdle,
          markers: {
            if (state.currentLocation case final currentLocation?)
              Marker(
                markerId: const .new('current_location'),
                position: currentLocation,
                infoWindow: .new(title: l10n.googleMapsYourLocation),
                icon: .defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            ...state.cafes.map(_toCafeMarker),
          },
        ),
      ),
    );
  }
}
