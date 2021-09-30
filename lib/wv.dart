import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebV extends StatefulWidget {
  static const routeName = '/webv';
  //final String authorizationUrl;
  WebV();
  //WebV({required this.authorizationUrl});

  @override
  _WebVState createState() => _WebVState();
}

class _WebVState extends State<WebV> {
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
    var authorizationUrl = settings.arguments;

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 40.0,
          title: Text('Oauth2WebV'),
        ),
        body: Builder(builder: (BuildContext context) {
          return WebView(
              onWebViewCreated: (controller) async {
                _webController = controller;
                await CookieManager().clearCookies();
              },
              initialUrl: authorizationUrl.toString(),
              javascriptMode: JavascriptMode.unrestricted,
              onProgress: (int progress) {},
              onPageFinished: (url) {
                log('страница загружена = > $url');
                if (url.contains('http://q90357mk.beget.tech/success.php')) {
                  Navigator.pop(context);
                }
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith(
                    'https://selfmadeperson.getcourse.ru/forward_smp'
                    //'http://q90357mk.beget.tech/user_login_success.php?'
                    )) {
                  var userData = request.url.toString().substring(59);
                  String jsonUser = userData.replaceAll('%22', '"');
                  jsonUser = jsonUser.replaceAll('%20', ' ');
                  var jsonData = json.decode(jsonUser);
                  log(jsonData.toString());
                  //var responseUrl = Uri.parse(request.url);
                  Navigator.pop(context, request.url);
                }
                print('allowing navigation to \n ===> ${request.url}');
                return NavigationDecision.navigate;
              });
        }));
  }
}
