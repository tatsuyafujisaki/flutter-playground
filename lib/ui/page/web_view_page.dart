import 'dart:async';
import 'dart:developer' as developer;

import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A screen that displays web content using a [WebViewWidget].
class const WebViewScreen({
  /// The initial URL to load in the web view.
  required final String url,

  /// The callback invoked when the back button is pressed.
  required final VoidCallback onBackPressed,
  super.key,

  /// An optional cookie to set before loading [url].
  final WebViewCookie? cookie,
}) extends StatefulWidget {
  /// Creates a [WebViewScreen] that loads [url].
  this;

  @override
  State<StatefulWidget> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  final WebViewCookieManager cookieManager = .new();
  String title = '';
  int loadingPercentage = 0;
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
        onPageStarted: (_) {
          if (!mounted) {
            return;
          }
          setState(() => loadingPercentage = 0);
        },
        onProgress: (progress) {
          if (!mounted) {
            return;
          }
          setState(() => loadingPercentage = progress);
        },
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
            loadingPercentage = 100;
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
      leading: Builder(
        builder: (context) => TextButton(
          onPressed: widget.onBackPressed,
          child: const FittedBox(child: Text('Back')),
        ),
      ),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      centerTitle: true,
      leadingWidth: 70,
    ),
    body: Column(
      children: <Widget>[
        Expanded(child: WebViewWidget(controller: controller)),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Row(
              children: <Widget>[
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
          ],
        ),
      ],
    ),
  );
}
