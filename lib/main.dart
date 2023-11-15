import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/constants.dart';
import 'package:todo/database.dart';
import 'package:todo/generic_widget.dart';

import 'task_list_screen.dart';

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
  Profile? _currentProfile = null;

  late FocusNode _newListFocusNode;
  final TextEditingController _textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _newListFocusNode = FocusNode();
    _loadProfiles();
  }

  @override
  void dispose() {
    _newListFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    try {
      _profiles = await widget.database.allProfiles;
      _currentProfile = _profiles.first;
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
      body: mainColumn(),
    );
  }

  /// Asynchronously builds a DropdownButton with profiles from the database.
  /// Handles loading, errors, and allows the user to select a profile.
  FutureBuilder futureDropdownButton() {
    return FutureBuilder(
      future: widget.database.allProfiles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            _currentProfile == null) {
          // While the future is still running, show a loading indicator or placeholder.
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If there's an error, show an error message.
          return Text('Error loading profiles: ${snapshot.error}');
        } else {
          // If the future is complete and successful, build the DropdownButton.
          return DropdownButton<String>(
            value: _currentProfile!.name,
            onChanged: (String? value) {
              setState(() {
                _currentProfile = profileLookup(value!);
              });
            },
            items:
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

  // returns a ListView or a Centered Text
  FutureBuilder newFutureListView() {
    return FutureBuilder(
        future: widget.database.getEntriesInProfile(_currentProfile),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _currentProfile == null) {
            // While the future is still running, show a loading indicator or placeholder.
            return Center(
                child: SizedBox(
              child: CircularProgressIndicator(),
              height: 60.0,
              width: 60.0,
            ));
          } else if (snapshot.hasError) {
            // If there's an error, show an error message.
            return Text('Error loading profiles: ${snapshot.error}');
          } else {
            bool empty = snapshot.data.length == 0;
            //the whole thing?
            return empty
                ? emptyBackgroundTextMessage("Add list down below ⬇️")
                : listView(snapshot);
          }
        });
  }

  Column mainColumn() {
    return Column(
      children: [
        Expanded(
          child: newFutureListView(),
        ),
        const Divider(height: 1.0),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: Row(
            children: [
              Flexible(
                  child: Container(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextField(
                    controller:
                        _textController, // Attach the TextEditingController
                    focusNode: _newListFocusNode, // Attach the FocusNode
                    canRequestFocus: true,
                    decoration: const InputDecoration.collapsed(
                      hintText: "New list",
                    ),
                    onSubmitted: (value) {
                      if (value.isEmpty) {
                        return;
                      }
                      setState(() {
                        widget.database.addList(TodoListsCompanion(
                            name: drift.Value(value),
                            profileId: drift.Value(_currentProfile!.id),
                            archived: drift.Value(false)));
                        // Keep focus on the TextField
                        FocusScope.of(context).requestFocus(_newListFocusNode);
                        // Clear the TextField
                        _textController.clear();
                      });
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

  ListView listView(AsyncSnapshot<dynamic> snapshot) {
    return ListView.builder(
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
                builder: (context) => TaskListScreen(prefs: widget.prefs),
              ),
            );
          }, // Handle your onTap here.
        );
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
