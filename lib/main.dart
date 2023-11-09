import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'task.dart';
import 'task_list_screen.dart';

void main() async {
  //obtain saved state.
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData.dark(),
      home: ListsScreen(prefs: prefs),
      //     TaskListScreen(
      //   prefs: prefs,
      // ),
    );
  }
}

class ListsScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const ListsScreen({super.key, required this.prefs});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),

        title: const Text('WORK'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, i) {
                return ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.article_outlined),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text('TODO list entry $i'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TaskListScreen(prefs: widget.prefs)));
                  }, // Handle your onTap here.
                );
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                //TODO why flexible here?
                Flexible(
                    child: Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                      // controller:
                      //     _textController, // Attach the TextEditingController
                      // focusNode: myFocusNode, // Attach the FocusNode
                      canRequestFocus: true,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Add to list",
                      ),
                      onSubmitted: (value) {
                        // _addTask(value);
                      }),
                )),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // _addTask(_textController.text);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
