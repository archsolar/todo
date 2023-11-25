import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:todo/constants.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 255)();
  BoolColumn get done => boolean()();
  // IntColumn get category => integer().nullable()();
  // Foreign key referencing the TodoLists table
  IntColumn get todoListId => integer().references(TodoLists, #id)();
  // sqlite3 will enforce that this column only contains timestamps happening after (the beginning of) 1950.
  DateTimeColumn get creationTime =>
      dateTime().withDefault(currentDateAndTime)();
}

class TodoLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 255)();
  //What percentage of this list is finished
  RealColumn get percentage => real().nullable()();
  BoolColumn get archived => boolean()();
  //TODO Be aware that, in sqlite3, foreign key references aren't enabled by default. They need to be enabled with PRAGMA foreign_keys = ON. A suitable place to issue that pragma with drift is in a post-migration callback.
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();
}

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 255)();
  //not sure if I want this here, but whatever.
  RealColumn get percentage => real().nullable()();
}

@DriftDatabase(
  tables: [TodoItems, TodoLists, Profiles],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// loads all profiles
  Future<List<Profile>> get allProfiles => select(profiles).get();

  /// loads all todoLists
  Future<List<TodoList>> get allTodoLists => select(todoLists).get();

  /// loads all todoItems
  Future<List<TodoItem>> get allTodoItems => select(todoItems).get();

  /// watches all profiles
  Stream<List<Profile>> get watchAllProfiles => select(profiles).watch();

  /// watches all todoLists in a given profile. The stream will automatically
  /// emit new items whenever the underlying data changes.
  Stream<List<TodoList>> watchTodoListsInProfile(Profile profile) {
    return (select(todoLists)..where((t) => t.profileId.equals(profile.id)))
        .watch();
  }

  Stream<List<TodoItem>> watchTodoItemsInList(TodoList todoList) {
    return (select(todoItems)..where((t) => t.todoListId.equals(todoList.id)))
        .watch();
  }

  /// gets all todoLists in a given profile.
  Future<List<TodoList>>? getEntriesInProfile(Profile? profile) {
    if (profile == null) {
      return null;
    }
    return (select(todoLists)..where((t) => t.profileId.equals(profile.id)))
        .get();
  }

  /// adds to todoLists
  /// returns the generated id
  Future<int> addList(TodoListsCompanion entry) {
    return into(todoLists).insert(entry);
  }

  /// adds to todoItems
  /// returns the generated id
  Future<int> addTodo(TodoItemsCompanion entry) {
    return into(todoItems).insert(entry);
  }

  /// update todo item
  Future updateTodo(TodoItem entry) {
    return update(todoItems).replace(entry);
  }
}

Future<Directory> getDirectory() async {
  Directory appFolder = await getApplicationDocumentsDirectory();
  return Directory("${appFolder.path}/$appName");
}

/// get path to sqlite as string
Future<String> getSqlitePath() async {
  final dir = await getDirectory();
  return p.join(dir.path, 'db.sqlite');
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final file = File(await getSqlitePath());
    return NativeDatabase.createInBackground(file);
  });
}

Future<void> initializeApp(AppDatabase database) async {
  //if it exists and is valid, then return.
  if (await File(await getSqlitePath()).exists()) {
    //check if it contains profiles.
    List<Profile> allProfiles = await database.select(database.profiles).get();
    if (!allProfiles.isEmpty) {
      return;
    }
  }
  //MAYBE check if there are already todo entries.
  List<Profile> allProfiles = await database.select(database.profiles).get();
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
}
