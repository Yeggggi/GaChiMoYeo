import 'package:flutter/material.dart';
import 'login.dart';
import 'wait.dart';
import 'chat.dart';
import 'home.dart';
import 'help.dart';
import 'mypage.dart';
import 'editmypage.dart';
import 'makeroom.dart';
import 'roomsetting.dart';
import 'search.dart';
import 'searchword.dart';
import 'colors.dart';
import 'stt.dart';

class ShrineApp extends StatelessWidget {
  const ShrineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가치모여',
      home: const LoginPage(),
      theme: ThemeData(
          primaryColor: Primary,
      ),
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginPage (),
        '/wait' : (context) => const WaitPage (),
        '/home' : (context) => const HomePage (),
        '/mypage' : (context) => const MyPage (),
        '/help' : (context) => const HelpPage (),
        '/chat' : (context) => ChatPage (),
        '/edit' : (context) => EditPage (),
        '/search' : (context) => SearchPage (),
        '/searchword' : (context) => SearchwordPage (),
        '/makeroom' : (context) => MakeroomPage (),
        '/settingroom' : (context) => SettingroomPage (),
        '/stt' : (context) => SttPage (),
      },
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic>? _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => const LoginPage(),
      fullscreenDialog: true,
    );
  }
}