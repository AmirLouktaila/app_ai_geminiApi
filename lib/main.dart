import 'dart:math';

import 'package:app/model/provider_change_wallapaper.dart';
import 'package:app/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProviderChangeWallapaper()),
    ],
    child: MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String NewChat = 'newChat';
  List<String> nameSisson = [];
  int newchatrandom = 0;

  Future<void> ReadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedItems = prefs.getStringList("items") ?? [];
    setState(() {
      nameSisson = loadedItems;
    });
  }

  Future<void> SaveItems(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('items', items);
  }

  @override
  void initState() {
    super.initState();
    newchatrandom = Random().nextInt(1000000);
    getlistsisson();
  }

  getlistsisson() async {
    await ReadItems();

    String newName = '$NewChat$newchatrandom';

    if (!nameSisson.contains(newName)) {
      setState(() {
        nameSisson.add(newName);
      });
      await SaveItems(nameSisson);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChatPage(
      name: '$NewChat$newchatrandom',
    );
  }
}
