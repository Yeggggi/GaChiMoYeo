import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:project_team_first/mypage.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

import 'login.dart';
import 'colors.dart';
import 'settings.dart';
import 'user.dart';

/*

말할 때 bold - 그냥 마이크 온오프에 따라, 채팅 ui 바꾸기 + 키보드 따라 화면이 올라가도록

*/

bool isEdit = false;
TextEditingController _editingController =TextEditingController(text: initialText);
String initialText = "";

class ChatPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  // final String? channelName;

  /// non-modifiable client role of the page
  final ClientRole? role;
  final String? channelName;

  const ChatPage({Key? key,this.channelName, this.role}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

bool toggle = false;

class _ChatPageState extends State<ChatPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();
  Color _floatingbuttonColor = TextWeak;
  bool muted = false;
  late RtcEngine _engine;
  Map<int, Users_Isspeak> _userMap = new Map<int, Users_Isspeak>();
  final _users = <int>[];
  final _infoStrings = <String>[];
  int? streamId;
  int? _localUid;
  //for token
  String baseUrl = 'https://tokenserveragora.herokuapp.com'; //Enter the link to your deployed token server over here
  int uid = 0;
  late String token;
  var namm;
  var photo;
  late int speak_us;
  // final viewInsets = EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets,WidgetsBinding.instance.window.devicePixelRatio);
  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.joinChannel(Token, widget.channelName!, null, 0);

  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableAudio();
    // await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    // await _engine.setChannelProfile(ChannelProfile.Communication);

    await _engine.setClientRole(ClientRole.Broadcaster);
    await _engine.enableAudioVolumeIndication(250, 3, true);

  }

  @override
  Widget build(BuildContext context) {

    String chats = "";
    String local_chats = "";
    final fb = FirebaseFirestore.instance;

   return KeyboardSizeProvider(
        smallSize: 500.0,
        child: Scaffold(
    resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Transform.scale(
          scale: 0.7,
          child: IconButton(
            padding: EdgeInsets.fromLTRB(28, 10, 0, 0),
            icon: Image.asset("assets/Iconography.png"),
            color: OnBackground,
            onPressed: () {
                    // _engine.sendStreamMessage(streamId!, "end");
                Navigator.of(context).pop();
                    // Navigator.pushNamed(context, '/wait',);
             },
          ),
        ),
        title:  Row(
          children: [
            Container(
              padding: EdgeInsets.only(left:50),
              child: Text('가치모여 공프기 회의 ...',
                style: TextStyle(
                    color: TextBig,
                    fontSize: 20,
                    letterSpacing: -1.2,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              child: Text(' 4 ',
                style: TextStyle(
                  color: TextWeak,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Transform.scale(
            scale: 0.7,
            child: IconButton(
              padding: EdgeInsets.fromLTRB(0, 10, 16, 0),
              icon: Image.asset("assets/high_brightness.png"),
              color: OnBackground,
              onPressed: () {
                Navigator.pushNamed(context, '/settingroom',);
              },
            ),
          ),
        ],
        backgroundColor: Bar,
        centerTitle: true,
      ),
      //backgroundColor: ChatBackground,
      backgroundColor: Background,
      body: Column(children: <Widget>[
       // _Avatar(),
      Stack(
      children: <Widget>[
        Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            // width: MediaQuery.of(context).size.width,
            width: 370,
            height: 360,
            color: Colors.white,
            // margin: EdgeInsets.fromLTRB(0, 40, 0, 30),
            child: Container(
              width: 300,
              height: 501,
              color: Colors.white,
              child: _buildAvatar(),

            ),
          ),
        Positioned(
          top: 130,
          left: 140,
          width: 94,
          height: 126,
          child: Image.asset('assets/fire.png'),
        ),
        Positioned(
          // top: 322,
          top: 20,
          right: 0,
          width: 40,
          height: 40,
          child:
          FloatingActionButton(
            onPressed: _onToggleMute,
            // backgroundColor:  toggle ? _floatingbuttonColor : Primary,
            backgroundColor:  muted ?  _floatingbuttonColor : Primary,
            child: Image.asset("assets/Mic.png",width: 18,height: 25,),

        ),
        ),
      ],),
         const SizedBox(height: 10),
        Expanded(
            child: Container(
              color: ChatBackground,
              child: StreamBuilder<QuerySnapshot>(
                stream: fb.collection("chats").orderBy('timestamp').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                  //   if (!(snapshot.hasError)) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return Text("Loading");
                  // }
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      if ((snapshot.data?.docs[index]['userId'] == uid_google)) {
                        String chats = (snapshot.data?.docs[index]['text'])
                            .toString();
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Text((snapshot.data?.docs[index]['name'])
                                            .toString()),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Primary,
                                            //color: (messages[index].messageType  == "receiver"?Colors.grey.shade200:Colors.blue[200]),
                                          ),
                                          padding: EdgeInsets.all(10),
                                          child: Text(chats),
                                        ),
                                      )
                                    ]
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top:5, right:5),
                              child: Image.asset('assets/group1.png',width: 38,height: 38),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top:10, left:5),
                              child: Image.asset('assets/group4.png',width: 38,height: 38),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text((snapshot.data?.docs[index]['name'])
                                            .toString()),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.all(10),
                                          child: Text((snapshot.data?.docs[index]['text'])
                                              .toString()),
                                        ),
                                      ),
                                    ]
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              ),
            )
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 35, left: 14),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(33.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      //border: InputBorder.none,
                      filled: true,
                      fillColor: InputBar,
                      hintText: '메세지를 입력하세요',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '메세지를 입력하세요';
                      }
                      return null;
                    },
                    onTap:() => {
                      // MediaQuery.of(context).viewInsets.bottom
                    },
                  ),
                ),
                Padding(
                  padding:const EdgeInsets.only(left: 5, right: 12),
                  child: Ink(
                      decoration: const ShapeDecoration(
                        color: ChatBackground,
                        shape: CircleBorder(),
                      ),
                      child: new SizedBox(
                          height: 45,
                          width: 45,
                          child: new IconButton(
                            icon: Icon(Icons.arrow_upward),
                            //padding: new EdgeInsets.all(12.2),
                            color: OnPrimary,
                            //iconSize: 62,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await addMessage(_controller.text);
                                _controller.clear();
                              }
                            },
                          )
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
        ),
    );
  }

  Future addMessage(String text) async {
    await FirebaseFirestore.instance.collection("chats").add({
      "text": text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'email': FirebaseAuth.instance.currentUser!.email,
    });
  }

  /*Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('메세지 삭제 알림'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('메세지를 정말 삭제 하시겠어요?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                //print('Confirmed');
                final QuerySnapshot result = await FirebaseFirestore.instance
                    .collection('chats')
                    .get();
                final List<DocumentSnapshot> documents = result.docs;
                String targetDoc = "";
                String creatorUID = "";
                documents.forEach((data) {
                  if (data['email'] == email_user) {
                    targetDoc = data.id;
                    creatorUID = data['userId'];
                  }
                });
                if (creatorUID == uid_google) {
                  var firebaseUser = FirebaseAuth.instance.currentUser;
                  FirebaseFirestore.instance
                      .collection("chats")
                      .doc(targetDoc)
                      .delete()
                      .then((data) {
                    //print("Deleted!");
                  });
                } else {
                  //print("not matching the user id");
                  //print(email_user);
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/

  Future updateStatus(String text) async{
    final firestoreInstance = FirebaseFirestore.instance;
    final QuerySnapshot result =
    await firestoreInstance.collection('chats').get();
    final List<DocumentSnapshot> documents = result.docs;
    final User user_uid = FirebaseAuth.instance.currentUser!;
    String targetDoc = "";
    String creatorUID = "";
    documents.forEach((data) {if(data['userId'] == user_uid.uid) {targetDoc = data.id;}});
    //print(targetDoc);
    //print(user_uid.uid);
    var firebaseUser = FirebaseAuth.instance.currentUser;
    firestoreInstance
        .collection("chats")
        .doc(targetDoc)
        .update({"text": text}).then((_) {
      print("success!");
    });
    //is Speaking

    // Navigator.pop(context);
  }


  Widget _buildAvatar(){
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
        if(index == 2){
          return Container(
            // child: _userCircular(),
            // child: _userCircle(index),
            // child: Image.asset('assets/group1.png'),
          );
            return Container();
        }else if(  index == 1 || index == 3 || index == 5||index == 7){
          if(index == 1){
            photo = "assets/group1.png";
            namm = name_user;
            // return Container(child: _userCircle(index, photo, namm),);

            return _Avatar(0,photo,namm);
          } else if(_userMap.length==2 && index == 7){
            photo = "assets/group4.png";
            namm = "슈비";
            // return Container(child: _userCircle(index, photo, namm),);
            return _Avatar(1,photo,namm);
          } else if(index == 5){
            photo = "assets/group3.png";
            namm = "산책러";
            return Container(child: _userCircle(index, photo, namm),);
          } else if(index == 3){ //usermap length가 2일 때
            photo = "assets/group2.png";
            namm = "반가워요";
            // return _Avatar();
            return Container(child: _userCircle(index, photo, namm),);
          }else return Container();
        }else return Container();

        },
    );

  }

//각각의 유저의 이미지랑 이름. 근데 지금은 제일 위에 자리에 본인 이름들어가는것밖에 없
 Widget _userCircle(index,photo,namm){
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
           width: 90,
           height: 90,
           child: PopupMenuButton(
             icon: Container(
               width: 80,
               height: 80,
               // child: _userCircular(photo),
               decoration: new BoxDecoration(
                 // color: Colors.black,
                 image: DecorationImage(image: AssetImage(photo), fit: BoxFit.cover,),
                 border: Border.all(
                     color:Colors.grey,
                     width: 4.0),
                 borderRadius: BorderRadius.all(
                   Radius.circular(80.0),
                 ),
               ),
             ),
             color: SubPrimary,
             itemBuilder: (BuildContext context) {
               return [
                 PopupMenuItem (
                     child: Row(
                       children: [
                         Column(
                           children: [
                             IconButton(
                               icon: Image.asset('assets/smile.png'),
                               iconSize: 20,
                               color: OnBackground,
                               onPressed: () {
                               },
                             ),
                             Container(
                               alignment: Alignment.center,
                               child: Text('공감해요',
                                 style: TextStyle(
                                   color: TextSmall,
                                   fontSize: 10,
                                 ),
                               ),
                             ),
                           ],
                         ),
                         Column(
                           children: [
                             IconButton(
                               icon: Image.asset('assets/sad.png'),
                               iconSize: 20,
                               color: OnBackground,
                               onPressed: () {
                               },
                             ),
                             Container(
                               alignment: Alignment.center,
                               child: Text('감동이에요',
                                 style: TextStyle(
                                   color: TextSmall,
                                   fontSize: 10,
                                 ),
                               ),
                             ),
                           ],
                         ),
                         Column(
                           children: [
                             IconButton(
                               icon: Image.asset('assets/wow.png'),
                               iconSize: 20,
                               color: OnBackground,
                               onPressed: () {
                               },
                             ),
                             Container(
                               alignment: Alignment.center,
                               child: Text('궁금해요',
                                 style: TextStyle(
                                   color: TextSmall,
                                   fontSize: 10,
                                 ),
                               ),
                             ),
                           ],
                         ),
                         Column(
                           children: [
                             IconButton(
                               icon: Image.asset('assets/wink.png'),
                               iconSize: 20,
                               color: OnBackground,
                               onPressed: () {
                               },
                             ),
                             Container(
                               alignment: Alignment.center,
                               child: Text('말해주세요',
                                 style: TextStyle(
                                   color: TextSmall,
                                   fontSize: 10,
                                 ),
                               ),
                             ),
                           ],
                         ),
                         Column(
                           children: [
                             IconButton(
                               icon: Image.asset('assets/bad.png'),
                               iconSize: 20,
                               color: OnBackground,
                               onPressed: () {
                               },
                             ),
                             Container(
                               alignment: Alignment.center,
                               child: Text('힘내요',
                                 style: TextStyle(
                                   color: TextSmall,
                                   fontSize: 10,
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ],
                     )
                   //value: 0,
                 ),
                 PopupMenuItem (
                   child: Divider(
                     height: 5,
                     thickness: 1,
                     endIndent: 0,
                     color: Colors.grey,
                   ),
                 ),
                 PopupMenuItem (
                   child:
                   Container(
                     alignment: Alignment.center,
                     child: Text('대화 기록'),
                   ),
                   value: 0,
                 ),
                 PopupMenuItem (
                   child: Divider(
                     height: 5,
                     thickness: 1,
                     endIndent: 0,
                     color: Colors.grey,
                   ),
                 ),
                 PopupMenuItem (
                   child: Container(
                     alignment: Alignment.center,
                     child: Text('정보'),
                   ),
                   value: 1,
                 ),
               ];
             },
             onSelected: (result) {
               if (result == 0) {
                 // Navigator.pushNamed(context, '/mypage',);
                 print('history');
               }else if (result == 1){
                 // code for the remove action
                 print('mypage');
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

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  Widget _userCircular(photo){
    return CircleAvatar(
      backgroundImage: AssetImage("assets/group1.png"),
      // NetworkImage(
      //     "https://4.bp.blogspot.com/-Jx21kNqFSTU/UXemtqPhZCI/AAAAAAAAh74/BMGSzpU6F48/s1600/funny-cat-pictures-047-001.jpg"
      // ),
      backgroundColor: Colors.red,
    );
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
          _localUid = uid;
          _userMap.addAll({uid: Users_Isspeak(uid, false)});
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
          _userMap.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
          _userMap.addAll({uid: Users_Isspeak(uid, false)});
        });
      },
      userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          _users.remove(uid);
          _userMap.remove(uid);
        });
      },
      // firstRemoteVideoFrame: (uid, width, height, elapsed) {
      //   setState(() {
      //     final info = 'firstRemoteVideo: $uid ${width}x $height';
      //     _infoStrings.add(info);
      //   });
      // },
      // tokenPrivilegeWillExpire: (token) async {
      //   await getToken();
      //   await _engine.renewToken(token);
      // },
        /// Detecting active speaker by using audioVolumeIndication callback
        audioVolumeIndication: (volumeInfo, v) {
          volumeInfo.forEach((speaker) {
            //detecting speaking person whose volume more than 5
            if (speaker.volume > 5) {
              try {
                _userMap.forEach((key, value) {
                  //Highlighting local user
                  //In this callback, the local user is represented by an uid of 0.
                  if ((_localUid?.compareTo(key) == 0) && (speaker.uid == 0)) {
                    setState(() {
                      _userMap.update(key, (value) => Users_Isspeak(key, true));
                    });
                  }

                  //Highlighting remote user
                  else if (key.compareTo(speaker.uid) == 0) {
                    setState(() {
                      _userMap.update(key, (value) => Users_Isspeak(key, true));
                    });
                  } else {
                    setState(() {
                      _userMap.update(key, (value) => Users_Isspeak(key, false));
                    });
                  }
                });
              } catch (error) {
                print('Error:${error.toString()}');
              }
            }
          });
        },
      streamMessageError: (_, __, error, ___, ____) {
        final String info = "here is the error $error";
        print(info);
      },
    ));
  }

  Widget _Avatar(speak_us,photo,namm) {
    return
     Container(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                width: 90,
                height: 90,
                child: PopupMenuButton(
                  icon: Container(
                    // color:Color(0xFAE3D9),
                    width: 78,
                    height: 78,
                    // child: _userCircular(photo),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage(photo), fit: BoxFit.cover,),
                    border: Border.all(
                          color: _userMap.entries.elementAt(speak_us).value.isSpeaking
                              ? Colors.blue
                              : Colors.grey,
                          width: 4.0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                    ),
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem (
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    icon: Image.asset('assets/smile.png'),
                                    iconSize: 20,
                                    color: OnBackground,
                                    onPressed: () {
                                    },
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text('공감해요',
                                      style: TextStyle(
                                        color: TextSmall,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Image.asset('assets/sad.png'),
                                    iconSize: 20,
                                    color: OnBackground,
                                    onPressed: () {
                                    },
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text('감동이에요',
                                      style: TextStyle(
                                        color: TextSmall,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Image.asset('assets/wow.png'),
                                    iconSize: 20,
                                    color: OnBackground,
                                    onPressed: () {
                                    },
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text('궁금해요',
                                      style: TextStyle(
                                        color: TextSmall,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Image.asset('assets/wink.png'),
                                    iconSize: 20,
                                    color: OnBackground,
                                    onPressed: () {
                                    },
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text('말해주세요',
                                      style: TextStyle(
                                        color: TextSmall,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Image.asset('assets/bad.png'),
                                    iconSize: 20,
                                    color: OnBackground,
                                    onPressed: () {
                                    },
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text('힘내요',
                                      style: TextStyle(
                                        color: TextSmall,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        //value: 0,
                      ),
                      PopupMenuItem (
                        child: Divider(
                          height: 5,
                          thickness: 1,
                          endIndent: 0,
                          color: Colors.grey,
                        ),
                      ),
                      PopupMenuItem (
                        child:
                        Container(
                          alignment: Alignment.center,
                          child: Text('대화 기록'),
                        ),
                        value: 0,
                      ),
                      PopupMenuItem (
                        child: Divider(
                          height: 5,
                          thickness: 1,
                          endIndent: 0,
                          color: Colors.grey,
                        ),
                      ),
                      PopupMenuItem (
                        child: Container(
                          alignment: Alignment.center,
                          child: Text('정보'),
                        ),
                        value: 1,
                      ),
                    ];
                  },
                  onSelected: (result) {
                    if (result == 0) {
                      // Navigator.pushNamed(context, '/mypage',);
                      print('history');
                    }else if (result == 1){
                      // code for the remove action
                      print('mypage');
                    };
                  },
                ),
              ),
              Text('$namm'),
            ],),
    );

  }
  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return Text("null");  // return type can't be null, a widget was required
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
