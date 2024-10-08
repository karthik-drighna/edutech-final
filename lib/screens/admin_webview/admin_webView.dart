import 'dart:async';
import 'dart:io';
import 'package:drighna_ed_tech/screens/login_screen.dart';
import 'package:drighna_ed_tech/widgets/file_viewer.dart';
import 'package:drighna_ed_tech/widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminWebview extends StatefulWidget {
  final String url;
  const AdminWebview({super.key, required this.url});

  @override
  _AdminWebviewState createState() => _AdminWebviewState();
}

class _AdminWebviewState extends State<AdminWebview> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  Color _backgroundColor = Colors.white;
  double _fontSize = 14.0;
  bool isLoading = false;
  String? cookies;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _requestPermissions();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.camera,
        Permission.storage,
        Permission.accessMediaLocation,
      ].request();

      final allPermissionsGranted =
          statuses.values.every((status) => status == PermissionStatus.granted);
      if (!allPermissionsGranted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Permissions are required to proceed')));
      }
    }
  }

  void _changeBackgroundColor(Color color) {
    setState(() {
      _backgroundColor = color;
      _savePreferences();
    });
  }

  void _changeFontSize(double fontSize) {
    setState(() {
      _fontSize = fontSize;
      _savePreferences();
    });
    _updateWebViewFontSize(fontSize);
  }

  Future<void> _updateWebViewFontSize(double fontSize) async {
    final controller = await _controller.future;
    final jsString = "document.body.style.fontSize = '${fontSize}px';";
    controller.runJavascript(jsString);
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _backgroundColor =
          Color(prefs.getInt('backgroundColor') ?? Colors.white.value);
      _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    });
  }

  Future<void> _savePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('backgroundColor', _backgroundColor.value);
    prefs.setDouble('fontSize', _fontSize);
  }

  Future<bool> _onWillPop() async {
    final WebViewController controller = await _controller.future;
    if (await controller.canGoBack()) {
      await controller.goBack();
      return Future.value(false);
    } else {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text(
                  'Do you want to leave this page and go back to parent/student Login page?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    loginOutApi(context);
                  },
                ),
              ],
            ),
          ) ??
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor =
        _backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: Text('Administration',
              style: TextStyle(fontSize: _fontSize, color: textColor)),
          backgroundColor: _backgroundColor,
          iconTheme: IconThemeData(color: textColor),
          actions: <Widget>[
            NavigationControls(_controller.future, textColor),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: textColor),
              onSelected: (String value) {
                switch (value) {
                  case 'Change Font Size':
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Change font size'),
                        content: Wrap(
                          children: [
                            StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Slider(
                                  value: _fontSize,
                                  min: 10.0,
                                  max: 24.0,
                                  divisions: 7,
                                  label: _fontSize.round().toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      _fontSize = value;
                                    });
                                    _changeFontSize(value);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Done'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                    break;
                  case 'Change Theme Color':
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pick a theme color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: _backgroundColor,
                            onColorChanged: _changeBackgroundColor,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Done'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Change Font Size', 'Change Theme Color'}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onProgress: (int progress) {},
          onPageStarted: (String url) async {
            WebViewController controller = await _controller.future;
            cookies = await controller
                .runJavascriptReturningResult("document.cookie");
          },
          onPageFinished: (String url) {
            _updateWebViewFontSize(_fontSize);
          },
          gestureNavigationEnabled: true,
          zoomEnabled: true,
          backgroundColor: const Color(0x00000000),
          geolocationEnabled: true,
          navigationDelegate: (NavigationRequest request) async {
            if (request.url.contains(".pdf") ||
                request.url.contains(".doc") ||
                request.url.contains(".docx") ||
                request.url.contains(".xls") ||
                request.url.contains(".xlsx") ||
                request.url.contains(".ppt") ||
                request.url.contains(".pptx") ||
                request.url.contains(".jpg") ||
                request.url.contains(".jpeg") ||
                request.url.contains(".png") ||
                request.url.contains("download")) {
              final url = request.url;
              final filename = url.split('/').last;
              downloadFile(url, filename, context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
        bottomNavigationBar: isLoading
            ? const LinearProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }

  Future<void> downloadFile(
      String url, String filename, BuildContext context) async {
    try {
      var dio = Dio();
      dio.options.headers[HttpHeaders.cookieHeader] = cookies;

      var response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        var documentDirectory = await getApplicationDocumentsDirectory();
        File file = File('${documentDirectory.path}/$filename');
        await file.writeAsBytes(response.data);

        if (filename.endsWith('.pdf') || filename.endsWith('.txt')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileViewer(filePath: file.path),
            ),
          );
        } else if (filename.endsWith('.jpg') ||
            filename.endsWith('.png') ||
            filename.endsWith('.jpeg')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(filePath: file.path),
            ),
          );
        } else if (filename.endsWith('.doc') || filename.endsWith('.docx')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileViewer(filePath: file.path),
            ),
          );
        } else {
          _launchURL(url);
        }
      } else {
        _launchURL(url);
        // _showSnackBar("Failed to download file", context);
      }
    } catch (e) {
      _showSnackBar('Error: $e', context);
    }
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showSnackBar('Could not launch $url', context);
    }
  }

  Future<void> loginOutApi(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("AdminLogin", false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture, this.textColor)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController? controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: textColor),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoBack()) {
                        await controller.goBack();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No back history item')),
                        );
                      }
                    },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: textColor),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoForward()) {
                        await controller.goForward();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No forward history item')),
                        );
                      }
                    },
            ),
            IconButton(
              icon: Icon(Icons.replay, color: textColor),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller!.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
