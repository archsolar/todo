import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/constants.dart';
import 'package:todo/database.dart';

import 'task_list_screen.dart';

//TODO I'd like a "something went wrong screen."
// StatefulWidget mainScreen;

Future<void> firstLaunch(AppDatabase database) async {
  //if it exists and is valid, then return.
  if (await File(await getSqlitePath()).exists()) {
    //maybe it's not necessary to check if it's valid
    return;
  }
  //MAYBE check if there are already todo entries.
  List<Profile> allProfiles = await database.select(database.profiles).get();
  List<TodoList> allLists = await database.select(database.todoLists).get();
  if (allProfiles.isEmpty) {
    // add default profiles
    database
        .into(database.profiles)
        .insert(ProfilesCompanion.insert(name: 'Work'));
    database
        .into(database.profiles)
        .insert(ProfilesCompanion.insert(name: 'Home'));
    database
        .into(database.profiles)
        .insert(ProfilesCompanion.insert(name: 'Chill'));
  }
  if (allLists.isEmpty) {
    // add default list
    //TODO add a background text that says "Add a list down below" when it's empty
    //TODO this needs a reference to profiles!!
    database
        .into(database.todoLists)
        .insert(TodoListsCompanion.insert(name: "Project A"));
  }
}

void main() async {
  //obtain saved state.
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //sql init
  final database = AppDatabase();

  //first launch
  await firstLaunch(database);
  //test
  await database.into(database.todoItems).insert(TodoItemsCompanion.insert(
        title: 'Test Job',
        done: false,
        //TODO foreign key how?
        todoListId: 0,
      ));
  List<TodoItem> allItems = await database.select(database.todoItems).get();
  print('items in database: $allItems');

  //
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
      home: MainScreen(prefs: prefs),
    );
  }
}

class MainScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const MainScreen({super.key, required this.prefs});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selectedCategory = 'WORK'; // Default selected category
  List<String> _categories = ['WORK', 'HOME', 'CHILL', 'Edit'];
  

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
