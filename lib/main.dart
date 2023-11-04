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
      home: TaskListScreen(
        prefs: prefs,
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const TaskListScreen({super.key, required this.prefs});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  late Tasks tasks;

  bool showCompleted = true; // To control visibility of completed tasks
  // Define the focus node. To manage the lifecycle, create the FocusNode in
  // the initState method, and clean it up in the dispose method.
  late FocusNode myFocusNode;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tasks = Tasks(widget.prefs);

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
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
                if (!showCompleted && tasks[index].check) {
                  return Container(); // Return an empty container for hidden tasks
                }
                return ListTile(
                  title: Text(tasks[index].title),
                  leading: Checkbox(
                    value: tasks[index].check,
                    onChanged: (value) {
                      setState(() {
                        tasks.setCheck(index, value ?? false);
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
                  padding: const EdgeInsets.only(left: 10.0),
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
                          tasks.add(Task(value, false), widget.prefs);
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
    );
  }
}
