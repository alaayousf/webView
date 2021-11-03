import 'dart:async';
import 'dart:io';
import 'package:fiddlepiddle/providers/hiedShowProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


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

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  @override
  Widget build(BuildContext context) {
    var info = Provider.of<HiedShowProvider>(context, listen: true);
    Completer<WebViewController> _controller = Completer<WebViewController>();
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Visibility(
            visible: info.value,
            child: LinearProgressIndicator(
              color: Color.fromRGBO(231, 135, 88, 1),
              backgroundColor: Color.fromRGBO(249, 232, 222,1),
              
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


              onWebViewCreated:
                  (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),


          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('mailto')||request.url.contains('wa.me')||request.url.contains('facebook.com')||request.url.contains('pinterest.com')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }else
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },



            ),
          ),
        ],
      ),
    ));
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

