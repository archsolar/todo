import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:todo/constants.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 2, max: 32)();
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
  TextColumn get name => text().withLength(min: 2, max: 64)();
  //What percentage of this list is finished
  RealColumn get percentage => real().nullable()();
  BoolColumn get archived => boolean()();
  //TODO Be aware that, in sqlite3, foreign key references aren't enabled by default. They need to be enabled with PRAGMA foreign_keys = ON. A suitable place to issue that pragma with drift is in a post-migration callback.
  IntColumn get profileId => integer().nullable().references(Profiles, #id)();
}

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 64)();
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
