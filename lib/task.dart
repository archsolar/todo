//susceptable for file corruption imo.
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

// an object of Tasks is easier to save than an array of Task.
class Tasks {
  List<String> _titleList = [];
  List<bool> _checkList = [];
  //TODO I don't want to store year and month in here. just on the total daily TODO.
  List<DateTime> _onCreateList = [];
  //loads state (if there's state)
  Tasks(SharedPreferences prefs) {
    loadState(prefs);
  }
  //returns the lowest of all the lists
  get length => lowest(
      _onCreateList.length, lowest(_titleList.length, _checkList.length));

  //returns task
  Task operator [](int index) {
    return Task(_titleList[index], _checkList[index], _onCreateList[index]);
  }

  void removeAt(int index, SharedPreferences prefs) {
    if (length >= index) {
      _titleList.removeAt(index);
      _checkList.removeAt(index);
      _onCreateList.removeAt(index);
    } else {
      //ERROR
      exit(1);
    }
    saveState(prefs);
  }

  //adds also saves state.
  void add(Task task, SharedPreferences prefs) {
    _titleList.add(task.title);
    _checkList.add(task.check);
    _onCreateList.add(DateTime.now());
    saveState(prefs);
  }

  //TODO don't use this.
  //Add an are you sure timer before this function is called... 3..2..1
  void clear(SharedPreferences prefs) {
    _titleList = [];
    _checkList = [];
    _onCreateList = [];
    saveState(prefs);
  }

  void setCheck(int index, bool value) {
    _checkList[index] = value;
  }

  //TODO right now it saves EVERY TODO LIST ENTRY.
  Future<void> saveState(SharedPreferences prefs) async {
    //save titles
    await prefs.setStringList('titleList', _titleList);

    //save List<bool>
    List<String> conversedListBool =
        _checkList.map((value) => value.toString()).toList();
    await prefs.setStringList('checkList', conversedListBool);

    //save List<DateTime>
    List<String> timesListTime =
        _onCreateList.map((value) => value.toIso8601String()).toList();
    await prefs.setStringList('timesList', timesListTime);
  }

  void loadState(SharedPreferences prefs) {
    //load titles
    final titleList = prefs.getStringList('titleList') ?? [];

    //load checkList
    final preConversedListBool = prefs.getStringList('checkList');
    //conversion from List<String> to List<bool>
    List<bool> checkList =
        (preConversedListBool ?? []).map((value) => value == "true").toList();

    //load List<DateTime>
    final preConversedListTime = prefs.getStringList('timesList');
    List<DateTime> timeList = (preConversedListTime ?? [])
        .map((value) => DateTime.parse(value))
        .toList();
    //set to loaded variables.
    _titleList = titleList;
    _checkList = checkList;
    _onCreateList = timeList;
  }
}

//class to pass data to Tasks, not actually used in Tasks though.
class Task {
  String title;
  bool check = false;
  DateTime timeCreated = DateTime.now();

  Task(this.title, this.check, this.timeCreated);
}

int lowest(int a, int b) {
  if (a < b) {
    return a;
  } else {
    return b;
  }
}
