import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class WebViewExample extends StatefulWidget {
  static const routeName = '/webview';

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late WebViewController _webController;
  @override
  void initState() {
    super.initState();

    // Enable Hybrid Composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context)!.settings;
    var aUrl = settings.arguments as String;
    const String TOKENURL = 'http://q90357mk.beget.tech/ya_user_token.php?';

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 40.0,
          title: Text('Вебвьюха'),
        ),
        body: Builder(builder: (BuildContext context) {
          return WebView(
              onWebViewCreated: (controller) async {
                _webController = controller;
                //await CookieManager().clearCookies();
              },
              initialUrl: aUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onProgress: (int progress) {},
              onPageFinished: (url) async {
                log('страница загружена = > $url');
                if (url.contains(TOKENURL)) {
                  //Navigator.pop(context);
                }
                if (url.startsWith(
                    'http://q90357mk.beget.tech/ya_user_data.php?')) {
                  var resp3 = await http.get(Uri.parse(url));
                  Navigator.pop(context, resp3);
                }
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith(TOKENURL)) {
                  // получаем json с токеном
                  var userToken = request.url
                      .toString()
                      .substring(45)
                      .replaceAll('%22', '"')
                      .replaceAll('%20', ' ');
                  log('\n=====TOKEN JSON========\n');
                  log(userToken);
                  var jsonToken = json.decode(userToken);
                  log(jsonToken.toString());
                  CookieManager().clearCookies();
                  Navigator.pop(context, jsonToken);

                  setState(() {});
                }
                print('allowing navigation to \n ===> $request');
                return NavigationDecision.navigate;
              });
        }));
  }
}
