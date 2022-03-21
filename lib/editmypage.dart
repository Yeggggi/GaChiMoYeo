import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';


class EditPage extends StatefulWidget {
  EditPageState createState() => EditPageState();
}

class EditPageState extends State<EditPage > {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _mynamecontroller = TextEditingController();
  final _hashtagcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: new Icon(Icons.close),
          color: OnBackground,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('수정하기',
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
              if (_formKey.currentState!.validate()) {
                await edit(
                    _mynamecontroller.text,
                    _hashtagcontroller.text
                );
                _mynamecontroller.clear();
                _hashtagcontroller.clear();
                Navigator.pushNamed(context, '/mypage',);
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
                        controller: _mynamecontroller,
                        decoration: const InputDecoration(
                          hintText: '닉네임',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '닉네임을 다시 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _hashtagcontroller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            hintText: '#',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '해시태그를 다시 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  Future edit(String name, String hashtag) async {
    await FirebaseFirestore.instance.collection("users").add({
      //"myname": name,
      "hashtag": hashtag,
      'name': name,
      //'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'email': FirebaseAuth.instance.currentUser!.email,
    });
  }
}



