//import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:radio_grouped_buttons/radio_grouped_buttons.dart';
import 'colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  late int _maxnum = 2;
  late int _category;
  List<String> buttonList=["상담","면접","토론","만남","스터디","수다"];

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
        title: const Text('방 찾기',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: OnBackground,
              fontSize: 26,
            )
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            color: OnBackground,
            onPressed: () {
              Navigator.pushNamed(context, '/searchword',);
            },
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
                    Row(
                      children: [
                        Expanded(
                            child: Container()
                        ),
                        Container(
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
}
