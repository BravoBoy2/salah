// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SalahTimeTablesTable extends SalahTimeTables
    with TableInfo<$SalahTimeTablesTable, SalahTimeTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;

  $SalahTimeTablesTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _salahNameMeta = const VerificationMeta(
    'salahName',
  );
  @override
  late final GeneratedColumn<String> salahName = GeneratedColumn<String>(
    'salah_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeStringMeta = const VerificationMeta(
    'timeString',
  );
  @override
  late final GeneratedColumn<String> timeString = GeneratedColumn<String>(
    'time_string',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  @override
  List<GeneratedColumn> get $columns => [id, salahName, date, timeString];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  String get actualTableName => $name;
  static const String $name = 'salah_time_tables';

  @override
  VerificationContext validateIntegrity(
    Insertable<SalahTimeTable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('salah_name')) {
      context.handle(
        _salahNameMeta,
        salahName.isAcceptableOrUnknown(data['salah_name']!, _salahNameMeta),
      );
    } else if (isInserting) {
      context.missing(_salahNameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time_string')) {
      context.handle(
        _timeStringMeta,
        timeString.isAcceptableOrUnknown(data['time_string']!, _timeStringMeta),
      );
    } else if (isInserting) {
      context.missing(_timeStringMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  SalahTimeTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalahTimeTable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      salahName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salah_name'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      timeString: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_string'],
      )!,
    );
  }

  @override
  $SalahTimeTablesTable createAlias(String alias) {
    return $SalahTimeTablesTable(attachedDatabase, alias);
  }
}

class SalahTimeTable extends DataClass implements Insertable<SalahTimeTable> {
  final int id;
  final String salahName;
  final DateTime date;
  final String timeString;

  const SalahTimeTable({
    required this.id,
    required this.salahName,
    required this.date,
    required this.timeString,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['salah_name'] = Variable<String>(salahName);
    map['date'] = Variable<DateTime>(date);
    map['time_string'] = Variable<String>(timeString);
    return map;
  }

  SalahTimeTablesCompanion toCompanion(bool nullToAbsent) {
    return SalahTimeTablesCompanion(
      id: Value(id),
      salahName: Value(salahName),
      date: Value(date),
      timeString: Value(timeString),
    );
  }

  factory SalahTimeTable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalahTimeTable(
      id: serializer.fromJson<int>(json['id']),
      salahName: serializer.fromJson<String>(json['salahName']),
      date: serializer.fromJson<DateTime>(json['date']),
      timeString: serializer.fromJson<String>(json['timeString']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'salahName': serializer.toJson<String>(salahName),
      'date': serializer.toJson<DateTime>(date),
      'timeString': serializer.toJson<String>(timeString),
    };
  }

  SalahTimeTable copyWith({
    int? id,
    String? salahName,
    DateTime? date,
    String? timeString,
  }) => SalahTimeTable(
    id: id ?? this.id,
    salahName: salahName ?? this.salahName,
    date: date ?? this.date,
    timeString: timeString ?? this.timeString,
  );

  SalahTimeTable copyWithCompanion(SalahTimeTablesCompanion data) {
    return SalahTimeTable(
      id: data.id.present ? data.id.value : this.id,
      salahName: data.salahName.present ? data.salahName.value : this.salahName,
      date: data.date.present ? data.date.value : this.date,
      timeString: data.timeString.present
          ? data.timeString.value
          : this.timeString,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalahTimeTable(')
          ..write('id: $id, ')
          ..write('salahName: $salahName, ')
          ..write('date: $date, ')
          ..write('timeString: $timeString')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, salahName, date, timeString);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalahTimeTable &&
          other.id == this.id &&
          other.salahName == this.salahName &&
          other.date == this.date &&
          other.timeString == this.timeString);
}

class SalahTimeTablesCompanion extends UpdateCompanion<SalahTimeTable> {
  final Value<int> id;
  final Value<String> salahName;
  final Value<DateTime> date;
  final Value<String> timeString;

  const SalahTimeTablesCompanion({
    this.id = const Value.absent(),
    this.salahName = const Value.absent(),
    this.date = const Value.absent(),
    this.timeString = const Value.absent(),
  });

  SalahTimeTablesCompanion.insert({
    this.id = const Value.absent(),
    required String salahName,
    required DateTime date,
    required String timeString,
  }) : salahName = Value(salahName),
       date = Value(date),
       timeString = Value(timeString);

  static Insertable<SalahTimeTable> custom({
    Expression<int>? id,
    Expression<String>? salahName,
    Expression<DateTime>? date,
    Expression<String>? timeString,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (salahName != null) 'salah_name': salahName,
      if (date != null) 'date': date,
      if (timeString != null) 'time_string': timeString,
    });
  }

  SalahTimeTablesCompanion copyWith({
    Value<int>? id,
    Value<String>? salahName,
    Value<DateTime>? date,
    Value<String>? timeString,
  }) {
    return SalahTimeTablesCompanion(
      id: id ?? this.id,
      salahName: salahName ?? this.salahName,
      date: date ?? this.date,
      timeString: timeString ?? this.timeString,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (salahName.present) {
      map['salah_name'] = Variable<String>(salahName.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (timeString.present) {
      map['time_string'] = Variable<String>(timeString.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalahTimeTablesCompanion(')
          ..write('id: $id, ')
          ..write('salahName: $salahName, ')
          ..write('date: $date, ')
          ..write('timeString: $timeString')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);

  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SalahTimeTablesTable salahTimeTables = $SalahTimeTablesTable(
    this,
  );

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [salahTimeTables];
}

typedef $$SalahTimeTablesTableCreateCompanionBuilder =
    SalahTimeTablesCompanion Function({
      Value<int> id,
      required String salahName,
      required DateTime date,
      required String timeString,
    });
typedef $$SalahTimeTablesTableUpdateCompanionBuilder =
    SalahTimeTablesCompanion Function({
      Value<int> id,
      Value<String> salahName,
      Value<DateTime> date,
      Value<String> timeString,
    });

class $$SalahTimeTablesTableFilterComposer
    extends Composer<_$AppDatabase, $SalahTimeTablesTable> {
  $$SalahTimeTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salahName => $composableBuilder(
    column: $table.salahName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeString => $composableBuilder(
    column: $table.timeString,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalahTimeTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalahTimeTablesTable> {
  $$SalahTimeTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salahName => $composableBuilder(
    column: $table.salahName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeString => $composableBuilder(
    column: $table.timeString,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalahTimeTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalahTimeTablesTable> {
  $$SalahTimeTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get salahName =>
      $composableBuilder(column: $table.salahName, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get timeString => $composableBuilder(
    column: $table.timeString,
    builder: (column) => column,
  );
}

class $$SalahTimeTablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalahTimeTablesTable,
          SalahTimeTable,
          $$SalahTimeTablesTableFilterComposer,
          $$SalahTimeTablesTableOrderingComposer,
          $$SalahTimeTablesTableAnnotationComposer,
          $$SalahTimeTablesTableCreateCompanionBuilder,
          $$SalahTimeTablesTableUpdateCompanionBuilder,
          (
            SalahTimeTable,
            BaseReferences<
              _$AppDatabase,
              $SalahTimeTablesTable,
              SalahTimeTable
            >,
          ),
          SalahTimeTable,
          PrefetchHooks Function()
        > {
  $$SalahTimeTablesTableTableManager(
    _$AppDatabase db,
    $SalahTimeTablesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalahTimeTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalahTimeTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalahTimeTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> salahName = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> timeString = const Value.absent(),
              }) => SalahTimeTablesCompanion(
                id: id,
                salahName: salahName,
                date: date,
                timeString: timeString,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String salahName,
                required DateTime date,
                required String timeString,
              }) => SalahTimeTablesCompanion.insert(
                id: id,
                salahName: salahName,
                date: date,
                timeString: timeString,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalahTimeTablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalahTimeTablesTable,
      SalahTimeTable,
      $$SalahTimeTablesTableFilterComposer,
      $$SalahTimeTablesTableOrderingComposer,
      $$SalahTimeTablesTableAnnotationComposer,
      $$SalahTimeTablesTableCreateCompanionBuilder,
      $$SalahTimeTablesTableUpdateCompanionBuilder,
      (
        SalahTimeTable,
        BaseReferences<_$AppDatabase, $SalahTimeTablesTable, SalahTimeTable>,
      ),
      SalahTimeTable,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;

  $AppDatabaseManager(this._db);

  $$SalahTimeTablesTableTableManager get salahTimeTables =>
      $$SalahTimeTablesTableTableManager(_db, _db.salahTimeTables);
}
