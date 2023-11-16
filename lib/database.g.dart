// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _percentageMeta =
      const VerificationMeta('percentage');
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
      'percentage', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, percentage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('percentage')) {
      context.handle(
          _percentageMeta,
          percentage.isAcceptableOrUnknown(
              data['percentage']!, _percentageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      percentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}percentage']),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String name;
  final double? percentage;
  const Profile({required this.id, required this.name, this.percentage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || percentage != null) {
      map['percentage'] = Variable<double>(percentage);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      percentage: percentage == null && nullToAbsent
          ? const Value.absent()
          : Value(percentage),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      percentage: serializer.fromJson<double?>(json['percentage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'percentage': serializer.toJson<double?>(percentage),
    };
  }

  Profile copyWith(
          {int? id,
          String? name,
          Value<double?> percentage = const Value.absent()}) =>
      Profile(
        id: id ?? this.id,
        name: name ?? this.name,
        percentage: percentage.present ? percentage.value : this.percentage,
      );
  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('percentage: $percentage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, percentage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.percentage == this.percentage);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> name;
  final Value<double?> percentage;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.percentage = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.percentage = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? percentage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (percentage != null) 'percentage': percentage,
    });
  }

  ProfilesCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<double?>? percentage}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('percentage: $percentage')
          ..write(')'))
        .toString();
  }
}

class $TodoListsTable extends TodoLists
    with TableInfo<$TodoListsTable, TodoList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _percentageMeta =
      const VerificationMeta('percentage');
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
      'percentage', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, percentage, archived, profileId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_lists';
  @override
  VerificationContext validateIntegrity(Insertable<TodoList> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('percentage')) {
      context.handle(
          _percentageMeta,
          percentage.isAcceptableOrUnknown(
              data['percentage']!, _percentageMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    } else if (isInserting) {
      context.missing(_archivedMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoList(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      percentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}percentage']),
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id']),
    );
  }

  @override
  $TodoListsTable createAlias(String alias) {
    return $TodoListsTable(attachedDatabase, alias);
  }
}

class TodoList extends DataClass implements Insertable<TodoList> {
  final int id;
  final String name;
  final double? percentage;
  final bool archived;
  final int? profileId;
  const TodoList(
      {required this.id,
      required this.name,
      this.percentage,
      required this.archived,
      this.profileId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || percentage != null) {
      map['percentage'] = Variable<double>(percentage);
    }
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    return map;
  }

  TodoListsCompanion toCompanion(bool nullToAbsent) {
    return TodoListsCompanion(
      id: Value(id),
      name: Value(name),
      percentage: percentage == null && nullToAbsent
          ? const Value.absent()
          : Value(percentage),
      archived: Value(archived),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
    );
  }

  factory TodoList.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      percentage: serializer.fromJson<double?>(json['percentage']),
      archived: serializer.fromJson<bool>(json['archived']),
      profileId: serializer.fromJson<int?>(json['profileId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'percentage': serializer.toJson<double?>(percentage),
      'archived': serializer.toJson<bool>(archived),
      'profileId': serializer.toJson<int?>(profileId),
    };
  }

  TodoList copyWith(
          {int? id,
          String? name,
          Value<double?> percentage = const Value.absent(),
          bool? archived,
          Value<int?> profileId = const Value.absent()}) =>
      TodoList(
        id: id ?? this.id,
        name: name ?? this.name,
        percentage: percentage.present ? percentage.value : this.percentage,
        archived: archived ?? this.archived,
        profileId: profileId.present ? profileId.value : this.profileId,
      );
  @override
  String toString() {
    return (StringBuffer('TodoList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('percentage: $percentage, ')
          ..write('archived: $archived, ')
          ..write('profileId: $profileId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, percentage, archived, profileId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoList &&
          other.id == this.id &&
          other.name == this.name &&
          other.percentage == this.percentage &&
          other.archived == this.archived &&
          other.profileId == this.profileId);
}

class TodoListsCompanion extends UpdateCompanion<TodoList> {
  final Value<int> id;
  final Value<String> name;
  final Value<double?> percentage;
  final Value<bool> archived;
  final Value<int?> profileId;
  const TodoListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.percentage = const Value.absent(),
    this.archived = const Value.absent(),
    this.profileId = const Value.absent(),
  });
  TodoListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.percentage = const Value.absent(),
    required bool archived,
    this.profileId = const Value.absent(),
  })  : name = Value(name),
        archived = Value(archived);
  static Insertable<TodoList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? percentage,
    Expression<bool>? archived,
    Expression<int>? profileId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (percentage != null) 'percentage': percentage,
      if (archived != null) 'archived': archived,
      if (profileId != null) 'profile_id': profileId,
    });
  }

  TodoListsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double?>? percentage,
      Value<bool>? archived,
      Value<int?>? profileId}) {
    return TodoListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      archived: archived ?? this.archived,
      profileId: profileId ?? this.profileId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('percentage: $percentage, ')
          ..write('archived: $archived, ')
          ..write('profileId: $profileId')
          ..write(')'))
        .toString();
  }
}

class $TodoItemsTable extends TodoItems
    with TableInfo<$TodoItemsTable, TodoItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
      'done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'));
  static const VerificationMeta _todoListIdMeta =
      const VerificationMeta('todoListId');
  @override
  late final GeneratedColumn<int> todoListId = GeneratedColumn<int>(
      'todo_list_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES todo_lists (id)'));
  static const VerificationMeta _creationTimeMeta =
      const VerificationMeta('creationTime');
  @override
  late final GeneratedColumn<DateTime> creationTime = GeneratedColumn<DateTime>(
      'creation_time', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, done, todoListId, creationTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_items';
  @override
  VerificationContext validateIntegrity(Insertable<TodoItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
          _doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    } else if (isInserting) {
      context.missing(_doneMeta);
    }
    if (data.containsKey('todo_list_id')) {
      context.handle(
          _todoListIdMeta,
          todoListId.isAcceptableOrUnknown(
              data['todo_list_id']!, _todoListIdMeta));
    } else if (isInserting) {
      context.missing(_todoListIdMeta);
    }
    if (data.containsKey('creation_time')) {
      context.handle(
          _creationTimeMeta,
          creationTime.isAcceptableOrUnknown(
              data['creation_time']!, _creationTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      done: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
      todoListId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}todo_list_id'])!,
      creationTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_time'])!,
    );
  }

  @override
  $TodoItemsTable createAlias(String alias) {
    return $TodoItemsTable(attachedDatabase, alias);
  }
}

class TodoItem extends DataClass implements Insertable<TodoItem> {
  final int id;
  final String title;
  final bool done;
  final int todoListId;
  final DateTime creationTime;
  const TodoItem(
      {required this.id,
      required this.title,
      required this.done,
      required this.todoListId,
      required this.creationTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['done'] = Variable<bool>(done);
    map['todo_list_id'] = Variable<int>(todoListId);
    map['creation_time'] = Variable<DateTime>(creationTime);
    return map;
  }

  TodoItemsCompanion toCompanion(bool nullToAbsent) {
    return TodoItemsCompanion(
      id: Value(id),
      title: Value(title),
      done: Value(done),
      todoListId: Value(todoListId),
      creationTime: Value(creationTime),
    );
  }

  factory TodoItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoItem(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      done: serializer.fromJson<bool>(json['done']),
      todoListId: serializer.fromJson<int>(json['todoListId']),
      creationTime: serializer.fromJson<DateTime>(json['creationTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'done': serializer.toJson<bool>(done),
      'todoListId': serializer.toJson<int>(todoListId),
      'creationTime': serializer.toJson<DateTime>(creationTime),
    };
  }

  TodoItem copyWith(
          {int? id,
          String? title,
          bool? done,
          int? todoListId,
          DateTime? creationTime}) =>
      TodoItem(
        id: id ?? this.id,
        title: title ?? this.title,
        done: done ?? this.done,
        todoListId: todoListId ?? this.todoListId,
        creationTime: creationTime ?? this.creationTime,
      );
  @override
  String toString() {
    return (StringBuffer('TodoItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('todoListId: $todoListId, ')
          ..write('creationTime: $creationTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, done, todoListId, creationTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.done == this.done &&
          other.todoListId == this.todoListId &&
          other.creationTime == this.creationTime);
}

class TodoItemsCompanion extends UpdateCompanion<TodoItem> {
  final Value<int> id;
  final Value<String> title;
  final Value<bool> done;
  final Value<int> todoListId;
  final Value<DateTime> creationTime;
  const TodoItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.done = const Value.absent(),
    this.todoListId = const Value.absent(),
    this.creationTime = const Value.absent(),
  });
  TodoItemsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required bool done,
    required int todoListId,
    this.creationTime = const Value.absent(),
  })  : title = Value(title),
        done = Value(done),
        todoListId = Value(todoListId);
  static Insertable<TodoItem> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<bool>? done,
    Expression<int>? todoListId,
    Expression<DateTime>? creationTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (done != null) 'done': done,
      if (todoListId != null) 'todo_list_id': todoListId,
      if (creationTime != null) 'creation_time': creationTime,
    });
  }

  TodoItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<bool>? done,
      Value<int>? todoListId,
      Value<DateTime>? creationTime}) {
    return TodoItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      todoListId: todoListId ?? this.todoListId,
      creationTime: creationTime ?? this.creationTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (todoListId.present) {
      map['todo_list_id'] = Variable<int>(todoListId.value);
    }
    if (creationTime.present) {
      map['creation_time'] = Variable<DateTime>(creationTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('todoListId: $todoListId, ')
          ..write('creationTime: $creationTime')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $TodoListsTable todoLists = $TodoListsTable(this);
  late final $TodoItemsTable todoItems = $TodoItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [profiles, todoLists, todoItems];
}
