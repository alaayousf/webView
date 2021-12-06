import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:fiddlepiddle/providers/hiedShowProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final webViewKey = GlobalKey<_WebviewVieState>();

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    //listenForPermissionStatus();
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    var info = Provider.of<HiedShowProvider>(context, listen: true);

    return Scaffold(
        body: SafeArea(
      child:
          info.connectedState ? WebviewVie(key: webViewKey) : LessConnesction(),
    ));
  }
}

class LessConnesction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var info = Provider.of<HiedShowProvider>(context, listen: true);


    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 232, 222, 1),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset('assets/images/noconnection.png',width: 150,),
 
          Text('No internet connection'),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return Color.fromRGBO(231, 135, 88, 1);
                }),
              ),
              onPressed: () {
                info.initeConnectivity();
              },
              child: Text(
                'Reload',
                style: TextStyle(),
              )),
        ],
      )),
    );
  }
}

JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
      name: '_Toaster',
      onMessageReceived: (JavascriptMessage message) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      });
}

class WebviewVie extends StatefulWidget {
  WebviewVie({required Key key}) : super(key: key);

  @override
  _WebviewVieState createState() => _WebviewVieState();
}

class _WebviewVieState extends State<WebviewVie> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _webViewController;

  void reloadWebView() {
    _webViewController.reload();
  }

  @override
  Widget build(BuildContext context) {
    var info = Provider.of<HiedShowProvider>(context, listen: true);

    void _launchURL(String _url) async => await canLaunch(_url)
        ? await launch(_url)
        : throw 'Could not launch $_url';
    return Column(
      children: [
        Visibility(
          visible: info.value,
          child: LinearProgressIndicator(
            color: Color.fromRGBO(231, 135, 88, 1),
            backgroundColor: Color.fromRGBO(249, 232, 222, 1),
          ),
        ),
        Expanded(
          child: WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: 'https://fiddlepiddle.com/',
            onProgress: (int progress) {
              print("WebView is loading (progress : $progress%)");

              if (progress == 100) {
                info.hiedProgres(false);
              }
            },
            onPageStarted: (String url) {
              info.hiedProgres(true);
            },
            onPageFinished: (e) {
              log('finshed');
              info.initeConnectivity();
            },
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            javascriptChannels: <JavascriptChannel>[
              _toasterJavascriptChannel(context),
            ].toSet(),
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('mailto') ||
                  request.url.contains('wa.me') ||
                  request.url.contains('facebook.com') ||
                  request.url.contains('pinterest.com')) {
                _launchURL(request.url);
                return NavigationDecision.prevent;
              } else
                print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
          ),
        ),
      ],
    );
  }
}
