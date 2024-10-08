import 'dart:async';
import 'dart:io';

import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class PaymentWebView extends StatefulWidget {
  final String feesId;
  final String feesTypeId;
  final String paymentType;
  final String transFeesIdList;

  const PaymentWebView({
    super.key,
    required this.feesId,
    required this.feesTypeId,
    required this.paymentType,
    required this.transFeesIdList,
  });

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  late Future<String> _urlFuture;
  Color _backgroundColor = Colors.white;
  double _fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _urlFuture = _loadUrl();
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

  Future<String> _loadUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String studentId = prefs.getString('studentId') ?? '';
    String url = '$apiUrl${Constants.paymentGatewayUrl}';

    if (widget.paymentType == 'fees') {
      url += '${widget.feesId}/${widget.feesTypeId}/$studentId/';
    } else {
      url += '0/0/$studentId/${widget.transFeesIdList}';
    }

    print("Paying webview URL: $url");

    if (await _isInternetConnected()) {
      return url;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet Connection'),
        ),
      );
      return '';
    }
  }

  Future<bool> _isInternetConnected() async {
    return true;
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
      final result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to leave this page?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (result == true) {
        Navigator.of(context).pop(true);
      }
      return result ?? false;
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
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('Do you want to leave this page?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('No'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );

                if (result == true) {
                  Navigator.of(context).pop(true);
                }
                return result ?? false;
              },
              icon: const Icon(Icons.arrow_back)),
          title: Text('Payment',
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
        body: FutureBuilder<String>(
          future: _urlFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == '') {
              return const Center(child: Text('Failed to load URL'));
            } else {
              return WebView(
                initialUrl: snapshot.data,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                onProgress: (int progress) {
                  print('WebView is loading (progress: $progress%)');
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
            }
          },
        ),
      ),
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
