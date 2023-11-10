import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/constants.dart';

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
      theme: whiteTheme(),

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
  String _selectedCategory = 'WORK'; // Default selected category
  List<String> _categories = ['WORK', 'HOME', 'CHILL', 'Add'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title
        title: DropdownButton<String>(
          value: _selectedCategory,
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
          items: _categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 40,
                    color: Theme.of(context).textTheme.bodyMedium!.color),
              ),
            );
          }).toList(),
        ),
        //actions
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // setState(() {
              //   _selectedCategory = value;
              // });
            },
            itemBuilder: (BuildContext context) {
              return ['Settings'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    // style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList();
            },
          ),
        ],
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
