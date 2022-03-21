import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';


class SettingroomPage extends StatefulWidget {
  SettingroomPageState createState() => SettingroomPageState();
}

class SettingroomPageState extends State<SettingroomPage > {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _maxnumcontroller = TextEditingController();
  final _maxseccontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: new Icon(Icons.arrow_back_ios_new_rounded),
          color: OnBackground,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('방 설정',
            style: TextStyle(
            color: OnBackground
            )
        ),
        actions: <Widget>[
          new TextButton(
            style: TextButton.styleFrom(
              primary: OnBackground,
              textStyle: const TextStyle(fontSize: 15),
            ),
            onPressed: () async {
              //print(_selectedbutton);
              if (_formKey.currentState!.validate()) {
                await EditRoom(
                    int.parse(_maxnumcontroller.text),
                    int.parse(_maxseccontroller.text),
                );
                _maxnumcontroller.clear();
                _maxseccontroller.clear();
              }
            },
            child: const Text('완료'),
          ),
        ],
        backgroundColor: Bar,
        centerTitle: true,
      ),
      body: Container(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _maxnumcontroller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '방 최대인원 (2-4(명))',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || int.parse(value) < 2 || int.parse(value) > 4) {
                            return '2-4 사이의 숫자를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _maxseccontroller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '인당 최대 말하기 시간 (30-300(초))',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || int.parse(value) < 30 || int.parse(value) > 300) {
                            return '30-300 사이의 숫자를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  Future EditRoom(int maxnum, int maxsec) async {
    await FirebaseFirestore.instance.collection("rooms").add({
      "maxnum": maxnum,
      'maxsec': maxsec,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'email': FirebaseAuth.instance.currentUser!.email,
    });
  }
}



