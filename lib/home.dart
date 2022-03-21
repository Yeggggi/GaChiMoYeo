import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class NoteModel{
  String title;
  String content;

  NoteModel({
    required this.title,
    required this.content,
  });
}

class _HomePageState extends State<HomePage> {
  //AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Primary,
              ),
              child: Text(''),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                signOut();
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),*/
      appBar: AppBar(
        leading: Icon(Icons.settings),
        title: const Text('가치모여',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: OnBackground,
              fontSize: 26,
            )
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('assets/MyIcon.png'),
            iconSize: 50,
            color: OnBackground,
            onPressed: () {
              Navigator.pushNamed(context, '/mypage',);
            },
          ),
        ],
        backgroundColor: Bar,
        centerTitle: true,
      ),
      floatingActionButton:Padding(
        padding: const EdgeInsets.only(bottom: 0, right: 5),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 63.72,
                width: 63.72,
                child: FloatingActionButton(
                  heroTag: "searchbutton",
                  onPressed: () {
                    Navigator.pushNamed(context, '/search',);
                  },
                  backgroundColor: Secondary,
                  child: const Icon(Icons.search, size: 37),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 63.72,
                width: 63.72,
                child: FloatingActionButton(
                  heroTag: "makeroombutton",
                  onPressed: () {
                    Navigator.pushNamed(context, '/makeroom',);
                  },
                  backgroundColor: Secondary,
                  child: const Icon(Icons.add, size: 38),
                ),
              )
            ]
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            //if (!snapshot.hasData) {
            return
              //const SizedBox(height:10),
              ListView(
                children: snapshot.data!.docs.map((document) {
                  return Container(
                    child: Container(
                      //margin: EdgeInsets.all(10),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        //mainAxisSize: MainAxisSize.max,
                        children: [
                          //const SizedBox(height:10),
                          Row(
                            children: [
                              Expanded(
                                child: _RoomPanel(
                                  category: document['category'],
                                  title: document['title'],
                                  hashtag: document['hashtag'],
                                  maxnum: document['maxnum'],
                                  ready: document['ready'],
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    color: TextBig,
                                  ),
                                  key: const Key("1"),
                                ),
                              ),

                            ],
                          ),
                          const Divider(
                            height: 5,
                            thickness: 1,
                            endIndent: 0,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                  Container(
                    child: Center(child: Text(document['title'])),
                  );
                }).toList(),
              );
          }
        /*else {
            return Container(
              child: Text(
                "1",
                style: TextStyle(
                  color: TextBig,
                  fontSize: 15,
                ),
              ),
            );
          }*/
        //},
      ),
      //getGroupsWidget(),
      /*StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child:
              CircularProgressIndicator(),
            );
          } else
            return ListView(
              children: snapshot.data.docs.map((doc) {
                return Card(
                  child: ListTile(
                    title: Text(doc.data()['title']),
                  ),
                );
              }).toList(),
            );
        },
      ),*/
      /*Container(
        width: double.infinity,
        height: double.infinity,
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _RoomPanel(
                        title: "상담",
                        value: '오늘 하루도 수고했어요:)\n#위로 #음악공유 #수고했어\n최대인원: 2/4',
                        textStyle: TextStyle(
                          fontSize: 15,
                          color: TextBig,
                        ), key: const Key("2"),
                      ),
                    ),
                    IconButton(
                      icon: new Icon(Icons.meeting_room),
                      color: Primary,
                      onPressed: () {
                        Navigator.pushNamed(context, '/wait',);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),*/
    );
  }
}

/*Widget getGroupsWidget() {
  return FutureBuilder(
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        itemBuilder: (context, index) {
          DocumentSnapshot document = snapshot.data.docs[index];
          return ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: const Icon(Icons.group),
              title: Text(document.data()["title"]),
              subtitle: Text(""),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(groupId: document.data()["id"]),
                  ),
                );
              });
        },
        itemCount: snapshot.data.docs.length,
      );
    },
    future: loadGroups(),
  );
}
Future loadGroups() async {
  return await _fireStore
      .collection("GroupDetail")
      .where("members", arrayContains: _fireAuth.currentUser.uid)
      .get();
}*/

class _RoomPanel extends StatefulWidget {
  _RoomPanel({required Key key, required this.category, required this.title, required this.hashtag, required this.maxnum, required this.ready, required this.textStyle}): super(key: key);

  String category;
  String title;
  String hashtag;
  num maxnum;
  num ready;
  TextStyle textStyle;

  @override
  _RoomPanelState createState() => _RoomPanelState();
}

class _RoomPanelState extends State<_RoomPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.only(left: 31, top: 17, bottom: 14, right: 24),
        height: 135,
        /*decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Background,
                //Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withAlpha(180),
              ],
              tileMode: TileMode.repeated),
      ),*/
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(3),
                    width: 50,
                    child: Text(
                      widget.category,
                      style: TextStyle(
                        color: TextBig,
                        fontSize: 15,
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: SubPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          color: TextBig,
                          fontSize: 20,
                          letterSpacing: -1.2,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      widget.hashtag,
                      style: TextStyle(
                        color: TextBig,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                      children: [
                        const Icon(
                            Icons.group,
                            size: 16,
                            color: TextSmall
                        ),
                        SizedBox(width: 6.6),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.maxnum.toString()+'명  |  ',
                            style: TextStyle(
                              color: TextSmall,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (widget.ready == 0) ...[
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '대기 중',
                              style: TextStyle(
                                color: Secondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ] else if(widget.ready == 1)...[
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              '대화 중',
                              style: TextStyle(
                                color: Primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ]
                  ),
                ],
              ),
            ),
            Ink(
                decoration: const ShapeDecoration(
                  color: Primary,
                  shape: CircleBorder(),
                ),
                child: new SizedBox(
                    height: 54.0,
                    width: 54.0,
                    child: new IconButton(
                      icon: Image.asset('assets/EnterIcon.png'),
                      padding: new EdgeInsets.all(12.2),
                      color: OnPrimary,
                      //iconSize: 62,
                      onPressed: () {
                        Navigator.pushNamed(context, '/wait',);
                      },
                    )
                )
              /*IconButton(
                                icon: Image.asset('assets/EnterIcon.png'),
                                iconSize: 44,
                                color: OnPrimary,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/wait',);
                                },
                              ),*/
            ),
          ],
        )


    );
  }
}
