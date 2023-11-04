//susceptable for file corruption imo.
import 'package:shared_preferences/shared_preferences.dart';

// an object of Tasks is easier to save than an array of Task.
class Tasks {
  List<String> _titleList = [];
  List<bool> _checkList = [];

  //loads state (if there's state)
  Tasks(SharedPreferences prefs) {
    loadState(prefs);
  }
  //returns the lowest of the two values
  get length => lowest(_titleList.length, _checkList.length);

  //returns task
  Task operator [](int index) {
    return Task(_titleList[index], _checkList[index]);
  }

  //adds also saves state.
  void add(Task task, SharedPreferences prefs) {
    _titleList.add(task.title);
    _checkList.add(task.check);
    saveState(prefs);
  }

  //TODO don't use this.
  void clear(SharedPreferences prefs) {
    _titleList = [];
    _checkList = [];
  }

  void setCheck(int index, bool value) {
    _checkList[index] = value;
  }

  Future<void> saveState(SharedPreferences prefs) async {
    //save titles
    await prefs.setStringList('titleList', _titleList);

    //conversion from List<bool> to List<String>
    List<String> conversedList =
        _checkList.map((value) => value.toString()).toList();

    //save List<bool>
    await prefs.setStringList('checkList', conversedList);
  }

  void loadState(SharedPreferences prefs) {
    //load titles
    final titleList = prefs.getStringList('titleList') ?? [];

    final preConversedList = prefs.getStringList('checkList');
    //conversion from List<String> to List<bool>
    List<bool> checkList =
        (preConversedList ?? []).map((value) => value == "true").toList();

    //set to loaded variables.
    _titleList = titleList;
    _checkList = checkList;
  }
}

//class to pass data to Tasks, not actually used in Tasks though.
class Task {
  String title;
  bool check;

  Task(this.title, this.check);
}

int lowest(int a, int b) {
  if (a < b) {
    return a;
  } else {
    return b;
  }
}
