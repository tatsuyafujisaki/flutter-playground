import 'dart:async';
import 'dart:developer' as developer;

import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A page that displays web content using a [WebViewWidget].
class const WebViewPage({
  /// The initial URL to load in the web view.
  required final String url,

  /// The callback invoked when the back button is pressed.
  required final VoidCallback onBackPressed,
  super.key,

  /// An optional cookie to set before loading [url].
  final WebViewCookie? cookie,
}) extends StatefulWidget {
  /// Creates a [WebViewPage] that loads [url].
  this;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  final WebViewCookieManager cookieManager = .new();
  String title = '';
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  void initState() {
    super.initState();
    controller = .new();
    unawaited(_initController());
  }

  Future<void> _initController() async {
    if (widget.cookie case final cookie?) {
      await cookieManager.setCookie(cookie);
    }
    await controller.setJavaScriptMode(.unrestricted);
    // Avoid a black screen before the first page loads, even in Dark Mode.
    await controller.setBackgroundColor(Colors.transparent);
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) async {
          final title = await controller.getTitle() ?? '';
          final canGoBack = await controller.canGoBack();
          final canGoForward = await controller.canGoForward();
          if (!mounted) {
            return;
          }
          setState(() {
            this.title = title;
            this.canGoBack = canGoBack;
            this.canGoForward = canGoForward;
          });
        },
      ),
    );
    try {
      await controller.loadRequest(.parse(widget.url));
    } on Exception catch (error, stackTrace) {
      developer.log('', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: TextButton(
        onPressed: widget.onBackPressed,
        child: const FittedBox(child: Text('Back')),
      ),
      title: Text(title),
      centerTitle: true,
      leadingWidth: 70,
    ),
    body: Column(
      children: [
        Expanded(child: WebViewWidget(controller: controller)),
        SafeArea(
          top: false,
          child: Row(
            children: [
              IconButton(
                onPressed: canGoBack ? controller.goBack : null,
                icon: const Icon(Icons.navigate_before),
              ),
              IconButton(
                onPressed: canGoForward ? controller.goForward : null,
                icon: const Icon(Icons.navigate_next),
              ),
              IconButton(
                onPressed: controller.reload,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
