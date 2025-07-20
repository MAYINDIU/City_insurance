import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({super.key, required this.url, required this.title});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true; // State variable to control loading indicator visibility

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: You can show progress percentage in the console or UI
            // print('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true; // Show spinner when page starts loading
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false; // Hide spinner when page finishes loading
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false; // Hide spinner on error
            });
            // Handle errors, e.g., show a snackbar or an error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading page: ${error.description}')),
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            // Optional: You can control navigation based on the URL
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent; // Prevent navigation to YouTube
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF00796B),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B)), // Spinner color
              ),
            ),
        ],
      ),
    );
  }
}