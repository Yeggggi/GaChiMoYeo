import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:radio_grouped_buttons/radio_grouped_buttons.dart';
import 'package:flutter_shapes/flutter_shapes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'colors.dart';

/*
예찌: makeroom.dart에 쓴 아고라 설명
완료 버튼을 누를 때, db 정보 저장하는 코드 바로 앞에 getToken() 함수로 토큰을 받아와서 토큰을 db에 함께 넣어줌
 */

late String room_token;

class MakeroomPage extends StatefulWidget {
  MakeroomPageState createState() => MakeroomPageState();
}

class MakeroomPageState extends State<MakeroomPage > {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _titlecontroller = TextEditingController();
  final _maxnumcontroller = TextEditingController();
  final _maxseccontroller = TextEditingController();
  final _interceptcontroller = TextEditingController();
  final _hashtagcontroller = TextEditingController();
  final int _maxsec = 99999;
  late int _maxnum = 2;
  late int _category;
  bool interceptStatus = false;
  bool timeStatus = false;
  List<String> buttonList=["상담","면접","토론","만남","스터디","수다"];
  Shapes shapes = Shapes(radius: 50, center: Offset.zero, angle: 0);

  String baseUrl = 'https://tokenserveragora.herokuapp.com'; //Enter the link to your deployed token server over here
  int uid=0;


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
        title: const Text('방 만들기',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: OnBackground,
              fontSize: 26,
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
             /* await getToken();*/

              if (_formKey.currentState!.validate()) {
                await addRoom(
                    _titlecontroller.text,
                    _maxnum,
                    int.parse(_maxseccontroller.text),
                    interceptStatus,
                    timeStatus,
                    await _Category(_category),
                    _hashtagcontroller.text,
                    /*room_token,*/
                );
                _titlecontroller.clear();
                _maxnumcontroller.clear();
                _maxseccontroller.clear();
                _interceptcontroller.clear();
                _hashtagcontroller.clear();


                Navigator.pushNamed(context, '/wait', arguments: room_token);
              }
            },
            child: Text(
              '완료',
              style: TextStyle(
                color: TextWeak,
                fontSize: 18,
              ),
            ),
          ),
        ],
        backgroundColor: Bar,
        centerTitle: true,
      ),
      body: Container(
          padding: const EdgeInsets.all(22.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '방 이름',
                    style: TextStyle(
                      color: TextSmall,
                      fontSize: 18,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titlecontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(33.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(33.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          fillColor: SubPrimary,
                          filled: true,
                          //hintText: '방 이름',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '방 이름을 다시 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '카테고리',
                          style: TextStyle(
                            color: TextSmall,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          child: CustomRadioButton(
                            buttonLables: buttonList,
                            buttonValues: buttonList,
                            buttonHeight: 36.81,
                            fontSize: 18,
                            //customShape: ,
                            buttonBorderColor: TextWeak,
                            textColor: TextSmall,
                            radioButtonValue: (value,index){
                              setState(() {
                                _category = index as int;
                              });
                              //print("Button value "+value.toString());
                              //print("Integer value "+index.toString());
                            },
                            horizontal: true,
                            enableShape: true,
                            //buttonSpace: 5,
                            buttonColor: Colors.white,
                            selectedColor: Primary,
                            buttonWidth: 150,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '최대 인원',
                          style: TextStyle(
                            color: TextSmall,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            height: 37,
                            width: 74,
                            padding: const EdgeInsets.only(top: 10,left: 15, bottom: 8, right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: SubPrimary,
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: SubPrimary,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  value: _maxnum,
                                  dropdownColor: SubPrimary,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  items: <DropdownMenuItem<int>>[
                                    new DropdownMenuItem(
                                      child: new Text('2'),
                                      value: 2,
                                    ),
                                    new DropdownMenuItem(
                                      child: new Text('3'),
                                      value: 3,
                                    ),
                                    new DropdownMenuItem(
                                      child: new Text('4'),
                                      value: 4,
                                  ),
                                ],
                                onChanged: (int? value) {
                                  setState(() {
                                    if(value != null)
                                      _maxnum = value;
                                  });
                                },
                              ),
                            )
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '명',
                              style: TextStyle(
                                color: TextSmall,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '중간 참여',
                          style: TextStyle(
                            color: TextWeak,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FlutterSwitch(
                              activeColor: SubPrimary,
                              activeTextColor: OnPrimary,
                              activeToggleColor: Primary,
                              activeTextFontWeight: FontWeight.w400,
                              inactiveColor: ChatBackground,
                              inactiveTextColor: TextWeak,
                              inactiveToggleColor: TextWeak,
                              inactiveTextFontWeight: FontWeight.w400,
                              width: 109.3,
                              height: 38.97,
                              valueFontSize: 20.0,
                              toggleSize: 33.0,
                              value: interceptStatus,
                              borderRadius: 33.0,
                              showOnOff: true,
                              onToggle: (val) {
                                setState(() {
                                  interceptStatus = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '타이머',
                          style: TextStyle(
                            color: TextWeak,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FlutterSwitch(
                              activeColor: SubPrimary,
                              activeTextColor: OnPrimary,
                              activeToggleColor: Primary,
                              activeTextFontWeight: FontWeight.w400,
                              inactiveColor: ChatBackground,
                              inactiveTextColor: TextWeak,
                              inactiveToggleColor: TextWeak,
                              inactiveTextFontWeight: FontWeight.w400,
                              width: 109.3,
                              height: 38.97,
                              valueFontSize: 20.0,
                              toggleSize: 33.0,
                              value: timeStatus,
                              borderRadius: 33.0,
                              showOnOff: true,
                              onToggle: (val) {
                                setState(() {
                                  timeStatus = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 76,
                            height: 38,
                            //padding: const EdgeInsets.only(bottom: 8),
                            child: TextFormField(
                              controller: _maxseccontroller,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(33.0)),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(33.0)),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                fillColor: SubPrimary,
                                filled: true,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '초',
                              style: TextStyle(
                                color: TextSmall,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '방을 소개해주세요',
                          style: TextStyle(
                            color: TextWeak,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _hashtagcontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(33.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(33.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          fillColor: SubPrimary,
                          filled: true,
                          hintText: '#해시태그로 대화방을 소개해보세요.',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '해시태그을 다시 입력해주세요';
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

  Future addRoom(String title, int maxnum, int maxsec, bool intercept, bool timer, String category, String hashtag) async {
    await FirebaseFirestore.instance.collection("rooms").add({
      "title": title,
      "maxnum": maxnum,
      'maxsec': maxsec,
      "timer" : timer,
      "intercept": intercept,
      "category": category,
      "hashtag": hashtag,
      "nownum": 1,
      'ready': 0,
      /*"token": token,*/
      "token": "",
      //'timestamp': DateTime.now().millisecondsSinceEpoch,
      //'name': FirebaseAuth.instance.currentUser!.displayName,
      //'userId': FirebaseAuth.instance.currentUser!.uid,
      //'email': FirebaseAuth.instance.currentUser!.email,
    });
  }
  Future<String> _Category(int index) async {
    String categorytext ="";
    if(index == 0){
      categorytext = "상담";
    }
    else if(index == 1){
      categorytext = "면접";
    }
    else if(index == 2){
      categorytext = "토론";
    }
    else if(index == 3){
      categorytext = "만남";
    }
    else if(index == 4){
      categorytext= "스터디";
    }
    else if(index == 5){
      categorytext = "수다";
    }
    return categorytext;
  }
/*
  Future<void> getToken() async {
    final response = await http.get(
      /*Uri.parse(baseUrl +
          '/rtc/' +
          widget.channelName! +
          '/publisher/uid/' +
          uid.toString()
        // To add expiry time uncomment the below given line with the time in seconds
        // + '?expiry=45'
      ),*/
      Uri.parse(baseUrl
          +
          '/access_token?channel=' +
          _titlecontroller.text +
          '&uid=' +
          uid.toString()
        // To add expiry time uncomment the below given line with the time in seconds
        // + '?expiry=45'
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        room_token = response.body;
        room_token = jsonDecode(room_token)['token'];

      });
    } else {
      print('Failed to fetch the token');
    }
  }*/
}