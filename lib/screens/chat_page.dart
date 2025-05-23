import 'dart:convert';

import 'package:app/model/api_gemini.dart';
import 'package:app/model/provider_change_wallapaper.dart';
import 'package:app/screens/drawer_page.dart';
import 'package:app/screens/wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/python.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatPage extends StatefulWidget {
  final String name;
  const ChatPage({required this.name, Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController getText = TextEditingController();
  List<Map<String, String>> ChatList = [];
  bool typing = false;
  String ainame = 'Lkt ai';
  Color colorbg = Color.fromARGB(255, 2, 2, 2);
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isListeningStop = false;
  bool sendDisbal = false;
  String _recognizedText = 'اضغط على الميكروفون للبدء...';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadChatListLocally();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    getText.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('🟡 الحالة: $status'),
        onError: (errorNotification) =>
            print('❌ خطأ: ${errorNotification.errorMsg}'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _isListeningStop = true;
        });
        _speech.listen(
          localeId: "ar-DZ",
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
              getText = TextEditingController(text: _recognizedText);
            });
          },
        );
      } else {
        print('🔴 التعرف على الصوت غير متاح');
      }
    } else {
      setState(() {
        _isListening = false;
        _isListeningStop = false;
      });
      _speech.stop();
    }
  }

  Future<void> loadChatListLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('Data_${widget.name}');
    if (jsonData != null) {
      setState(() {
        ChatList = (jsonDecode(jsonData) as List)
            .map<Map<String, String>>(
              (item) => Map<String, String>.from(
                item.map(
                    (key, value) => MapEntry(key.toString(), value.toString())),
              ),
            )
            .toList();
      });
      print("✅ تم تحميل المحادثات من SharedPreferences");
    }
  }

  Future<void> saveChatListLocally(List<Map<String, String>> listc) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(listc);
    await prefs.setString('Data_${widget.name}', jsonData);
    print("✅ تم حفظ المحادثات بنجاح");
  }

  getchatai(String chating) async {
    setState(() {
      typing = true;
      sendDisbal = true;
    });

    var apichating =
        await ApiGmini("Api_key", chating);

    setState(() {
      ChatList.add({
        "name": ainame,
        "msg": chating,
        "code": '',
      });
      typing = false;
      sendDisbal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorbg,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: colorbg,
        title: ListTile(
          title: Text(
            "lkt ai",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            '${typing ? 'AI Typing ...' : ''}',
            style: TextStyle(color: Colors.white),
          ),
          leading: CircleAvatar(
            child: Image.asset('images/bot.png'),
          ),
        ),
      ),
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            color: colorbg,
            // image: DecorationImage(
            //   image: NetworkImage(
            //       context.watch<ProviderChangeWallapaper>().url_wallapaper),
            //   repeat: ImageRepeat.repeat,
            // ),
          ),
        ),
        SafeArea(
            child: Column(
          children: [
            Expanded(
              child: ChatList.length <= 0
                  ? Center(
                      child: Text(
                        'كيف يمكنني مساعدتك',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: ChatList.length,
                      itemBuilder: (_, index) {
                        print(ChatList);
                        saveChatListLocally(ChatList);
                        final chat = ChatList[index];
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Align(
                            alignment: chat['name'] == ainame
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: chat['name'] == ainame
                                    ? Color.fromARGB(109, 0, 0, 0)
                                    : Color.fromARGB(255, 39, 39, 39),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: chat['name'] == ainame
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      chat['msg'] ?? '',
                                      textAlign: chat['name'] == ainame
                                          ? TextAlign.left
                                          : TextAlign.right,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    if ((chat['code'] ?? '').isNotEmpty)
                                      Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: ElevatedButton(
                                                onPressed: () {},
                                                child: Text('Copy')),
                                          ),
                                          CodeTheme(
                                            data: CodeThemeData(
                                                styles: monokaiSublimeTheme),
                                            child: Container(
                                              height: 300,
                                              child: SingleChildScrollView(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: CodeField(
                                                  controller: CodeController(
                                                    text: chat['code']!,
                                                    language: python,
                                                  ),
                                                  gutterStyle:
                                                      const GutterStyle(
                                                          width: 60),
                                                  readOnly: true,
                                                  textStyle: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 39, 39, 39),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 39, 39, 39),
                              borderRadius: BorderRadius.circular(60)),
                          child: TextField(
                            maxLines: null,
                            onChanged: (value) {
                              setState(() {
                                _isListening = value.isNotEmpty;
                              });
                            },
                            cursorColor: Colors.white,
                            controller: getText,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type message'),
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    InkWell(
                        onTap: sendDisbal
                            ? null
                            : () async {
                                if (!_isListening && !_isListeningStop) {
                                  _listen();
                                } else if (_isListeningStop) {
                                  _speech.stop();
                                  setState(() {
                                    _isListening = true;
                                    _isListeningStop = false;
                                  });
                                } else if (getText.text.trim().isNotEmpty) {
                                  var chating = getText.text.trim();
                                  setState(() {
                                    ChatList.add({
                                      "name": widget.name,
                                      "msg": chating,
                                      "code": ""
                                    });
                                    _isListening = false;
                                    getText.clear();
                                  });
                                  await getchatai(chating);
                                }
                              },
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: []),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                _isListeningStop
                                    ? 'images/close.png'
                                    : _isListening
                                        ? 'images/send.png'
                                        : 'images/voice.png',
                                color: Colors.black,
                                width: 25,
                                height: 25,
                              )),
                        ))
                  ],
                ),
              ),
            )
          ],
        )),
      ]),
      drawer: DrawerPage(),
    );
  }
}
