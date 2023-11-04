import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'task.dart';


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
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  bool showCompleted = true; // To control visibility of completed tasks
  // Define the focus node. To manage the lifecycle, create the FocusNode in
  // the initState method, and clean it up in the dispose method.
  late FocusNode myFocusNode;
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: Icon(showCompleted
                ? Icons.check_box_outline_blank
                : Icons.check_box),
            onPressed: () {
              setState(() {
                showCompleted = !showCompleted;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                if (!showCompleted && tasks[index].isDone) {
                  return Container(); // Return an empty container for hidden tasks
                }
                return ListTile(
                  title: Text(tasks[index].title),
                  leading: Checkbox(
                    value: tasks[index].isDone,
                    onChanged: (value) {
                      setState(() {
                        tasks[index].isDone = value ?? false;
                      });
                    },
                  ),
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
                  padding: EdgeInsets.only(left: 10.0),
                  child: TextField(
                      controller:
                          _textController, // Attach the TextEditingController

                      focusNode: myFocusNode, // Attach the FocusNode
                      canRequestFocus: true,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Send a message",
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          tasks.add(Task(value, false));
                        });
                        // Keep focus on the TextField
                        FocusScope.of(context).requestFocus(myFocusNode);
                        // Clear the TextField
                        _textController.clear();
                      }),
                )),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // _handleSubmitted(_textController.text);
                  },
                ),
              ],
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _addTask();
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  void _addTask() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: myFocusNode,
                canRequestFocus: true,
                decoration: const InputDecoration(
                  hintText: 'Task',
                ),
                onSubmitted: (value) {
                  setState(() {
                    tasks.add(Task(value, false));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
    //TODO bruhhhhh
    myFocusNode.requestFocus();
  }
}
