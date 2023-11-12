import 'package:drift/drift.dart';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  // IntColumn get category => integer().nullable()();
  // Foreign key referencing the TodoLists table
  IntColumn get todoListId => integer().nullable().references(TodoLists, #id)();
}

class TodoLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  //What percentage of this list is finished
  RealColumn get percentage => real().nullable()();
  BoolColumn get archived => boolean().nullable()();

  IntColumn get profileId => integer().nullable().references(Profiles, #id)();
}

@DataClassName("Category")
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  //not sure if I want this here, but whatever.
  RealColumn get percentage => real().nullable()();
}

@DriftDatabase(tables: [TodoItems, TodoLists])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}