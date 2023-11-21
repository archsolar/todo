import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/constants.dart';
import 'package:todo/database.dart';
import 'package:todo/generic_widget.dart';

import 'task_list_screen.dart';

class Global {
  static final AppDatabase _database = AppDatabase();

  static AppDatabase get database => _database;
}

void main() async {
  //obtain saved state.
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //first launch check
  await initializeApp(Global.database);
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
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  List<Profile> _profiles = [];
  Profile? _currentProfile;
  late FocusNode _textFieldFocus;
  final TextEditingController _textController = TextEditingController();

  late Stream<List<Profile>> profileStream;
  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _textFieldFocus = FocusNode();
  }

  Future<void> _loadProfiles() async {
    try {
      // this seems weird, curious how to rewrite
      profileStream = Global.database.watchAllProfiles;
      _profiles = await Global.database.allProfiles;
      _currentProfile = _profiles.first;
      setState(() {}); // Trigger a rebuild to reflect the changes in the UI
    } catch (e) {
      final snackBar = SnackBar(content: Text("Error: loading profiles: $e"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void dispose() {
    _textFieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamDropDownButton(
            currentProfile: _currentProfile,
            profileStream: profileStream,
            onChanged: (String value) {
              _currentProfile = profileLookup(value);
            }),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              //TODO what is this again?
            },
            itemBuilder: (BuildContext context) {
              return ['Settings'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: mainColumn(),
    );
  }

  // returns a ListView or a Centered Text
  FutureBuilder todoListViewer() {
    return FutureBuilder(
        future: Global.database.getEntriesInProfile(_currentProfile),
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
                ? emptyBackgroundTextMessage("Add list down below")
                : listView(snapshot);
          }
        });
  }

  Column mainColumn() {
    return Column(
      children: [
        Expanded(
          child: todoListViewer(),
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
                    maxLength: 255,
                    controller:
                        _textController, // Attach the TextEditingController
                    focusNode: _textFieldFocus, // Attach the FocusNode
                    canRequestFocus: true,
                    decoration: const InputDecoration.collapsed(
                      hintText: "New list",
                    ),
                    onSubmitted: (newListName) {
                      if (newListName.isEmpty) return;
                      try {
                        Global.database
                            .addList(TodoListsCompanion(
                                name: drift.Value(newListName),
                                profileId: drift.Value(_currentProfile!.id),
                                archived: drift.Value(false)))
                            .then((value) {
                          setState(() {});
                        });
                      } catch (e) {
                        // Show a Snackbar with an error message
                        final snackBar = SnackBar(
                            content: Text(
                                "An error occurred while adding the list."));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      //TODO why does it keep focusing when I click on something else?
                      // Keep focus on the TextField
                      // Check if the text field has focus before refocusing
                      if (FocusScope.of(context).focusedChild ==
                          _textController) {
                        FocusScope.of(context).requestFocus(_textFieldFocus);
                      }
                      // Clear the TextField
                      _textController.clear();
                      FocusScope.of(context).requestFocus(new FocusNode());
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
            onPressed: () => Navigator.of(context).maybePop(),
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
      final snackBar = SnackBar(content: Text("Error: profile not found."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }
  }
}

class StreamDropDownButton extends StatelessWidget {
  final Profile? currentProfile;
  final Stream<List<Profile>> profileStream;
  final Function(String) onChanged;

  StreamDropDownButton({
    required this.currentProfile,
    required this.profileStream,
    required this.onChanged,
  });

  /// Asynchronously builds a DropdownButton with profiles from the database.
  /// Handles loading, errors, and allows the user to select a profile.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            currentProfile == null) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return DropdownButton<String>(
            value: currentProfile!.name,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onChanged: (String? value) {
              onChanged(value!);
            },
            items:
                snapshot.data?.map<DropdownMenuItem<String>>((Profile value) {
                      return DropdownMenuItem<String>(
                        value: value.name,
                        child: Text(value.name),
                      );
                    }).toList() ??
                    [],
          );
        }
      },
    );
  }
}

// class TodoListViewer extends StatelessWidget {
//   final Future<List<TodoList>> todoListFuture;
//   TodoListViewer({required this.todoListFuture});

//   @override
//   Widget build(BuildContext context) {
//     return  Placeholder();
//   }
// }
