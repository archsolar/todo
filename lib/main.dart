import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/constants.dart';
import 'package:todo/database.dart';
import 'package:todo/generic_widget.dart';

import 'widgets.dart';

void main() async {
  // obtain saved state.
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // first launch check
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

  late Stream<List<Profile>> profileStream;
  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      // this seems weird, curious how to rewrite
      profileStream = Global.database.watchAllProfiles;
      _profiles = await Global.database.allProfiles;
      _currentProfile = _profiles.first;
      setState(() {}); // trigger a rebuild to reflect the changes in the UI
    } catch (e) {
      final snackBar = SnackBar(content: Text("Error: loading profiles: $e"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamDropDownButton(
            currentProfile: _currentProfile,
            profileStream: profileStream,
            //defines
            onChanged: (String value) {
              setState(() {
                print(value);
                _currentProfile = profileLookup(value);
              });
            }),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              //TODO settings page
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
  FutureBuilder todoListsViewer() {
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
                : TodoListList(
                    snapshot,
                    Icons.article_outlined,
                    (data) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TodoListPage(
                            list: data,
                          ),
                        ),
                      );
                    },
                  );
          }
        });
  }

  Column mainColumn() {
    return Column(
      children: [
        Expanded(
          child: todoListsViewer(),
        ),
        const Divider(height: 1.0),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: BottomInput(
            textSuggestion: 'New list',
            onSubmit: (String newListName) {
              if (newListName.isEmpty) {
                return;
              } else {
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
                      content:
                          Text("An error occurred while adding the list."));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
            },
          ),
        )
      ],
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

class TodoListPage extends StatefulWidget {
  final TodoList _list;
  TodoListPage({super.key, required TodoList list}) : _list = list;

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late Stream<List<TodoItem>> todoStream;

  @override
  void initState() {
    super.initState();
    todoStream = Global.database.watchTodoItemsInList(widget._list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget._list.name),
      ),
      body: Column(
        children: [
          //listviewbuilder
          //TODO replace with listviewbuilder
          Expanded(
              child: StreamBuilder(
            stream: todoStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.data == null) {
                //TODO why would this be null?
                return Text('Error: snapshot.data == null');
              } else {
                bool empty = snapshot.data!.length == 0;
                return empty
                    ? emptyBackgroundTextMessage("Add items down below!")
                    //TODO edit listViewBuilder to facilitate for this class as well
                    : TodoItemsList(snapshot, Icons.check_box, (data) {});
              }
            },
          )),
          const Divider(height: 1.0),
          BottomInput(
            textSuggestion: "Add to list",
            onSubmit: (String value) => _addTask(value),
          ),
        ],
      ),
    );
  }

  ListView TodoItemsList(
      AsyncSnapshot<dynamic> snapshot, IconData icon, Function onTapCallback) {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(height: 1),
      itemCount: snapshot.data?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          // //TODO global color?
          // tileColor: Color.fromARGB(96, 153, 153, 153),
          leading: Checkbox(
            value: snapshot.data[index].done,
            onChanged: (value) {
              // then set state
              //make a todo item with same data except TodoItem.done
              TodoItem updated = TodoItem(
                  id: snapshot.data[index].id,
                  name: snapshot.data[index].name,
                  done: !snapshot.data[index].done,
                  todoListId: snapshot.data[index].todoListId,
                  creationTime: snapshot.data[index].creationTime);
              Global.database.updateTodo(updated);
              setState(() {
                print("boop");
              });
            },
          ),
          //use subtitle to use normalBody
          subtitle: Text(snapshot.data![index].name),
          onTap: () {
            onTapCallback(snapshot.data![index]);
          }, // Handle your onTap here.
        );
      },
    );
  }

  Future<void> _addTask(String text) async {
    await Global.database
        .addTodo(TodoItemsCompanion(
            name: drift.Value(text),
            todoListId: drift.Value(widget._list.id),
            done: drift.Value(false)))
        .then((value) {
      setState(() {});
    });
  }
}
