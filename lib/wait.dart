import 'package:flutter/material.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_team_first/makeroom.dart';
import 'dart:async';

import 'chat.dart';
import 'colors.dart';
import 'login.dart';
import 'settings.dart';

/*
예찌:
[아고라]
- 토큰이랑 방이름을 어디에 받아와줄지
1.firebase로 부터 토큰과 방이름 값을 wait.dart에 받아와서 chat.dart로 넘겨줘도 되고
2.chat.dart에서 받아와서 바로 channelJoin 해줘도됨.
- 토큰 생성의 기반 고민 중
방 만들 때 방이름을 기반으로 토큰을 생성하였는데 다른 값(ex.방번호)으로 변경할지 고민 중
(아 한글로도 생성 되는지 봐야함)

[UI]
- 유저 표시
1. 방에 접속한 인원을 어떻게 인식하는지?
그리드 기반으로 index에 따라 유저가 표시되도록 했는데 유저가 들어온 순서에 따라
자리를 지정해줘야하는데 접속 유저 카운트를 어떻게 해야하는지 고민 중
2. 방에 접속한 각 유저의 정보를 어떻게 파라미터로 _userCircle()에 전달해줘야할까
3. 말하고 있는 사람 주위로 파란색 불빛이 표시되도록 하였는데 bold말고 퍼져나가는 듯한 모션을 어떻게 줄 수 있는지 찾아보
기



 */
bool isEdit = false;
String initialText = "";

class WaitPage extends StatefulWidget {
  // final String? room_token;

  const WaitPage({Key? key}) : super(key: key);

  @override
  _WaitPageState createState() => _WaitPageState();
}

bool toggle = false;

class _WaitPageState extends State<WaitPage> {
  /// create a channelController to retrieve text value
  late String _channelController;
  bool _isChannelCreated = true;
  /// if channel textField is validated to have error
  bool _validateError = false;

  var photo;
  var namm;
  String myChannel = 'happyman';

  final firestoreInstance = FirebaseFirestore.instance;

  ClientRole? _role = ClientRole.Broadcaster;

  final Map<String, List<String>> _seniorMember = {};

  // @override
  // void dispose() {
  //   // dispose input controller
  //   _channelController.dispose();
  //   super.dispose();
  // }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: new Icon(Icons.arrow_back_ios_new_rounded),
          color: OnBackground,
          onPressed: () {
            Navigator.pushNamed(context, '/home',);
          },
        ),
        title: const Text('대화방',
            style: TextStyle(
                color: OnBackground
            )
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.settings),
            color: OnBackground,
            onPressed: () {
              Navigator.pushNamed(context, '/settingroom',);
            },
          ),
        ],
        backgroundColor: Bar,
        centerTitle: true,
      ),
      //backgroundColor: ChatBackground,
      backgroundColor: Background,
      body: Column(children: <Widget>[
        const SizedBox(height: 100),
        //Image.asset('assets/wait.png'),
         Stack(
           children: <Widget>[
             Container(
              child: _buildAvatar(),
            ),
             Positioned(
               top: 125,
               left: 150,
               width: 94,
               height: 126,
               child: Image.asset('assets/fire.png'),
             ),
          ],
         ),
        const SizedBox(height: 10),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Secondary, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: onJoin,
                      // ()  async{
                    // Navigator.pushNamed(context, '/chat',);
                  // },
                  child: Text('준비'),
                )
              ],
            ),
          ],
        ),
        ]),
      );
  }

  Future getDate() async {
    firestoreInstance
        .collection("rooms")
        .where("token", isEqualTo: room_token)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        print(result.data());
      });
    });
  }




  Widget _buildAvatar(){
    /*return GridView.builder(
      shrinkWrap: true,
      itemCount: _userMap.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: MediaQuery.of(context).size.height / 1100,
          crossAxisCount: 2),
      itemBuilder: (BuildContext context, int index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Container(
              color: Colors.white,
              child: (_userMap.entries.elementAt(index).key == _localUid)
                  ? RtcLocalView.SurfaceView()
                  : RtcRemoteView.SurfaceView(
                  uid: _userMap.entries.elementAt(index).key)),
          decoration: BoxDecoration(
            border: Border.all(
                color: _userMap.entries.elementAt(index).value.isSpeaking
                    ? Colors.blue
                    : Colors.grey,
                width: 6),
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
        ),
      ),
    );*/
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 9,
      // _userMap.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing : MediaQuery.of(context).size.width /100,
          childAspectRatio: MediaQuery.of(context).size.height /800,
          crossAxisCount: 3
      ),
      itemBuilder: (BuildContext context, int index){
        if(index == 1){
          return Container(
            child: _userCircular(index, photo = "assets/group1.png",
                namm = name_user,),
            // child: Image.asset('assets/group1.png'),
          );
          // return Container();
        }else if(index == 1 || index == 3 || index == 5||index == 7){
          if(index == 3){
            photo = "assets/group2.png";
            namm = "반가워요";
          } else if(index == 5){
            photo = "assets/group3.png";
            namm = "산책러";
          } else {
            photo = "assets/group4.png";
            namm = "프로경청러";
          };
          return Container(child: _userCircular(index, photo, namm),);
        /*  return
            // child: _userCircular(index),
            // child: Image.asset('assets/group1.png'),
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Column(
                // mainAxisAlignment: mainAx,
                children: [
                  Container(
                    color: Colors.white,
                    width: 78,
                    height: 78,
                    child: CircleAvatar(
                      // backgroundImage: AssetImage('assets/group1.png'),
                      // radius: (60),
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius:BorderRadius.circular(50),
                          child: Image.asset(photo),
                        )
                      // backgroundColor: Colors.blue,
                      // radius: 42,
                    ),
                    // decoration: new BoxDecoration(
                    //   shape: BoxShape.circle,
                    //   border: new Border.all(
                    //     color: Colors.grey,
                    //     width: 4.0,
                    //   ),
                    // ),
                  ),
                  Text(namm,style: TextStyle(
                    fontSize: 13,
                    color: TextSmall,
                  ),),
                ],
              ),
            );*/

        }else return Container();

      },
      //     Padding(
      //   padding: const EdgeInsets.all(8.0),
      //     child: _userCircular(index),
      // ),
    );

  }


  Widget _userCircular(index, photo, namm){
    print('index = $index');
    var fontbordder;
    if(namm == name_user){
      fontbordder = FontWeight.bold;
    }else{
      fontbordder = FontWeight.normal;
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            width: 100,
            height: 100,
            child: PopupMenuButton(
              icon: Container(
                width: 85,
                height: 85,

                // child: CircleAvatar(
                    // backgroundImage: AssetImage('assets/group1.png'),
                    // backgroundColor: Colors.purple,
                    // child: ClipRRect(
                    //   // borderRadius:BorderRadius.circular(50),
                    //   child: Image.asset('assets/group1.png'),
                    // ),
                // ),
                decoration: new BoxDecoration(
                  // shape: BoxShape.circle,
                  color: Colors.black,
                  image: DecorationImage(image: AssetImage(photo), fit: BoxFit.cover,),
                  border: new Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(80.0),
                  ),

                ),
              ),
              color: Background,
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem (
                    child: Container(
                      alignment: Alignment.center,
                      child: Text('mypage'),
                    ),
                    value: 0,
                  ),
                  PopupMenuItem (
                    child: Container(
                      alignment: Alignment.center,
                      child: Text('history'),
                    ),
                    value: 1,
                  ),
                ];
              },
              onSelected: (result) {
                if (result == 0) {
                  // Navigator.pushNamed(context, '/mypage',);
                  print('mypage');
                }else if (result == 1){
                  // code for the remove action
                  print('history');
                };
              },
            ),
          ),
          Text("$namm",style: TextStyle(
            fontSize: 13,
            color: TextSmall,
              fontWeight: fontbordder,
          ),),
        ],),
    );
  }


  Future<void> onJoin() async {
    _channelController = uid;
    print("Uid(ChannelName): ${_channelController}");
    // update input validation
    setState(() {
      _channelController.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    // if (_channelController.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      // await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await _handleCameraAndMic(Permission.camera);
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            // channelName: _channelController,
            channelName: myChannel,
            role: _role,
          ),
        ),
      );
    // }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}