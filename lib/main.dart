import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/constants.dart';
import 'package:todo/database.dart';

import 'task_list_screen.dart';

//TODO I'd like a "something went wrong screen."
// StatefulWidget mainScreen;

Future<void> initializeApp(AppDatabase database) async {
  //if it exists and is valid, then return.
  if (await File(await getSqlitePath()).exists()) {
    //check if it contains profiles.
    List<Profile> allProfiles = await database.select(database.profiles).get();
    if (allProfiles.isEmpty) {
      return;
    }
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
  print("all profiles: $allProfiles");
  if (allLists.isEmpty) {
    // add default list
    //TODO add a background text that says "Add a list down below" when it's empty
    //TODO this needs a reference to profiles!!
    database
        .into(database.todoLists)
        .insert(TodoListsCompanion.insert(name: "Project A", archived: false));
  }
}

void main() async {
  //obtain saved state.
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //sql init
  final database = AppDatabase();
  //first launch check
  await initializeApp(database);
  //test
  // await database.into(database.todoItems).insert(TodoItemsCompanion.insert(
  //       title: 'Test Job',
  //       done: false,
  //       //TODO foreign key how?
  //       todoListId: 0,
  //     ));
  // List<TodoItem> allItems = await database.select(database.todoItems).get();
  // print('items in database: $allItems');

  //
  runApp(MyApp(prefs: prefs, database: database));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AppDatabase database;

  const MyApp({super.key, required this.prefs, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: whiteTheme(),
      home: MainScreen(prefs: prefs, database: database),
    );
  }
}

class MainScreen extends StatefulWidget {
  final SharedPreferences prefs;
  //is it a good idea to get the database here?
  final AppDatabase database;

  const MainScreen({super.key, required this.prefs, required this.database});

  @override
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  List<Profile> _profiles = [];
  //TODO check if this is correctly handled.
  Profile? dropdownValue = null;
  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      _profiles = await widget.database.allProfiles;
      dropdownValue = _profiles.first;
      // Run code for each profile
      for (Profile profile in _profiles) {
        print('Profile Name: ${profile.name}');
        // Add more code here if needed
      }
      setState(() {}); // Trigger a rebuild to reflect the changes in the UI
    } catch (e) {
      print('Error loading profiles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: futureDropdownButton(),
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
      body: futureListView(),
    );
  }

  Column oldColumn(BuildContext context) {
    return Column(
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
                      builder: (context) => TaskListScreen(prefs: widget.prefs),
                    ),
                  );
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
    );
  }

  FutureBuilder futureDropdownButton() {
    return FutureBuilder(
      future: widget.database.allProfiles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            dropdownValue == null) {
          // While the future is still running, show a loading indicator or placeholder.
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If there's an error, show an error message.
          return Text('Error loading profiles: ${snapshot.error}');
        } else {
          // If the future is complete and successful, build the DropdownButton.
          return DropdownButton<String>(
            value: dropdownValue!.name,
            onChanged: (String? value) {
              setState(() {
                dropdownValue = profileLookup(value!);
              });
            },
            items:
                //TODO does this ? really need to be there?
                snapshot.data?.map<DropdownMenuItem<String>>((Profile value) {
              return DropdownMenuItem<String>(
                value: value.name,
                child: Text(value.name),
              );
            }).toList(),
          );
        }
      },
    );
  }

  FutureBuilder futureListView() {
    return FutureBuilder(
      future: widget.database.allProfiles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            dropdownValue == null) {
          // While the future is still running, show a loading indicator or placeholder.
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If there's an error, show an error message.
          return Text('Error loading profiles: ${snapshot.error}');
        } else {
          //the whole thing?
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.article_outlined),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: Text(snapshot.data![index].name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TaskListScreen(prefs: widget.prefs),
                          ),
                        );
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
          );
        }
      },
    );
  }

  Profile? profileLookup(String name) {
    try {
      return _profiles.firstWhere((profile) => profile.name == name);
    } catch (e) {
      // Handle the case where the profile is not found
      // For example, you can return a default profile or throw an exception.
      return null;
    }
  }
}
