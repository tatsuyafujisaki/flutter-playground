import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_playground/ui/extension/build_context_extension.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A page that displays web content using a [WebViewWidget].
class const WebViewPage({
  /// The initial URL to load in the web view.
  required final String url,
  super.key,

  /// An optional callback invoked when a custom back button is pressed.
  ///
  /// When omitted, [AppBar] uses its default back button.
  final VoidCallback? onBackPressed,

  /// An optional cookie to set before loading [url].
  final WebViewCookie? cookie,
}) extends StatefulWidget {
  /// Creates a [WebViewPage] that loads [url].
  this;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final WebViewController _controller = .new();
  final WebViewCookieManager _cookieManager = .new();
  String _title = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initController());
  }

  Future<void> _initController() async {
    if (widget.cookie case final cookie?) {
      await _cookieManager.setCookie(cookie);
    }
    await _controller.setJavaScriptMode(.unrestricted);
    // Avoid a black screen before the first page loads, even in Dark Mode.
    await _controller.setBackgroundColor(Colors.transparent);
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) async {
          final title = await _controller.getTitle() ?? '';
          final canGoBack = await _controller.canGoBack();
          final canGoForward = await _controller.canGoForward();
          if (!mounted) {
            return;
          }
          setState(() {
            _title = title;
            _canGoBack = canGoBack;
            _canGoForward = canGoForward;
          });
        },
      ),
    );
    try {
      await _controller.loadRequest(.parse(widget.url));
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to load URL in WebView: ${widget.url}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: widget.onBackPressed != null
          ? TextButton(
              onPressed: widget.onBackPressed,
              child: FittedBox(child: Text(context.l10n.webViewBackButton)),
            )
          : null,
      title: Text(_title),
      centerTitle: true,
      leadingWidth: widget.onBackPressed != null ? 70 : null,
    ),
    body: Column(
      children: [
        Expanded(child: WebViewWidget(controller: _controller)),
        SafeArea(
          top: false,
          child: Row(
            children: [
              IconButton(
                onPressed: _canGoBack ? _controller.goBack : null,
                icon: const Icon(Icons.navigate_before),
              ),
              IconButton(
                onPressed: _canGoForward ? _controller.goForward : null,
                icon: const Icon(Icons.navigate_next),
              ),
              IconButton(
                onPressed: _controller.reload,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
