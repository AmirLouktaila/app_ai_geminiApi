import 'package:app/model/provider_change_wallapaper.dart';
import 'package:app/model/wallpaper_items.dart';
import 'package:app/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wallpaper extends StatefulWidget {
  const Wallpaper({super.key});

  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallpaper'),
      ),
      body: SafeArea(
          child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 2,
        ),
        itemBuilder: (_, index) {
          return InkWell(
            onTap: () {
              context
                  .read<ProviderChangeWallapaper>()
                  .changeWallapaper(textures[index]['url'].toString());
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(name: 'Salah Louktaila')));
            },
            child: Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                color: Color(0xFF009985), // ← اللون الأساسي
                image: DecorationImage(
                  image: NetworkImage(
                      textures[index]['url'].toString()), // ← خلفية الصورة
                  repeat: ImageRepeat.repeat, // لتكرار الباترن
                ),
              ),
            ),
          );
        },
        itemCount: textures.length,
      )),
    );
  }
}
