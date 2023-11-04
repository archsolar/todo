// import 'package:shared_preferences/shared_preferences.dart';

class Tasks {
  List<String> _titleList;
  List<bool> _checkList;

  Tasks(this._titleList, this._checkList);

  get length => _titleList.length;

  //returns task
  Task operator [](int index) {
    return Task(_titleList[index], _checkList[index]);
  }

  void add(Task task) {
    _titleList.add(task.title);
    _checkList.add(task.check);
  }

  void set_check(int index, bool value) {
    _checkList[index] = value;
  }
}

//class to pass data to Tasks, not actually used in Tasks though.
class Task {
  String title;
  bool check;

  Task(this.title, this.check);
}
