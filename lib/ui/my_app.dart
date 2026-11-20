import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_playground/data/utils/upgrade_utils.dart';
import 'package:flutter_playground/l10n/app_localizations.dart';
import 'package:flutter_playground/ui/page/home_page.dart';
import 'package:flutter_playground/ui/provider/my_app_lifecycle_state.dart';
import 'package:flutter_playground/ui/view_model/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The global navigator key used by [MyApp].
final navigatorKey = GlobalKey<NavigatorState>();

/// The root widget of the application.
class MyApp extends ConsumerStatefulWidget {
  /// Creates a [MyApp].
  const new({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final navigatorState = navigatorKey.currentState;
      if (navigatorState != null) {
        await showForceUpdateDialogIfNeeded(navigatorState);
      }
    });
    unawaited(ref.read(authViewModelProvider.notifier).signInAnonymously());
  }

  @override
  Widget build(BuildContext context) {
    final lifecycleState = ref.watch(myAppLifecycleStateProvider);
    developer.log('🔄${lifecycleState.name}');

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const HomePage(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
