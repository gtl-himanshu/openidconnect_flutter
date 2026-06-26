part of openidconnect;

class OpenIdConnectAndroidiOS {
  static Future<String> authorizeInteractive({
    required BuildContext context,
    required String title,
    required String authorizationUrl,
    required String redirectUrl,
    required int popupWidth,
    required int popupHeight,
  }) async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (pageContext) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(pageContext, null),
                icon: const Icon(Icons.close),
              ),
              title: Text(title),
            ),
            body: flutterWebView.WebViewWidget(
              controller: controller
                ..setNavigationDelegate(
  NavigationDelegate(
    onNavigationRequest: (NavigationRequest request) {
      if (request.url.startsWith(redirectUrl)) {
        Navigator.pop(pageContext, request.url);
        return NavigationDecision.prevent;
      }
      return NavigationDecision.navigate;
    },
    onPageFinished: (String url) {
      if (url.startsWith(redirectUrl)) {
        Navigator.pop(pageContext, url);
      }
    },
    onWebResourceError: (WebResourceError error) {
      if (Platform.isIOS &&
          error.url != null &&
          error.url!.startsWith(redirectUrl)) {
        Navigator.pop(pageContext, error.url);
      }
    },
  ),
)
                ..loadRequest(Uri.parse(authorizationUrl)),
            ),
          );
        },
      ),
    );

    if (result == null) throw AuthenticationException(ERROR_USER_CLOSED);

    return result;
  }
}
