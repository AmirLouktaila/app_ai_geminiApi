import 'package:app/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  TextEditingController addnamed = TextEditingController();
  TextEditingController search = TextEditingController();
  Color colorbg = Color.fromARGB(255, 0, 0, 0);
  List<String> nameSisson = [];
  List<String> filteredNames = [];
  Future<void> ReadItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nameSisson = prefs.getStringList("items") ?? [];
      filteredNames = nameSisson;
    });
  }

  Future<void> SaveItems(List<String> nameSisson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('items', nameSisson);

    ReadItems();
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  void _filterNames(String query) {
    setState(() {
      filteredNames = nameSisson
          .where((name) => name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  init() async {
    await ReadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 39, 39, 39),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
                  child: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: addnamed,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder()),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              var iduser = addnamed.text;
                                              if (!nameSisson
                                                  .contains(iduser)) {
                                                nameSisson.add(iduser);
                                                await SaveItems(nameSisson);
                                                addnamed.clear();
                                                Navigator.pop(context);
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => ChatPage(
                                                          name: iduser)),
                                                );
                                              }
                                            },
                                            child: const Text('Add'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      icon: Image.asset(
                        'images/edit.png',
                        width: 25,
                        height: 25,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: colorbg,
                        borderRadius: BorderRadius.circular(60)),
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                      child: TextField(
                        onChanged: _filterNames,
                        cursorColor: Colors.white,
                        controller: search,
                        decoration: InputDecoration(
                            prefix: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            border: InputBorder.none,
                            hintText: 'Search'),
                        style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (_, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ChatPage(
                                      name: filteredNames[index],
                                    )));
                      },
                      child: Ink(
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          title: Text(
                            filteredNames[index],
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: filteredNames.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
