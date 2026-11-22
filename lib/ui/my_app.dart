import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_playground/l10n/app_localizations.dart';
import 'package:flutter_playground/ui/page/home_page.dart';
import 'package:flutter_playground/ui/provider/my_app_lifecycle_state.dart';
import 'package:flutter_playground/ui/utils/force_update_dialog.dart';
import 'package:flutter_playground/ui/view_model/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget of the application.
class const MyApp({super.key}) extends ConsumerStatefulWidget {
  /// Creates a [MyApp].
  this;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final List<NavigatorObserver> _navigatorObservers = [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final navigatorState = _navigatorKey.currentState;
      if (navigatorState != null) {
        unawaited(showForceUpdateDialogIfNeeded(navigatorState));
      }
      ref.read(authViewModelProvider.notifier).signInAnonymously().ignore();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(myAppLifecycleStateProvider, (_, next) {
      developer.log('🔄${next.name}');
    });

    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: const HomePage(),
      navigatorObservers: _navigatorObservers,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
