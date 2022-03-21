import 'package:flutter/material.dart';

import 'colors.dart';

class SearchwordPage extends StatefulWidget {
  const SearchwordPage({Key? key}) : super(key: key);

  @override
  _SearchwordPageState createState() => _SearchwordPageState();
}

class _SearchwordPageState extends State<SearchwordPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _wordcontroller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Row(
                      children: [
                        Icon(Icons.search),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _wordcontroller,
                            decoration: const InputDecoration(
                              hintText: '채팅방 이름, 태그 검색',
                            ),
                            validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '채팅방 이름, 태그 검색 이름을 다시 입력해주세요';
                            }
                            return null;
                            },
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: OnBackground,
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);                      },
                          child: const Text('취소'),
                        ),
                      ]
                    ),
                    const SizedBox(height: 80),
                    Image.asset('assets/search.png'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
