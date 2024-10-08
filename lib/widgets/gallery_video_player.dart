import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

const String kLocalExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>

<h1>Local demo page</h1>
<p>
  This is an example page used to demonstrate how to load a local file or HTML 
  string using the <a href="https://pub.dev/packages/webview_flutter">Flutter 
  webview</a> plugin.
</p>

</body>
</html>
''';

const String kTransparentBackgroundPage = '''
  <!DOCTYPE html>
  <html>
  <head>
    <title>Transparent background test</title>
  </head>
  <style type="text/css">
    body { background: transparent; margin: 0; padding: 0; }
    #container { position: relative; margin: 0; padding: 0; width: 100vw; height: 100vh; }
    #shape { background: red; width: 200px; height: 200px; margin: 0; padding: 0; position: absolute; top: calc(50% - 100px); left: calc(50% - 100px); }
    p { text-align: center; }
  </style>
  <body>
    <div id="container">
      <p>Transparent background test</p>
      <div id="shape"></div>
    </div>
  </body>
  </html>
''';

class GalleryVideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  const GalleryVideoPlayerPage({super.key, required this.videoUrl});

  @override
  _GalleryVideoPlayerPageState createState() => _GalleryVideoPlayerPageState();
}

class _GalleryVideoPlayerPageState extends State<GalleryVideoPlayerPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  Color _backgroundColor = Colors.white;
  double _fontSize = 14.0;

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

  @override
  Widget build(BuildContext context) {
    Color textColor =
        _backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('Video Player',
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
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
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
                case 'Change Background Color':
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Pick a background color'),
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
              return {'Change Font Size', 'Change Background Color'}
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
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.videoUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onProgress: (int progress) {
            print('WebView is loading (progress: $progress%)');
          },
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            _updateWebViewFontSize(_fontSize);
          },
          gestureNavigationEnabled: true,
          zoomEnabled: true,
          backgroundColor: const Color(0x00000000),
          geolocationEnabled: true,
        );
      }),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        // ignore: deprecated_member_use
        // Scaffold.of(context).showSnackBar(
        //   SnackBar(content: Text(message.message)),
        // );
      },
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture, this.textColor,
      {super.key})
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
