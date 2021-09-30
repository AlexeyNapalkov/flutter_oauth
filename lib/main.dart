import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_oauth/webview.dart';
import 'package:flutter_oauth/wv.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:uuid/uuid.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'YandexID Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'YandexID test'),
        routes: {
          '/webview': (context) => WebViewExample(),
          '/webv': (context) => WebV(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = '';
  String id = '';
  String email = '';
  String userToken = '';
  late SharedPreferences _user;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
      ..then((user) {
        setState(() => this._user = user);
        _loadUserName();
        _loadUserId();
        _loadUserEmail();
      });
  }

  // void _signInYandex() {
  //   setState(() {
  //     signWithYandex();
  //     // email = '1@1.ru';
  //     // id = '2323232';
  //     // name = 'Alexey';
  //     // _setUserName(1, name);
  //     // _setUserId(1, id);
  //     // _setUserEmail(1, email);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'User email: $email',
            ),
            Text(
              'User TOKEN: $userToken',
            ),
            Text(
              'User name: $name',
            ),
            ElevatedButton(
                onPressed: () async {
                  //loginWithYandex(context);
                  //oauth2autorization(context);
                  var responseUserData = await getUserDataByToken2(userToken);
                  log('\n=======ответ данных пользователя====\n');
                  log(responseUserData.toString());
                },
                child: Text('ByToken'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          loginWithYandex(context);
        },
        tooltip: 'signIn with Yandex',
        child: Icon(Icons.login),
      ),
    );
  }

  Future<Null> _setUserName(int, value) async {
    await this._user.setString('name', value);
    _loadUserName();
  }

  Future<Null> _setUserId(int, value) async {
    await this._user.setString('id', value);
    _loadUserId();
  }

  Future<Null> _setUserEmail(int, value) async {
    await this._user.setString('email', value);
    _loadUserEmail();
  }

  void _loadUserName() {
    setState(() {
      this.name = this._user.getString('name') ?? 'non';
    });
  }

  void _loadUserId() {
    setState(() {
      this.id = this._user.getString('id') ?? 'non';
    });
  }

  void _loadUserEmail() {
    setState(() {
      this.email = this._user.getString('email') ?? 'non';
    });
  }

  void loginWithYandex(BuildContext context) async {
    final String yandexauthurl = 'http://q90357mk.beget.tech';
    //'http://q90357mk.beget.tech/yandex_oauth.php?user_uuid=${Uuid().v1()}';

    // если из вебвьюхи нам вернут токен то мы получаем данные о пользователе
    var resultW = await Navigator.pushNamed(context, '/webview',
        arguments: yandexauthurl);
    setState(() {});
    if (resultW is Map) {
      String accessToken = '';
      try {
        accessToken = resultW['access_token'];
      } catch (e) {
        log('\n ======== ТОКЕН НЕ ПОЛУЧЕН=======\n');
      }
      if (accessToken != '') {
        userToken = accessToken;

        setState(() {});
        var resp = await getUserDataByToken(accessToken);
      }
    }
  }

  void oauth2autorization(BuildContext context) async {
    final authorizationEndpoint =
        Uri.parse('https://oauth.yandex.ru/authorize');
    final tokenEndpoint = Uri.parse('https://oauth.yandex.ru/token');
    final identifier = '052735deba4b4404aabded41eb67aa0b';
    final secret = '057984687762466aa76671802d0142e2';
    final redirectUrl =
        Uri.parse('https://selfmadeperson.getcourse.ru/forward_smp');
    //final credentialsFile = File('~/flutter_oauth/credentials.json');
    // Future<oauth2.Client> createClient() async {
    //var exists = await credentialsFile.exists();
    // if (exists) {
    //   var credentials =
    //       oauth2.Credentials.fromJson(await credentialsFile.readAsString());
    //   return oauth2.Client(credentials, identifier: identifier, secret: secret);
    // }

    // If we don't have OAuth2 credentials yet, we need to get the resource owner
    // to authorize us. We're assuming here that we're a command-line application.
    var grant = oauth2.AuthorizationCodeGrant(
        identifier, authorizationEndpoint, tokenEndpoint,
        secret: secret);

    // A URL on the authorization server (authorizationEndpoint with some additional
    // query parameters). Scopes and state can optionally be passed into this method.
    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);

    // Redirect the resource owner to the authorization URL. Once the resource
    // owner has authorized, they'll be redirected to `redirectUrl` with an
    // authorization code. The `redirect` should cause the browser to redirect to
    // another URL which should also have a listener.
    //
    // `redirect` and `listen` are not shown implemented here.
    //await redirect(authorizationUrl);
    //var responseUrl = await listen(redirectUrl);
    final response = await Navigator.pushNamed(context, '/webv',
        arguments: authorizationUrl);
    final responseUrl = Uri.parse(response.toString());
    log('/n############RESPONSE#############/n');
    log(response.toString());
    // final route = MaterialPageRoute(
    //     builder: (context) => WebV(
    //           authorizationUrl: authorizationUrl.toString(),
    //         ));
    // Navigator.push(context, route);
    //final responseUrl = await Navigator.push(context, route);

    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them and extract the
    // authorization code to create a new Client.
    var client =
        await grant.handleAuthorizationResponse(responseUrl.queryParameters);
    log('\n====== access TOKEN===>>> ${client.credentials.accessToken}\n');
    log('\n ========= данные ТОКЕНА =========\n');
    log(client.credentials.toJson().toString());
    //var client2 = grant.
    var userData = await oauth2.clientCredentialsGrant(
        authorizationEndpoint, identifier, secret);
    log('\n ========= данные ПОЛЬЗОВАТЕЛЯ =========\n');
    log(userData.credentials.toJson().toString());
  }

  Future getUserDataByToken(accessToken) async {
    final Map<String, String> queryParams = {
      'access_token': accessToken,
    };

    var urldata = Uri(
      scheme: 'http',
      host: 'q90357mk.beget.tech',
      port: 80,
      path: '/ya_user_data.php',
      queryParameters: queryParams,
    );
    final Map<String, String> requestHeaders = {
      'Accept': 'application/json',
    };
    log('\n ===== первый запрос по адресу=======\n');
    setState(() {});
    log(urldata.toString());
    var resp1 = await http.get(
      urldata,
    );
    //headers: requestHeaders);
    log('\n=====первый ответ ======\n');
    log(resp1.body.toString());
    log('\n ===== второй запрос по адресу=======\n');
    var resp2 = await http.get(urldata);
    log(resp2.request.toString());
    // var userDataUrl = Uri(
    //   scheme: 'http',
    //   host: 'q90357mk.beget.tech',
    //   port: 80,
    //   path: '/ya_user_data.php',
    // );
    // final Map<String, String> requestHeaders = {
    //   'Content-type': 'application/json',
    //   'Accept': 'application/json',
    //   'Authorization': 'Bearer AQAAAAAAH3hdAAdcjIvMBHzu4EEHkRGCn-vQwjs'
    // };
    //var userDataUrl = Uri.http('http://q90357mk.beget.tech',
    //    '/ya_user_data.php', {'access_token': jsonToken});
    //log(userDataUrl.toString());
    // Await the http get response, then decode the json-formatted response.
    //var response = await http.get(userDataUrl, headers: requestHeaders);
    if (resp2.statusCode == 200) {
      var jsonResponse = jsonDecode(resp2.body) as Map<String, dynamic>;

      log(resp2.body);
      return resp2.body.toString();
    } else {
      print('Request failed with status: ${resp2.statusCode}.');
      return resp2.toString();
    }
  }

  Future getUserDataByToken2(accessToken) async {
    String tokenUrl =
        'http://q90357mk.beget.tech/ya_user_data.php?access_token=$accessToken';
    var resultW =
        await Navigator.pushNamed(context, '/webview', arguments: tokenUrl);
    log('\n*************ОТВЕТ ВЕБВЬЮХИ************\n');
    log(resultW.toString());
  }
}
