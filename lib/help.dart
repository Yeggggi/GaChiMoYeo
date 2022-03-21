import 'package:flutter/material.dart';

import 'colors.dart';

bool isEdit = false;
String initialText = "";

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: new Icon(Icons.arrow_back_ios_new_rounded),
          color: OnBackground,
          onPressed: () {
            Navigator.pushNamed(context, '/mypage');
          },
        ),
        title: const Text('도움말',
            style: TextStyle(
                color: OnBackground
            )
        ),
        backgroundColor: Bar,
        centerTitle: true,
      ),
      //backgroundColor: ChatBackground,
      backgroundColor: Background,
      body: Column(children: <Widget>[
        ]),
      );
  }
}