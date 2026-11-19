import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A screen that displays web content using a [WebViewWidget].
class WebViewScreen extends StatefulWidget {
  /// Creates a [WebViewScreen] that loads [url].
  const WebViewScreen({
    required this.url,
    required this.onBackPressed,
    super.key,
    this.cookie,
  });

  /// The initial URL to load in the web view.
  final String url;

  /// The callback invoked when the back button is pressed.
  final VoidCallback onBackPressed;

  /// An optional cookie to set before loading [url].
  final WebViewCookie? cookie;

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
    if (widget.cookie != null) {
      Future<void>.delayed(
        .zero,
        () => cookieManager.setCookie(widget.cookie!),
      );
    }

    controller = .new();

    Future<void>.delayed(.zero, () async {
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      // Avoid a black screen before the first page loads, even in Dark Mode.
      await controller.setBackgroundColor(Colors.transparent);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => loadingPercentage = 0),
          onProgress: (progress) =>
              setState(() => loadingPercentage = progress),
          onPageFinished: (_) async {
            final title = await controller.getTitle() ?? '';
            setState(() => this.title = title);
            loadingPercentage = 100;
          },
        ),
      );
      try {
        await controller.loadRequest(.parse(widget.url));
      } on Exception catch (error, stackTrace) {
        developer.log('', error: error, stackTrace: stackTrace);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void>.delayed(.zero, () async {
      canGoBack = await controller.canGoBack();
      canGoForward = await controller.canGoForward();
    });
    return Scaffold(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
}
