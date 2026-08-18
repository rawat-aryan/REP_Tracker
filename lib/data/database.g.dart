// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, ExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> aliases =
      GeneratedColumn<String>('aliases', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($ExercisesTable.$converteraliases);
  @override
  late final GeneratedColumnWithTypeConverter<Muscle, String> primaryMuscle =
      GeneratedColumn<String>('primary_muscle', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Muscle>($ExercisesTable.$converterprimaryMuscle);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
      secondaryMuscles = GeneratedColumn<String>(
              'secondary_muscles', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>(
              $ExercisesTable.$convertersecondaryMuscles);
  @override
  late final GeneratedColumnWithTypeConverter<Equipment, String> equipment =
      GeneratedColumn<String>('equipment', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Equipment>($ExercisesTable.$converterequipment);
  @override
  late final GeneratedColumnWithTypeConverter<Execution, String>
      defaultExecution = GeneratedColumn<String>(
              'default_execution', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('bilateral'))
          .withConverter<Execution>($ExercisesTable.$converterdefaultExecution);
  static const VerificationMeta _variantOfMeta =
      const VerificationMeta('variantOf');
  @override
  late final GeneratedColumn<String> variantOf = GeneratedColumn<String>(
      'variant_of', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _incrementOverrideMeta =
      const VerificationMeta('incrementOverride');
  @override
  late final GeneratedColumn<double> incrementOverride =
      GeneratedColumn<double>('increment_override', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _equipmentIncrementMeta =
      const VerificationMeta('equipmentIncrement');
  @override
  late final GeneratedColumn<double> equipmentIncrement =
      GeneratedColumn<double>('equipment_increment', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(2.5));
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        isCustom,
        name,
        aliases,
        primaryMuscle,
        secondaryMuscles,
        equipment,
        defaultExecution,
        variantOf,
        incrementOverride,
        equipmentIncrement,
        archived
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('variant_of')) {
      context.handle(_variantOfMeta,
          variantOf.isAcceptableOrUnknown(data['variant_of']!, _variantOfMeta));
    }
    if (data.containsKey('increment_override')) {
      context.handle(
          _incrementOverrideMeta,
          incrementOverride.isAcceptableOrUnknown(
              data['increment_override']!, _incrementOverrideMeta));
    }
    if (data.containsKey('equipment_increment')) {
      context.handle(
          _equipmentIncrementMeta,
          equipmentIncrement.isAcceptableOrUnknown(
              data['equipment_increment']!, _equipmentIncrementMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      aliases: $ExercisesTable.$converteraliases.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aliases'])!),
      primaryMuscle: $ExercisesTable.$converterprimaryMuscle.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}primary_muscle'])!),
      secondaryMuscles: $ExercisesTable.$convertersecondaryMuscles.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}secondary_muscles'])!),
      equipment: $ExercisesTable.$converterequipment.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}equipment'])!),
      defaultExecution: $ExercisesTable.$converterdefaultExecution.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}default_execution'])!),
      variantOf: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_of']),
      incrementOverride: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}increment_override']),
      equipmentIncrement: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}equipment_increment'])!,
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converteraliases =
      const StringListConverter();
  static JsonTypeConverter2<Muscle, String, String> $converterprimaryMuscle =
      const EnumNameConverter<Muscle>(Muscle.values);
  static TypeConverter<List<String>, String> $convertersecondaryMuscles =
      const StringListConverter();
  static JsonTypeConverter2<Equipment, String, String> $converterequipment =
      const EnumNameConverter<Equipment>(Equipment.values);
  static JsonTypeConverter2<Execution, String, String>
      $converterdefaultExecution =
      const EnumNameConverter<Execution>(Execution.values);
}

class ExerciseRow extends DataClass implements Insertable<ExerciseRow> {
  final String id;
  final bool isCustom;
  final String name;
  final List<String> aliases;
  final Muscle primaryMuscle;
  final List<String> secondaryMuscles;
  final Equipment equipment;
  final Execution defaultExecution;

  /// Points at another [Exercises.id]. Powers the compare overlay only —
  /// never a merge, never read by analytics.
  final String? variantOf;
  final double? incrementOverride;
  final double equipmentIncrement;

  /// I7: archived, never deleted. History must never dangle.
  final bool archived;
  const ExerciseRow(
      {required this.id,
      required this.isCustom,
      required this.name,
      required this.aliases,
      required this.primaryMuscle,
      required this.secondaryMuscles,
      required this.equipment,
      required this.defaultExecution,
      this.variantOf,
      this.incrementOverride,
      required this.equipmentIncrement,
      required this.archived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['is_custom'] = Variable<bool>(isCustom);
    map['name'] = Variable<String>(name);
    {
      map['aliases'] =
          Variable<String>($ExercisesTable.$converteraliases.toSql(aliases));
    }
    {
      map['primary_muscle'] = Variable<String>(
          $ExercisesTable.$converterprimaryMuscle.toSql(primaryMuscle));
    }
    {
      map['secondary_muscles'] = Variable<String>(
          $ExercisesTable.$convertersecondaryMuscles.toSql(secondaryMuscles));
    }
    {
      map['equipment'] = Variable<String>(
          $ExercisesTable.$converterequipment.toSql(equipment));
    }
    {
      map['default_execution'] = Variable<String>(
          $ExercisesTable.$converterdefaultExecution.toSql(defaultExecution));
    }
    if (!nullToAbsent || variantOf != null) {
      map['variant_of'] = Variable<String>(variantOf);
    }
    if (!nullToAbsent || incrementOverride != null) {
      map['increment_override'] = Variable<double>(incrementOverride);
    }
    map['equipment_increment'] = Variable<double>(equipmentIncrement);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      isCustom: Value(isCustom),
      name: Value(name),
      aliases: Value(aliases),
      primaryMuscle: Value(primaryMuscle),
      secondaryMuscles: Value(secondaryMuscles),
      equipment: Value(equipment),
      defaultExecution: Value(defaultExecution),
      variantOf: variantOf == null && nullToAbsent
          ? const Value.absent()
          : Value(variantOf),
      incrementOverride: incrementOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(incrementOverride),
      equipmentIncrement: Value(equipmentIncrement),
      archived: Value(archived),
    );
  }

  factory ExerciseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      name: serializer.fromJson<String>(json['name']),
      aliases: serializer.fromJson<List<String>>(json['aliases']),
      primaryMuscle: $ExercisesTable.$converterprimaryMuscle
          .fromJson(serializer.fromJson<String>(json['primaryMuscle'])),
      secondaryMuscles:
          serializer.fromJson<List<String>>(json['secondaryMuscles']),
      equipment: $ExercisesTable.$converterequipment
          .fromJson(serializer.fromJson<String>(json['equipment'])),
      defaultExecution: $ExercisesTable.$converterdefaultExecution
          .fromJson(serializer.fromJson<String>(json['defaultExecution'])),
      variantOf: serializer.fromJson<String?>(json['variantOf']),
      incrementOverride:
          serializer.fromJson<double?>(json['incrementOverride']),
      equipmentIncrement:
          serializer.fromJson<double>(json['equipmentIncrement']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'isCustom': serializer.toJson<bool>(isCustom),
      'name': serializer.toJson<String>(name),
      'aliases': serializer.toJson<List<String>>(aliases),
      'primaryMuscle': serializer.toJson<String>(
          $ExercisesTable.$converterprimaryMuscle.toJson(primaryMuscle)),
      'secondaryMuscles': serializer.toJson<List<String>>(secondaryMuscles),
      'equipment': serializer.toJson<String>(
          $ExercisesTable.$converterequipment.toJson(equipment)),
      'defaultExecution': serializer.toJson<String>(
          $ExercisesTable.$converterdefaultExecution.toJson(defaultExecution)),
      'variantOf': serializer.toJson<String?>(variantOf),
      'incrementOverride': serializer.toJson<double?>(incrementOverride),
      'equipmentIncrement': serializer.toJson<double>(equipmentIncrement),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  ExerciseRow copyWith(
          {String? id,
          bool? isCustom,
          String? name,
          List<String>? aliases,
          Muscle? primaryMuscle,
          List<String>? secondaryMuscles,
          Equipment? equipment,
          Execution? defaultExecution,
          Value<String?> variantOf = const Value.absent(),
          Value<double?> incrementOverride = const Value.absent(),
          double? equipmentIncrement,
          bool? archived}) =>
      ExerciseRow(
        id: id ?? this.id,
        isCustom: isCustom ?? this.isCustom,
        name: name ?? this.name,
        aliases: aliases ?? this.aliases,
        primaryMuscle: primaryMuscle ?? this.primaryMuscle,
        secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
        equipment: equipment ?? this.equipment,
        defaultExecution: defaultExecution ?? this.defaultExecution,
        variantOf: variantOf.present ? variantOf.value : this.variantOf,
        incrementOverride: incrementOverride.present
            ? incrementOverride.value
            : this.incrementOverride,
        equipmentIncrement: equipmentIncrement ?? this.equipmentIncrement,
        archived: archived ?? this.archived,
      );
  ExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return ExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      name: data.name.present ? data.name.value : this.name,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      primaryMuscle: data.primaryMuscle.present
          ? data.primaryMuscle.value
          : this.primaryMuscle,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      defaultExecution: data.defaultExecution.present
          ? data.defaultExecution.value
          : this.defaultExecution,
      variantOf: data.variantOf.present ? data.variantOf.value : this.variantOf,
      incrementOverride: data.incrementOverride.present
          ? data.incrementOverride.value
          : this.incrementOverride,
      equipmentIncrement: data.equipmentIncrement.present
          ? data.equipmentIncrement.value
          : this.equipmentIncrement,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRow(')
          ..write('id: $id, ')
          ..write('isCustom: $isCustom, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('equipment: $equipment, ')
          ..write('defaultExecution: $defaultExecution, ')
          ..write('variantOf: $variantOf, ')
          ..write('incrementOverride: $incrementOverride, ')
          ..write('equipmentIncrement: $equipmentIncrement, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      isCustom,
      name,
      aliases,
      primaryMuscle,
      secondaryMuscles,
      equipment,
      defaultExecution,
      variantOf,
      incrementOverride,
      equipmentIncrement,
      archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRow &&
          other.id == this.id &&
          other.isCustom == this.isCustom &&
          other.name == this.name &&
          other.aliases == this.aliases &&
          other.primaryMuscle == this.primaryMuscle &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.equipment == this.equipment &&
          other.defaultExecution == this.defaultExecution &&
          other.variantOf == this.variantOf &&
          other.incrementOverride == this.incrementOverride &&
          other.equipmentIncrement == this.equipmentIncrement &&
          other.archived == this.archived);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseRow> {
  final Value<String> id;
  final Value<bool> isCustom;
  final Value<String> name;
  final Value<List<String>> aliases;
  final Value<Muscle> primaryMuscle;
  final Value<List<String>> secondaryMuscles;
  final Value<Equipment> equipment;
  final Value<Execution> defaultExecution;
  final Value<String?> variantOf;
  final Value<double?> incrementOverride;
  final Value<double> equipmentIncrement;
  final Value<bool> archived;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.name = const Value.absent(),
    this.aliases = const Value.absent(),
    this.primaryMuscle = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.equipment = const Value.absent(),
    this.defaultExecution = const Value.absent(),
    this.variantOf = const Value.absent(),
    this.incrementOverride = const Value.absent(),
    this.equipmentIncrement = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    this.isCustom = const Value.absent(),
    required String name,
    this.aliases = const Value.absent(),
    required Muscle primaryMuscle,
    this.secondaryMuscles = const Value.absent(),
    required Equipment equipment,
    this.defaultExecution = const Value.absent(),
    this.variantOf = const Value.absent(),
    this.incrementOverride = const Value.absent(),
    this.equipmentIncrement = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        primaryMuscle = Value(primaryMuscle),
        equipment = Value(equipment);
  static Insertable<ExerciseRow> custom({
    Expression<String>? id,
    Expression<bool>? isCustom,
    Expression<String>? name,
    Expression<String>? aliases,
    Expression<String>? primaryMuscle,
    Expression<String>? secondaryMuscles,
    Expression<String>? equipment,
    Expression<String>? defaultExecution,
    Expression<String>? variantOf,
    Expression<double>? incrementOverride,
    Expression<double>? equipmentIncrement,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isCustom != null) 'is_custom': isCustom,
      if (name != null) 'name': name,
      if (aliases != null) 'aliases': aliases,
      if (primaryMuscle != null) 'primary_muscle': primaryMuscle,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (equipment != null) 'equipment': equipment,
      if (defaultExecution != null) 'default_execution': defaultExecution,
      if (variantOf != null) 'variant_of': variantOf,
      if (incrementOverride != null) 'increment_override': incrementOverride,
      if (equipmentIncrement != null) 'equipment_increment': equipmentIncrement,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith(
      {Value<String>? id,
      Value<bool>? isCustom,
      Value<String>? name,
      Value<List<String>>? aliases,
      Value<Muscle>? primaryMuscle,
      Value<List<String>>? secondaryMuscles,
      Value<Equipment>? equipment,
      Value<Execution>? defaultExecution,
      Value<String?>? variantOf,
      Value<double?>? incrementOverride,
      Value<double>? equipmentIncrement,
      Value<bool>? archived,
      Value<int>? rowid}) {
    return ExercisesCompanion(
      id: id ?? this.id,
      isCustom: isCustom ?? this.isCustom,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      defaultExecution: defaultExecution ?? this.defaultExecution,
      variantOf: variantOf ?? this.variantOf,
      incrementOverride: incrementOverride ?? this.incrementOverride,
      equipmentIncrement: equipmentIncrement ?? this.equipmentIncrement,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(
          $ExercisesTable.$converteraliases.toSql(aliases.value));
    }
    if (primaryMuscle.present) {
      map['primary_muscle'] = Variable<String>(
          $ExercisesTable.$converterprimaryMuscle.toSql(primaryMuscle.value));
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>($ExercisesTable
          .$convertersecondaryMuscles
          .toSql(secondaryMuscles.value));
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
          $ExercisesTable.$converterequipment.toSql(equipment.value));
    }
    if (defaultExecution.present) {
      map['default_execution'] = Variable<String>($ExercisesTable
          .$converterdefaultExecution
          .toSql(defaultExecution.value));
    }
    if (variantOf.present) {
      map['variant_of'] = Variable<String>(variantOf.value);
    }
    if (incrementOverride.present) {
      map['increment_override'] = Variable<double>(incrementOverride.value);
    }
    if (equipmentIncrement.present) {
      map['equipment_increment'] = Variable<double>(equipmentIncrement.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('isCustom: $isCustom, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('equipment: $equipment, ')
          ..write('defaultExecution: $defaultExecution, ')
          ..write('variantOf: $variantOf, ')
          ..write('incrementOverride: $incrementOverride, ')
          ..write('equipmentIncrement: $equipmentIncrement, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutDaysTable extends WorkoutDays
    with TableInfo<$WorkoutDaysTable, WorkoutDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, name, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_days';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutDayRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutDayRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $WorkoutDaysTable createAlias(String alias) {
    return $WorkoutDaysTable(attachedDatabase, alias);
  }
}

class WorkoutDayRow extends DataClass implements Insertable<WorkoutDayRow> {
  final String id;
  final String name;
  final bool archived;
  const WorkoutDayRow(
      {required this.id, required this.name, required this.archived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  WorkoutDaysCompanion toCompanion(bool nullToAbsent) {
    return WorkoutDaysCompanion(
      id: Value(id),
      name: Value(name),
      archived: Value(archived),
    );
  }

  factory WorkoutDayRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutDayRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  WorkoutDayRow copyWith({String? id, String? name, bool? archived}) =>
      WorkoutDayRow(
        id: id ?? this.id,
        name: name ?? this.name,
        archived: archived ?? this.archived,
      );
  WorkoutDayRow copyWithCompanion(WorkoutDaysCompanion data) {
    return WorkoutDayRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutDayRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutDayRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.archived == this.archived);
}

class WorkoutDaysCompanion extends UpdateCompanion<WorkoutDayRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> archived;
  final Value<int> rowid;
  const WorkoutDaysCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutDaysCompanion.insert({
    required String id,
    required String name,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<WorkoutDayRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutDaysCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<bool>? archived,
      Value<int>? rowid}) {
    return WorkoutDaysCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutDaysCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedExercisesTable extends PlannedExercises
    with TableInfo<$PlannedExercisesTable, PlannedExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workoutDayIdMeta =
      const VerificationMeta('workoutDayId');
  @override
  late final GeneratedColumn<String> workoutDayId = GeneratedColumn<String>(
      'workout_day_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workout_days (id)'));
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES exercises (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _targetSetsMeta =
      const VerificationMeta('targetSets');
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
      'target_sets', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _defaultUnilateralMeta =
      const VerificationMeta('defaultUnilateral');
  @override
  late final GeneratedColumn<bool> defaultUnilateral = GeneratedColumn<bool>(
      'default_unilateral', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("default_unilateral" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, workoutDayId, exerciseId, sortOrder, targetSets, defaultUnilateral];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<PlannedExerciseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_day_id')) {
      context.handle(
          _workoutDayIdMeta,
          workoutDayId.isAcceptableOrUnknown(
              data['workout_day_id']!, _workoutDayIdMeta));
    } else if (isInserting) {
      context.missing(_workoutDayIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(
          _targetSetsMeta,
          targetSets.isAcceptableOrUnknown(
              data['target_sets']!, _targetSetsMeta));
    }
    if (data.containsKey('default_unilateral')) {
      context.handle(
          _defaultUnilateralMeta,
          defaultUnilateral.isAcceptableOrUnknown(
              data['default_unilateral']!, _defaultUnilateralMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedExerciseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workoutDayId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workout_day_id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      targetSets: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_sets'])!,
      defaultUnilateral: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}default_unilateral'])!,
    );
  }

  @override
  $PlannedExercisesTable createAlias(String alias) {
    return $PlannedExercisesTable(attachedDatabase, alias);
  }
}

class PlannedExerciseRow extends DataClass
    implements Insertable<PlannedExerciseRow> {
  final int id;
  final String workoutDayId;
  final String exerciseId;
  final int sortOrder;
  final int targetSets;
  final bool defaultUnilateral;
  const PlannedExerciseRow(
      {required this.id,
      required this.workoutDayId,
      required this.exerciseId,
      required this.sortOrder,
      required this.targetSets,
      required this.defaultUnilateral});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_day_id'] = Variable<String>(workoutDayId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['target_sets'] = Variable<int>(targetSets);
    map['default_unilateral'] = Variable<bool>(defaultUnilateral);
    return map;
  }

  PlannedExercisesCompanion toCompanion(bool nullToAbsent) {
    return PlannedExercisesCompanion(
      id: Value(id),
      workoutDayId: Value(workoutDayId),
      exerciseId: Value(exerciseId),
      sortOrder: Value(sortOrder),
      targetSets: Value(targetSets),
      defaultUnilateral: Value(defaultUnilateral),
    );
  }

  factory PlannedExerciseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedExerciseRow(
      id: serializer.fromJson<int>(json['id']),
      workoutDayId: serializer.fromJson<String>(json['workoutDayId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      defaultUnilateral: serializer.fromJson<bool>(json['defaultUnilateral']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutDayId': serializer.toJson<String>(workoutDayId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'targetSets': serializer.toJson<int>(targetSets),
      'defaultUnilateral': serializer.toJson<bool>(defaultUnilateral),
    };
  }

  PlannedExerciseRow copyWith(
          {int? id,
          String? workoutDayId,
          String? exerciseId,
          int? sortOrder,
          int? targetSets,
          bool? defaultUnilateral}) =>
      PlannedExerciseRow(
        id: id ?? this.id,
        workoutDayId: workoutDayId ?? this.workoutDayId,
        exerciseId: exerciseId ?? this.exerciseId,
        sortOrder: sortOrder ?? this.sortOrder,
        targetSets: targetSets ?? this.targetSets,
        defaultUnilateral: defaultUnilateral ?? this.defaultUnilateral,
      );
  PlannedExerciseRow copyWithCompanion(PlannedExercisesCompanion data) {
    return PlannedExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      workoutDayId: data.workoutDayId.present
          ? data.workoutDayId.value
          : this.workoutDayId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      targetSets:
          data.targetSets.present ? data.targetSets.value : this.targetSets,
      defaultUnilateral: data.defaultUnilateral.present
          ? data.defaultUnilateral.value
          : this.defaultUnilateral,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedExerciseRow(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('targetSets: $targetSets, ')
          ..write('defaultUnilateral: $defaultUnilateral')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, workoutDayId, exerciseId, sortOrder, targetSets, defaultUnilateral);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedExerciseRow &&
          other.id == this.id &&
          other.workoutDayId == this.workoutDayId &&
          other.exerciseId == this.exerciseId &&
          other.sortOrder == this.sortOrder &&
          other.targetSets == this.targetSets &&
          other.defaultUnilateral == this.defaultUnilateral);
}

class PlannedExercisesCompanion extends UpdateCompanion<PlannedExerciseRow> {
  final Value<int> id;
  final Value<String> workoutDayId;
  final Value<String> exerciseId;
  final Value<int> sortOrder;
  final Value<int> targetSets;
  final Value<bool> defaultUnilateral;
  const PlannedExercisesCompanion({
    this.id = const Value.absent(),
    this.workoutDayId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.defaultUnilateral = const Value.absent(),
  });
  PlannedExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String workoutDayId,
    required String exerciseId,
    required int sortOrder,
    this.targetSets = const Value.absent(),
    this.defaultUnilateral = const Value.absent(),
  })  : workoutDayId = Value(workoutDayId),
        exerciseId = Value(exerciseId),
        sortOrder = Value(sortOrder);
  static Insertable<PlannedExerciseRow> custom({
    Expression<int>? id,
    Expression<String>? workoutDayId,
    Expression<String>? exerciseId,
    Expression<int>? sortOrder,
    Expression<int>? targetSets,
    Expression<bool>? defaultUnilateral,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutDayId != null) 'workout_day_id': workoutDayId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (targetSets != null) 'target_sets': targetSets,
      if (defaultUnilateral != null) 'default_unilateral': defaultUnilateral,
    });
  }

  PlannedExercisesCompanion copyWith(
      {Value<int>? id,
      Value<String>? workoutDayId,
      Value<String>? exerciseId,
      Value<int>? sortOrder,
      Value<int>? targetSets,
      Value<bool>? defaultUnilateral}) {
    return PlannedExercisesCompanion(
      id: id ?? this.id,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      exerciseId: exerciseId ?? this.exerciseId,
      sortOrder: sortOrder ?? this.sortOrder,
      targetSets: targetSets ?? this.targetSets,
      defaultUnilateral: defaultUnilateral ?? this.defaultUnilateral,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutDayId.present) {
      map['workout_day_id'] = Variable<String>(workoutDayId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (defaultUnilateral.present) {
      map['default_unilateral'] = Variable<bool>(defaultUnilateral.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedExercisesCompanion(')
          ..write('id: $id, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('targetSets: $targetSets, ')
          ..write('defaultUnilateral: $defaultUnilateral')
          ..write(')'))
        .toString();
  }
}

class $WeekPlansTable extends WeekPlans
    with TableInfo<$WeekPlansTable, WeekPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
      'routine_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [routineId, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_plans';
  @override
  VerificationContext validateIntegrity(Insertable<WeekPlanRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {routineId, version};
  @override
  WeekPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekPlanRow(
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routine_id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $WeekPlansTable createAlias(String alias) {
    return $WeekPlansTable(attachedDatabase, alias);
  }
}

class WeekPlanRow extends DataClass implements Insertable<WeekPlanRow> {
  final String routineId;
  final int version;
  const WeekPlanRow({required this.routineId, required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['routine_id'] = Variable<String>(routineId);
    map['version'] = Variable<int>(version);
    return map;
  }

  WeekPlansCompanion toCompanion(bool nullToAbsent) {
    return WeekPlansCompanion(
      routineId: Value(routineId),
      version: Value(version),
    );
  }

  factory WeekPlanRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekPlanRow(
      routineId: serializer.fromJson<String>(json['routineId']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'routineId': serializer.toJson<String>(routineId),
      'version': serializer.toJson<int>(version),
    };
  }

  WeekPlanRow copyWith({String? routineId, int? version}) => WeekPlanRow(
        routineId: routineId ?? this.routineId,
        version: version ?? this.version,
      );
  WeekPlanRow copyWithCompanion(WeekPlansCompanion data) {
    return WeekPlanRow(
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekPlanRow(')
          ..write('routineId: $routineId, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(routineId, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekPlanRow &&
          other.routineId == this.routineId &&
          other.version == this.version);
}

class WeekPlansCompanion extends UpdateCompanion<WeekPlanRow> {
  final Value<String> routineId;
  final Value<int> version;
  final Value<int> rowid;
  const WeekPlansCompanion({
    this.routineId = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekPlansCompanion.insert({
    required String routineId,
    required int version,
    this.rowid = const Value.absent(),
  })  : routineId = Value(routineId),
        version = Value(version);
  static Insertable<WeekPlanRow> custom({
    Expression<String>? routineId,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (routineId != null) 'routine_id': routineId,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekPlansCompanion copyWith(
      {Value<String>? routineId, Value<int>? version, Value<int>? rowid}) {
    return WeekPlansCompanion(
      routineId: routineId ?? this.routineId,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekPlansCompanion(')
          ..write('routineId: $routineId, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeekPlanSlotsTable extends WeekPlanSlots
    with TableInfo<$WeekPlanSlotsTable, WeekPlanSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekPlanSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
      'routine_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<Weekday, String> weekday =
      GeneratedColumn<String>('weekday', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Weekday>($WeekPlanSlotsTable.$converterweekday);
  static const VerificationMeta _workoutDayIdMeta =
      const VerificationMeta('workoutDayId');
  @override
  late final GeneratedColumn<String> workoutDayId = GeneratedColumn<String>(
      'workout_day_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [routineId, version, weekday, workoutDayId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_plan_slots';
  @override
  VerificationContext validateIntegrity(Insertable<WeekPlanSlot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('workout_day_id')) {
      context.handle(
          _workoutDayIdMeta,
          workoutDayId.isAcceptableOrUnknown(
              data['workout_day_id']!, _workoutDayIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {routineId, version, weekday};
  @override
  WeekPlanSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekPlanSlot(
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routine_id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      weekday: $WeekPlanSlotsTable.$converterweekday.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weekday'])!),
      workoutDayId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workout_day_id']),
    );
  }

  @override
  $WeekPlanSlotsTable createAlias(String alias) {
    return $WeekPlanSlotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Weekday, String, String> $converterweekday =
      const EnumNameConverter<Weekday>(Weekday.values);
}

class WeekPlanSlot extends DataClass implements Insertable<WeekPlanSlot> {
  final String routineId;
  final int version;
  final Weekday weekday;

  /// Null = rest day.
  final String? workoutDayId;
  const WeekPlanSlot(
      {required this.routineId,
      required this.version,
      required this.weekday,
      this.workoutDayId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['routine_id'] = Variable<String>(routineId);
    map['version'] = Variable<int>(version);
    {
      map['weekday'] = Variable<String>(
          $WeekPlanSlotsTable.$converterweekday.toSql(weekday));
    }
    if (!nullToAbsent || workoutDayId != null) {
      map['workout_day_id'] = Variable<String>(workoutDayId);
    }
    return map;
  }

  WeekPlanSlotsCompanion toCompanion(bool nullToAbsent) {
    return WeekPlanSlotsCompanion(
      routineId: Value(routineId),
      version: Value(version),
      weekday: Value(weekday),
      workoutDayId: workoutDayId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutDayId),
    );
  }

  factory WeekPlanSlot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekPlanSlot(
      routineId: serializer.fromJson<String>(json['routineId']),
      version: serializer.fromJson<int>(json['version']),
      weekday: $WeekPlanSlotsTable.$converterweekday
          .fromJson(serializer.fromJson<String>(json['weekday'])),
      workoutDayId: serializer.fromJson<String?>(json['workoutDayId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'routineId': serializer.toJson<String>(routineId),
      'version': serializer.toJson<int>(version),
      'weekday': serializer.toJson<String>(
          $WeekPlanSlotsTable.$converterweekday.toJson(weekday)),
      'workoutDayId': serializer.toJson<String?>(workoutDayId),
    };
  }

  WeekPlanSlot copyWith(
          {String? routineId,
          int? version,
          Weekday? weekday,
          Value<String?> workoutDayId = const Value.absent()}) =>
      WeekPlanSlot(
        routineId: routineId ?? this.routineId,
        version: version ?? this.version,
        weekday: weekday ?? this.weekday,
        workoutDayId:
            workoutDayId.present ? workoutDayId.value : this.workoutDayId,
      );
  WeekPlanSlot copyWithCompanion(WeekPlanSlotsCompanion data) {
    return WeekPlanSlot(
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      version: data.version.present ? data.version.value : this.version,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      workoutDayId: data.workoutDayId.present
          ? data.workoutDayId.value
          : this.workoutDayId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekPlanSlot(')
          ..write('routineId: $routineId, ')
          ..write('version: $version, ')
          ..write('weekday: $weekday, ')
          ..write('workoutDayId: $workoutDayId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(routineId, version, weekday, workoutDayId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekPlanSlot &&
          other.routineId == this.routineId &&
          other.version == this.version &&
          other.weekday == this.weekday &&
          other.workoutDayId == this.workoutDayId);
}

class WeekPlanSlotsCompanion extends UpdateCompanion<WeekPlanSlot> {
  final Value<String> routineId;
  final Value<int> version;
  final Value<Weekday> weekday;
  final Value<String?> workoutDayId;
  final Value<int> rowid;
  const WeekPlanSlotsCompanion({
    this.routineId = const Value.absent(),
    this.version = const Value.absent(),
    this.weekday = const Value.absent(),
    this.workoutDayId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekPlanSlotsCompanion.insert({
    required String routineId,
    required int version,
    required Weekday weekday,
    this.workoutDayId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : routineId = Value(routineId),
        version = Value(version),
        weekday = Value(weekday);
  static Insertable<WeekPlanSlot> custom({
    Expression<String>? routineId,
    Expression<int>? version,
    Expression<String>? weekday,
    Expression<String>? workoutDayId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (routineId != null) 'routine_id': routineId,
      if (version != null) 'version': version,
      if (weekday != null) 'weekday': weekday,
      if (workoutDayId != null) 'workout_day_id': workoutDayId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekPlanSlotsCompanion copyWith(
      {Value<String>? routineId,
      Value<int>? version,
      Value<Weekday>? weekday,
      Value<String?>? workoutDayId,
      Value<int>? rowid}) {
    return WeekPlanSlotsCompanion(
      routineId: routineId ?? this.routineId,
      version: version ?? this.version,
      weekday: weekday ?? this.weekday,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<String>(
          $WeekPlanSlotsTable.$converterweekday.toSql(weekday.value));
    }
    if (workoutDayId.present) {
      map['workout_day_id'] = Variable<String>(workoutDayId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekPlanSlotsCompanion(')
          ..write('routineId: $routineId, ')
          ..write('version: $version, ')
          ..write('weekday: $weekday, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _workoutDayIdMeta =
      const VerificationMeta('workoutDayId');
  @override
  late final GeneratedColumn<String> workoutDayId = GeneratedColumn<String>(
      'workout_day_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _routineVersionMeta =
      const VerificationMeta('routineVersion');
  @override
  late final GeneratedColumn<int> routineVersion = GeneratedColumn<int>(
      'routine_version', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
      intendedExerciseIds = GeneratedColumn<String>(
              'intended_exercise_ids', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>(
              $SessionsTable.$converterintendedExerciseIds);
  static const VerificationMeta _currentExerciseIdMeta =
      const VerificationMeta('currentExerciseId');
  @override
  late final GeneratedColumn<String> currentExerciseId =
      GeneratedColumn<String>('current_exercise_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        workoutDayId,
        routineVersion,
        intendedExerciseIds,
        currentExerciseId,
        startedAt,
        endedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<SessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('workout_day_id')) {
      context.handle(
          _workoutDayIdMeta,
          workoutDayId.isAcceptableOrUnknown(
              data['workout_day_id']!, _workoutDayIdMeta));
    }
    if (data.containsKey('routine_version')) {
      context.handle(
          _routineVersionMeta,
          routineVersion.isAcceptableOrUnknown(
              data['routine_version']!, _routineVersionMeta));
    }
    if (data.containsKey('current_exercise_id')) {
      context.handle(
          _currentExerciseIdMeta,
          currentExerciseId.isAcceptableOrUnknown(
              data['current_exercise_id']!, _currentExerciseIdMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      workoutDayId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workout_day_id']),
      routineVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}routine_version']),
      intendedExerciseIds: $SessionsTable.$converterintendedExerciseIds.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}intended_exercise_ids'])!),
      currentExerciseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}current_exercise_id']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterintendedExerciseIds =
      const StringListConverter();
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final DateTime date;

  /// Null for an improvised session with no plan behind it. Planning-only
  /// field — analytics/history queries never filter on it (I1).
  final String? workoutDayId;
  final int? routineVersion;
  final List<String> intendedExerciseIds;

  /// Which exercise the next triggered set is attributed to. Must be kept
  /// current so the ambient card never mis-attributes a set.
  final String? currentExerciseId;
  final DateTime startedAt;

  /// I5: ending a session never locks it. This column being non-null must
  /// never gate whether its sets can still be edited.
  final DateTime? endedAt;
  const SessionRow(
      {required this.id,
      required this.date,
      this.workoutDayId,
      this.routineVersion,
      required this.intendedExerciseIds,
      this.currentExerciseId,
      required this.startedAt,
      this.endedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || workoutDayId != null) {
      map['workout_day_id'] = Variable<String>(workoutDayId);
    }
    if (!nullToAbsent || routineVersion != null) {
      map['routine_version'] = Variable<int>(routineVersion);
    }
    {
      map['intended_exercise_ids'] = Variable<String>($SessionsTable
          .$converterintendedExerciseIds
          .toSql(intendedExerciseIds));
    }
    if (!nullToAbsent || currentExerciseId != null) {
      map['current_exercise_id'] = Variable<String>(currentExerciseId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      date: Value(date),
      workoutDayId: workoutDayId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutDayId),
      routineVersion: routineVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(routineVersion),
      intendedExerciseIds: Value(intendedExerciseIds),
      currentExerciseId: currentExerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentExerciseId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory SessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      workoutDayId: serializer.fromJson<String?>(json['workoutDayId']),
      routineVersion: serializer.fromJson<int?>(json['routineVersion']),
      intendedExerciseIds:
          serializer.fromJson<List<String>>(json['intendedExerciseIds']),
      currentExerciseId:
          serializer.fromJson<String?>(json['currentExerciseId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'workoutDayId': serializer.toJson<String?>(workoutDayId),
      'routineVersion': serializer.toJson<int?>(routineVersion),
      'intendedExerciseIds':
          serializer.toJson<List<String>>(intendedExerciseIds),
      'currentExerciseId': serializer.toJson<String?>(currentExerciseId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  SessionRow copyWith(
          {String? id,
          DateTime? date,
          Value<String?> workoutDayId = const Value.absent(),
          Value<int?> routineVersion = const Value.absent(),
          List<String>? intendedExerciseIds,
          Value<String?> currentExerciseId = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent()}) =>
      SessionRow(
        id: id ?? this.id,
        date: date ?? this.date,
        workoutDayId:
            workoutDayId.present ? workoutDayId.value : this.workoutDayId,
        routineVersion:
            routineVersion.present ? routineVersion.value : this.routineVersion,
        intendedExerciseIds: intendedExerciseIds ?? this.intendedExerciseIds,
        currentExerciseId: currentExerciseId.present
            ? currentExerciseId.value
            : this.currentExerciseId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
      );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      workoutDayId: data.workoutDayId.present
          ? data.workoutDayId.value
          : this.workoutDayId,
      routineVersion: data.routineVersion.present
          ? data.routineVersion.value
          : this.routineVersion,
      intendedExerciseIds: data.intendedExerciseIds.present
          ? data.intendedExerciseIds.value
          : this.intendedExerciseIds,
      currentExerciseId: data.currentExerciseId.present
          ? data.currentExerciseId.value
          : this.currentExerciseId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('routineVersion: $routineVersion, ')
          ..write('intendedExerciseIds: $intendedExerciseIds, ')
          ..write('currentExerciseId: $currentExerciseId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, workoutDayId, routineVersion,
      intendedExerciseIds, currentExerciseId, startedAt, endedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.workoutDayId == this.workoutDayId &&
          other.routineVersion == this.routineVersion &&
          other.intendedExerciseIds == this.intendedExerciseIds &&
          other.currentExerciseId == this.currentExerciseId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String?> workoutDayId;
  final Value<int?> routineVersion;
  final Value<List<String>> intendedExerciseIds;
  final Value<String?> currentExerciseId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.workoutDayId = const Value.absent(),
    this.routineVersion = const Value.absent(),
    this.intendedExerciseIds = const Value.absent(),
    this.currentExerciseId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required DateTime date,
    this.workoutDayId = const Value.absent(),
    this.routineVersion = const Value.absent(),
    this.intendedExerciseIds = const Value.absent(),
    this.currentExerciseId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        startedAt = Value(startedAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? workoutDayId,
    Expression<int>? routineVersion,
    Expression<String>? intendedExerciseIds,
    Expression<String>? currentExerciseId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (workoutDayId != null) 'workout_day_id': workoutDayId,
      if (routineVersion != null) 'routine_version': routineVersion,
      if (intendedExerciseIds != null)
        'intended_exercise_ids': intendedExerciseIds,
      if (currentExerciseId != null) 'current_exercise_id': currentExerciseId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<String?>? workoutDayId,
      Value<int?>? routineVersion,
      Value<List<String>>? intendedExerciseIds,
      Value<String?>? currentExerciseId,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<int>? rowid}) {
    return SessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      routineVersion: routineVersion ?? this.routineVersion,
      intendedExerciseIds: intendedExerciseIds ?? this.intendedExerciseIds,
      currentExerciseId: currentExerciseId ?? this.currentExerciseId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (workoutDayId.present) {
      map['workout_day_id'] = Variable<String>(workoutDayId.value);
    }
    if (routineVersion.present) {
      map['routine_version'] = Variable<int>(routineVersion.value);
    }
    if (intendedExerciseIds.present) {
      map['intended_exercise_ids'] = Variable<String>($SessionsTable
          .$converterintendedExerciseIds
          .toSql(intendedExerciseIds.value));
    }
    if (currentExerciseId.present) {
      map['current_exercise_id'] = Variable<String>(currentExerciseId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('workoutDayId: $workoutDayId, ')
          ..write('routineVersion: $routineVersion, ')
          ..write('intendedExerciseIds: $intendedExerciseIds, ')
          ..write('currentExerciseId: $currentExerciseId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionExercisesTable extends SessionExercises
    with TableInfo<$SessionExercisesTable, SessionExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sessions (id)'));
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES exercises (id)'));
  static const VerificationMeta _planOrderMeta =
      const VerificationMeta('planOrder');
  @override
  late final GeneratedColumn<int> planOrder = GeneratedColumn<int>(
      'plan_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _offPlanMeta =
      const VerificationMeta('offPlan');
  @override
  late final GeneratedColumn<bool> offPlan = GeneratedColumn<bool>(
      'off_plan', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("off_plan" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, exerciseId, planOrder, offPlan];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<SessionExerciseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('plan_order')) {
      context.handle(_planOrderMeta,
          planOrder.isAcceptableOrUnknown(data['plan_order']!, _planOrderMeta));
    } else if (isInserting) {
      context.missing(_planOrderMeta);
    }
    if (data.containsKey('off_plan')) {
      context.handle(_offPlanMeta,
          offPlan.isAcceptableOrUnknown(data['off_plan']!, _offPlanMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExerciseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      planOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plan_order'])!,
      offPlan: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}off_plan'])!,
    );
  }

  @override
  $SessionExercisesTable createAlias(String alias) {
    return $SessionExercisesTable(attachedDatabase, alias);
  }
}

class SessionExerciseRow extends DataClass
    implements Insertable<SessionExerciseRow> {
  final int id;
  final String sessionId;
  final String exerciseId;
  final int planOrder;
  final bool offPlan;
  const SessionExerciseRow(
      {required this.id,
      required this.sessionId,
      required this.exerciseId,
      required this.planOrder,
      required this.offPlan});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['plan_order'] = Variable<int>(planOrder);
    map['off_plan'] = Variable<bool>(offPlan);
    return map;
  }

  SessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return SessionExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      planOrder: Value(planOrder),
      offPlan: Value(offPlan),
    );
  }

  factory SessionExerciseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExerciseRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      planOrder: serializer.fromJson<int>(json['planOrder']),
      offPlan: serializer.fromJson<bool>(json['offPlan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'planOrder': serializer.toJson<int>(planOrder),
      'offPlan': serializer.toJson<bool>(offPlan),
    };
  }

  SessionExerciseRow copyWith(
          {int? id,
          String? sessionId,
          String? exerciseId,
          int? planOrder,
          bool? offPlan}) =>
      SessionExerciseRow(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        exerciseId: exerciseId ?? this.exerciseId,
        planOrder: planOrder ?? this.planOrder,
        offPlan: offPlan ?? this.offPlan,
      );
  SessionExerciseRow copyWithCompanion(SessionExercisesCompanion data) {
    return SessionExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      planOrder: data.planOrder.present ? data.planOrder.value : this.planOrder,
      offPlan: data.offPlan.present ? data.offPlan.value : this.offPlan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExerciseRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('planOrder: $planOrder, ')
          ..write('offPlan: $offPlan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, exerciseId, planOrder, offPlan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExerciseRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.planOrder == this.planOrder &&
          other.offPlan == this.offPlan);
}

class SessionExercisesCompanion extends UpdateCompanion<SessionExerciseRow> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<String> exerciseId;
  final Value<int> planOrder;
  final Value<bool> offPlan;
  const SessionExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.planOrder = const Value.absent(),
    this.offPlan = const Value.absent(),
  });
  SessionExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required String exerciseId,
    required int planOrder,
    this.offPlan = const Value.absent(),
  })  : sessionId = Value(sessionId),
        exerciseId = Value(exerciseId),
        planOrder = Value(planOrder);
  static Insertable<SessionExerciseRow> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<int>? planOrder,
    Expression<bool>? offPlan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (planOrder != null) 'plan_order': planOrder,
      if (offPlan != null) 'off_plan': offPlan,
    });
  }

  SessionExercisesCompanion copyWith(
      {Value<int>? id,
      Value<String>? sessionId,
      Value<String>? exerciseId,
      Value<int>? planOrder,
      Value<bool>? offPlan}) {
    return SessionExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      planOrder: planOrder ?? this.planOrder,
      offPlan: offPlan ?? this.offPlan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (planOrder.present) {
      map['plan_order'] = Variable<int>(planOrder.value);
    }
    if (offPlan.present) {
      map['off_plan'] = Variable<bool>(offPlan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('planOrder: $planOrder, ')
          ..write('offPlan: $offPlan')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionExerciseIdMeta =
      const VerificationMeta('sessionExerciseId');
  @override
  late final GeneratedColumn<int> sessionExerciseId = GeneratedColumn<int>(
      'session_exercise_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES session_exercises (id)'));
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
      'seq', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<Execution, String> execution =
      GeneratedColumn<String>('execution', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('bilateral'))
          .withConverter<Execution>($WorkoutSetsTable.$converterexecution);
  static const VerificationMeta _aggregateRepsMeta =
      const VerificationMeta('aggregateReps');
  @override
  late final GeneratedColumn<int> aggregateReps = GeneratedColumn<int>(
      'aggregate_reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($WorkoutSetsTable.$convertertags);
  static const VerificationMeta _tempoMeta = const VerificationMeta('tempo');
  @override
  late final GeneratedColumn<String> tempo = GeneratedColumn<String>(
      'tempo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionExerciseId,
        exerciseId,
        seq,
        execution,
        aggregateReps,
        tags,
        tempo,
        startedAt,
        endedAt,
        note
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSetRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_exercise_id')) {
      context.handle(
          _sessionExerciseIdMeta,
          sessionExerciseId.isAcceptableOrUnknown(
              data['session_exercise_id']!, _sessionExerciseIdMeta));
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
          _seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('aggregate_reps')) {
      context.handle(
          _aggregateRepsMeta,
          aggregateReps.isAcceptableOrUnknown(
              data['aggregate_reps']!, _aggregateRepsMeta));
    }
    if (data.containsKey('tempo')) {
      context.handle(
          _tempoMeta, tempo.isAcceptableOrUnknown(data['tempo']!, _tempoMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSetRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionExerciseId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}session_exercise_id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      seq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seq'])!,
      execution: $WorkoutSetsTable.$converterexecution.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}execution'])!),
      aggregateReps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}aggregate_reps']),
      tags: $WorkoutSetsTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      tempo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tempo']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Execution, String, String> $converterexecution =
      const EnumNameConverter<Execution>(Execution.values);
  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class WorkoutSetRow extends DataClass implements Insertable<WorkoutSetRow> {
  final String id;
  final int sessionExerciseId;

  /// The only link analytics needs (I1). Denormalized here so history/PR/
  /// chart queries never have to join through [SessionExercises].
  final String exerciseId;

  /// Insertion-order stamp, NOT the positional index — the index itself is
  /// never stored (see milestone 03: "don't trust a stored value to stay
  /// correct after a delete"). Repositories derive `WorkoutSet.index` by
  /// ordering rows within a [SessionExercises] group by this column and
  /// enumerating on read, so a mid-list delete can never leave a stale
  /// index behind.
  final int seq;
  final Execution execution;

  /// I4: nullable. "Total 50 reps" across a drop set with no per-segment
  /// counts recorded is valid and must save.
  final int? aggregateReps;
  final List<String> tags;
  final String? tempo;

  /// Authoritative timestamps from the trigger journal. Duration is always
  /// endedAt - startedAt, never computed at drain time.
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? note;
  const WorkoutSetRow(
      {required this.id,
      required this.sessionExerciseId,
      required this.exerciseId,
      required this.seq,
      required this.execution,
      this.aggregateReps,
      required this.tags,
      this.tempo,
      this.startedAt,
      this.endedAt,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_exercise_id'] = Variable<int>(sessionExerciseId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['seq'] = Variable<int>(seq);
    {
      map['execution'] = Variable<String>(
          $WorkoutSetsTable.$converterexecution.toSql(execution));
    }
    if (!nullToAbsent || aggregateReps != null) {
      map['aggregate_reps'] = Variable<int>(aggregateReps);
    }
    {
      map['tags'] =
          Variable<String>($WorkoutSetsTable.$convertertags.toSql(tags));
    }
    if (!nullToAbsent || tempo != null) {
      map['tempo'] = Variable<String>(tempo);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      sessionExerciseId: Value(sessionExerciseId),
      exerciseId: Value(exerciseId),
      seq: Value(seq),
      execution: Value(execution),
      aggregateReps: aggregateReps == null && nullToAbsent
          ? const Value.absent()
          : Value(aggregateReps),
      tags: Value(tags),
      tempo:
          tempo == null && nullToAbsent ? const Value.absent() : Value(tempo),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WorkoutSetRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSetRow(
      id: serializer.fromJson<String>(json['id']),
      sessionExerciseId: serializer.fromJson<int>(json['sessionExerciseId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      seq: serializer.fromJson<int>(json['seq']),
      execution: $WorkoutSetsTable.$converterexecution
          .fromJson(serializer.fromJson<String>(json['execution'])),
      aggregateReps: serializer.fromJson<int?>(json['aggregateReps']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      tempo: serializer.fromJson<String?>(json['tempo']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionExerciseId': serializer.toJson<int>(sessionExerciseId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'seq': serializer.toJson<int>(seq),
      'execution': serializer.toJson<String>(
          $WorkoutSetsTable.$converterexecution.toJson(execution)),
      'aggregateReps': serializer.toJson<int?>(aggregateReps),
      'tags': serializer.toJson<List<String>>(tags),
      'tempo': serializer.toJson<String?>(tempo),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  WorkoutSetRow copyWith(
          {String? id,
          int? sessionExerciseId,
          String? exerciseId,
          int? seq,
          Execution? execution,
          Value<int?> aggregateReps = const Value.absent(),
          List<String>? tags,
          Value<String?> tempo = const Value.absent(),
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> endedAt = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      WorkoutSetRow(
        id: id ?? this.id,
        sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
        exerciseId: exerciseId ?? this.exerciseId,
        seq: seq ?? this.seq,
        execution: execution ?? this.execution,
        aggregateReps:
            aggregateReps.present ? aggregateReps.value : this.aggregateReps,
        tags: tags ?? this.tags,
        tempo: tempo.present ? tempo.value : this.tempo,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        note: note.present ? note.value : this.note,
      );
  WorkoutSetRow copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSetRow(
      id: data.id.present ? data.id.value : this.id,
      sessionExerciseId: data.sessionExerciseId.present
          ? data.sessionExerciseId.value
          : this.sessionExerciseId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      seq: data.seq.present ? data.seq.value : this.seq,
      execution: data.execution.present ? data.execution.value : this.execution,
      aggregateReps: data.aggregateReps.present
          ? data.aggregateReps.value
          : this.aggregateReps,
      tags: data.tags.present ? data.tags.value : this.tags,
      tempo: data.tempo.present ? data.tempo.value : this.tempo,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetRow(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('seq: $seq, ')
          ..write('execution: $execution, ')
          ..write('aggregateReps: $aggregateReps, ')
          ..write('tags: $tags, ')
          ..write('tempo: $tempo, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionExerciseId, exerciseId, seq,
      execution, aggregateReps, tags, tempo, startedAt, endedAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSetRow &&
          other.id == this.id &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.exerciseId == this.exerciseId &&
          other.seq == this.seq &&
          other.execution == this.execution &&
          other.aggregateReps == this.aggregateReps &&
          other.tags == this.tags &&
          other.tempo == this.tempo &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.note == this.note);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSetRow> {
  final Value<String> id;
  final Value<int> sessionExerciseId;
  final Value<String> exerciseId;
  final Value<int> seq;
  final Value<Execution> execution;
  final Value<int?> aggregateReps;
  final Value<List<String>> tags;
  final Value<String?> tempo;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> note;
  final Value<int> rowid;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.sessionExerciseId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.seq = const Value.absent(),
    this.execution = const Value.absent(),
    this.aggregateReps = const Value.absent(),
    this.tags = const Value.absent(),
    this.tempo = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    required String id,
    required int sessionExerciseId,
    required String exerciseId,
    required int seq,
    this.execution = const Value.absent(),
    this.aggregateReps = const Value.absent(),
    this.tags = const Value.absent(),
    this.tempo = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionExerciseId = Value(sessionExerciseId),
        exerciseId = Value(exerciseId),
        seq = Value(seq);
  static Insertable<WorkoutSetRow> custom({
    Expression<String>? id,
    Expression<int>? sessionExerciseId,
    Expression<String>? exerciseId,
    Expression<int>? seq,
    Expression<String>? execution,
    Expression<int>? aggregateReps,
    Expression<String>? tags,
    Expression<String>? tempo,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (seq != null) 'seq': seq,
      if (execution != null) 'execution': execution,
      if (aggregateReps != null) 'aggregate_reps': aggregateReps,
      if (tags != null) 'tags': tags,
      if (tempo != null) 'tempo': tempo,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSetsCompanion copyWith(
      {Value<String>? id,
      Value<int>? sessionExerciseId,
      Value<String>? exerciseId,
      Value<int>? seq,
      Value<Execution>? execution,
      Value<int?>? aggregateReps,
      Value<List<String>>? tags,
      Value<String?>? tempo,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? endedAt,
      Value<String?>? note,
      Value<int>? rowid}) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      seq: seq ?? this.seq,
      execution: execution ?? this.execution,
      aggregateReps: aggregateReps ?? this.aggregateReps,
      tags: tags ?? this.tags,
      tempo: tempo ?? this.tempo,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<int>(sessionExerciseId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (execution.present) {
      map['execution'] = Variable<String>(
          $WorkoutSetsTable.$converterexecution.toSql(execution.value));
    }
    if (aggregateReps.present) {
      map['aggregate_reps'] = Variable<int>(aggregateReps.value);
    }
    if (tags.present) {
      map['tags'] =
          Variable<String>($WorkoutSetsTable.$convertertags.toSql(tags.value));
    }
    if (tempo.present) {
      map['tempo'] = Variable<String>(tempo.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('seq: $seq, ')
          ..write('execution: $execution, ')
          ..write('aggregateReps: $aggregateReps, ')
          ..write('tags: $tags, ')
          ..write('tempo: $tempo, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetSegmentsTable extends SetSegments
    with TableInfo<$SetSegmentsTable, SetSegmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workoutSetIdMeta =
      const VerificationMeta('workoutSetId');
  @override
  late final GeneratedColumn<String> workoutSetId = GeneratedColumn<String>(
      'workout_set_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workout_sets (id)'));
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
      'seq', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _loadValueMeta =
      const VerificationMeta('loadValue');
  @override
  late final GeneratedColumn<double> loadValue = GeneratedColumn<double>(
      'load_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<LoadUnit, String> loadUnit =
      GeneratedColumn<String>('load_unit', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('kg'))
          .withConverter<LoadUnit>($SetSegmentsTable.$converterloadUnit);
  @override
  late final GeneratedColumnWithTypeConverter<LoadSource, String> loadSource =
      GeneratedColumn<String>('load_source', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<LoadSource>($SetSegmentsTable.$converterloadSource);
  @override
  late final GeneratedColumnWithTypeConverter<LoadScope, String> loadScope =
      GeneratedColumn<String>('load_scope', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('total'))
          .withConverter<LoadScope>($SetSegmentsTable.$converterloadScope);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _repsLeftMeta =
      const VerificationMeta('repsLeft');
  @override
  late final GeneratedColumn<int> repsLeft = GeneratedColumn<int>(
      'reps_left', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _repsRightMeta =
      const VerificationMeta('repsRight');
  @override
  late final GeneratedColumn<int> repsRight = GeneratedColumn<int>(
      'reps_right', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        workoutSetId,
        seq,
        loadValue,
        loadUnit,
        loadSource,
        loadScope,
        reps,
        repsLeft,
        repsRight
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_segments';
  @override
  VerificationContext validateIntegrity(Insertable<SetSegmentRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_set_id')) {
      context.handle(
          _workoutSetIdMeta,
          workoutSetId.isAcceptableOrUnknown(
              data['workout_set_id']!, _workoutSetIdMeta));
    } else if (isInserting) {
      context.missing(_workoutSetIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
          _seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('load_value')) {
      context.handle(_loadValueMeta,
          loadValue.isAcceptableOrUnknown(data['load_value']!, _loadValueMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('reps_left')) {
      context.handle(_repsLeftMeta,
          repsLeft.isAcceptableOrUnknown(data['reps_left']!, _repsLeftMeta));
    }
    if (data.containsKey('reps_right')) {
      context.handle(_repsRightMeta,
          repsRight.isAcceptableOrUnknown(data['reps_right']!, _repsRightMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetSegmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetSegmentRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workoutSetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workout_set_id'])!,
      seq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seq'])!,
      loadValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}load_value']),
      loadUnit: $SetSegmentsTable.$converterloadUnit.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}load_unit'])!),
      loadSource: $SetSegmentsTable.$converterloadSource.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}load_source'])!),
      loadScope: $SetSegmentsTable.$converterloadScope.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}load_scope'])!),
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps']),
      repsLeft: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps_left']),
      repsRight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps_right']),
    );
  }

  @override
  $SetSegmentsTable createAlias(String alias) {
    return $SetSegmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LoadUnit, String, String> $converterloadUnit =
      const EnumNameConverter<LoadUnit>(LoadUnit.values);
  static JsonTypeConverter2<LoadSource, String, String> $converterloadSource =
      const EnumNameConverter<LoadSource>(LoadSource.values);
  static JsonTypeConverter2<LoadScope, String, String> $converterloadScope =
      const EnumNameConverter<LoadScope>(LoadScope.values);
}

class SetSegmentRow extends DataClass implements Insertable<SetSegmentRow> {
  final int id;
  final String workoutSetId;

  /// Same insertion-order stamp as [WorkoutSets.seq] — segments are
  /// positional within a set too.
  final int seq;

  /// I4: nullable — pure bodyweight has no value.
  final double? loadValue;
  final LoadUnit loadUnit;
  final LoadSource loadSource;
  final LoadScope loadScope;

  /// I4: all three nullable. A hurried user may log a weight and nothing else.
  final int? reps;
  final int? repsLeft;
  final int? repsRight;
  const SetSegmentRow(
      {required this.id,
      required this.workoutSetId,
      required this.seq,
      this.loadValue,
      required this.loadUnit,
      required this.loadSource,
      required this.loadScope,
      this.reps,
      this.repsLeft,
      this.repsRight});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_set_id'] = Variable<String>(workoutSetId);
    map['seq'] = Variable<int>(seq);
    if (!nullToAbsent || loadValue != null) {
      map['load_value'] = Variable<double>(loadValue);
    }
    {
      map['load_unit'] = Variable<String>(
          $SetSegmentsTable.$converterloadUnit.toSql(loadUnit));
    }
    {
      map['load_source'] = Variable<String>(
          $SetSegmentsTable.$converterloadSource.toSql(loadSource));
    }
    {
      map['load_scope'] = Variable<String>(
          $SetSegmentsTable.$converterloadScope.toSql(loadScope));
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || repsLeft != null) {
      map['reps_left'] = Variable<int>(repsLeft);
    }
    if (!nullToAbsent || repsRight != null) {
      map['reps_right'] = Variable<int>(repsRight);
    }
    return map;
  }

  SetSegmentsCompanion toCompanion(bool nullToAbsent) {
    return SetSegmentsCompanion(
      id: Value(id),
      workoutSetId: Value(workoutSetId),
      seq: Value(seq),
      loadValue: loadValue == null && nullToAbsent
          ? const Value.absent()
          : Value(loadValue),
      loadUnit: Value(loadUnit),
      loadSource: Value(loadSource),
      loadScope: Value(loadScope),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      repsLeft: repsLeft == null && nullToAbsent
          ? const Value.absent()
          : Value(repsLeft),
      repsRight: repsRight == null && nullToAbsent
          ? const Value.absent()
          : Value(repsRight),
    );
  }

  factory SetSegmentRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetSegmentRow(
      id: serializer.fromJson<int>(json['id']),
      workoutSetId: serializer.fromJson<String>(json['workoutSetId']),
      seq: serializer.fromJson<int>(json['seq']),
      loadValue: serializer.fromJson<double?>(json['loadValue']),
      loadUnit: $SetSegmentsTable.$converterloadUnit
          .fromJson(serializer.fromJson<String>(json['loadUnit'])),
      loadSource: $SetSegmentsTable.$converterloadSource
          .fromJson(serializer.fromJson<String>(json['loadSource'])),
      loadScope: $SetSegmentsTable.$converterloadScope
          .fromJson(serializer.fromJson<String>(json['loadScope'])),
      reps: serializer.fromJson<int?>(json['reps']),
      repsLeft: serializer.fromJson<int?>(json['repsLeft']),
      repsRight: serializer.fromJson<int?>(json['repsRight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutSetId': serializer.toJson<String>(workoutSetId),
      'seq': serializer.toJson<int>(seq),
      'loadValue': serializer.toJson<double?>(loadValue),
      'loadUnit': serializer.toJson<String>(
          $SetSegmentsTable.$converterloadUnit.toJson(loadUnit)),
      'loadSource': serializer.toJson<String>(
          $SetSegmentsTable.$converterloadSource.toJson(loadSource)),
      'loadScope': serializer.toJson<String>(
          $SetSegmentsTable.$converterloadScope.toJson(loadScope)),
      'reps': serializer.toJson<int?>(reps),
      'repsLeft': serializer.toJson<int?>(repsLeft),
      'repsRight': serializer.toJson<int?>(repsRight),
    };
  }

  SetSegmentRow copyWith(
          {int? id,
          String? workoutSetId,
          int? seq,
          Value<double?> loadValue = const Value.absent(),
          LoadUnit? loadUnit,
          LoadSource? loadSource,
          LoadScope? loadScope,
          Value<int?> reps = const Value.absent(),
          Value<int?> repsLeft = const Value.absent(),
          Value<int?> repsRight = const Value.absent()}) =>
      SetSegmentRow(
        id: id ?? this.id,
        workoutSetId: workoutSetId ?? this.workoutSetId,
        seq: seq ?? this.seq,
        loadValue: loadValue.present ? loadValue.value : this.loadValue,
        loadUnit: loadUnit ?? this.loadUnit,
        loadSource: loadSource ?? this.loadSource,
        loadScope: loadScope ?? this.loadScope,
        reps: reps.present ? reps.value : this.reps,
        repsLeft: repsLeft.present ? repsLeft.value : this.repsLeft,
        repsRight: repsRight.present ? repsRight.value : this.repsRight,
      );
  SetSegmentRow copyWithCompanion(SetSegmentsCompanion data) {
    return SetSegmentRow(
      id: data.id.present ? data.id.value : this.id,
      workoutSetId: data.workoutSetId.present
          ? data.workoutSetId.value
          : this.workoutSetId,
      seq: data.seq.present ? data.seq.value : this.seq,
      loadValue: data.loadValue.present ? data.loadValue.value : this.loadValue,
      loadUnit: data.loadUnit.present ? data.loadUnit.value : this.loadUnit,
      loadSource:
          data.loadSource.present ? data.loadSource.value : this.loadSource,
      loadScope: data.loadScope.present ? data.loadScope.value : this.loadScope,
      reps: data.reps.present ? data.reps.value : this.reps,
      repsLeft: data.repsLeft.present ? data.repsLeft.value : this.repsLeft,
      repsRight: data.repsRight.present ? data.repsRight.value : this.repsRight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetSegmentRow(')
          ..write('id: $id, ')
          ..write('workoutSetId: $workoutSetId, ')
          ..write('seq: $seq, ')
          ..write('loadValue: $loadValue, ')
          ..write('loadUnit: $loadUnit, ')
          ..write('loadSource: $loadSource, ')
          ..write('loadScope: $loadScope, ')
          ..write('reps: $reps, ')
          ..write('repsLeft: $repsLeft, ')
          ..write('repsRight: $repsRight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, workoutSetId, seq, loadValue, loadUnit,
      loadSource, loadScope, reps, repsLeft, repsRight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetSegmentRow &&
          other.id == this.id &&
          other.workoutSetId == this.workoutSetId &&
          other.seq == this.seq &&
          other.loadValue == this.loadValue &&
          other.loadUnit == this.loadUnit &&
          other.loadSource == this.loadSource &&
          other.loadScope == this.loadScope &&
          other.reps == this.reps &&
          other.repsLeft == this.repsLeft &&
          other.repsRight == this.repsRight);
}

class SetSegmentsCompanion extends UpdateCompanion<SetSegmentRow> {
  final Value<int> id;
  final Value<String> workoutSetId;
  final Value<int> seq;
  final Value<double?> loadValue;
  final Value<LoadUnit> loadUnit;
  final Value<LoadSource> loadSource;
  final Value<LoadScope> loadScope;
  final Value<int?> reps;
  final Value<int?> repsLeft;
  final Value<int?> repsRight;
  const SetSegmentsCompanion({
    this.id = const Value.absent(),
    this.workoutSetId = const Value.absent(),
    this.seq = const Value.absent(),
    this.loadValue = const Value.absent(),
    this.loadUnit = const Value.absent(),
    this.loadSource = const Value.absent(),
    this.loadScope = const Value.absent(),
    this.reps = const Value.absent(),
    this.repsLeft = const Value.absent(),
    this.repsRight = const Value.absent(),
  });
  SetSegmentsCompanion.insert({
    this.id = const Value.absent(),
    required String workoutSetId,
    required int seq,
    this.loadValue = const Value.absent(),
    this.loadUnit = const Value.absent(),
    required LoadSource loadSource,
    this.loadScope = const Value.absent(),
    this.reps = const Value.absent(),
    this.repsLeft = const Value.absent(),
    this.repsRight = const Value.absent(),
  })  : workoutSetId = Value(workoutSetId),
        seq = Value(seq),
        loadSource = Value(loadSource);
  static Insertable<SetSegmentRow> custom({
    Expression<int>? id,
    Expression<String>? workoutSetId,
    Expression<int>? seq,
    Expression<double>? loadValue,
    Expression<String>? loadUnit,
    Expression<String>? loadSource,
    Expression<String>? loadScope,
    Expression<int>? reps,
    Expression<int>? repsLeft,
    Expression<int>? repsRight,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutSetId != null) 'workout_set_id': workoutSetId,
      if (seq != null) 'seq': seq,
      if (loadValue != null) 'load_value': loadValue,
      if (loadUnit != null) 'load_unit': loadUnit,
      if (loadSource != null) 'load_source': loadSource,
      if (loadScope != null) 'load_scope': loadScope,
      if (reps != null) 'reps': reps,
      if (repsLeft != null) 'reps_left': repsLeft,
      if (repsRight != null) 'reps_right': repsRight,
    });
  }

  SetSegmentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? workoutSetId,
      Value<int>? seq,
      Value<double?>? loadValue,
      Value<LoadUnit>? loadUnit,
      Value<LoadSource>? loadSource,
      Value<LoadScope>? loadScope,
      Value<int?>? reps,
      Value<int?>? repsLeft,
      Value<int?>? repsRight}) {
    return SetSegmentsCompanion(
      id: id ?? this.id,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      seq: seq ?? this.seq,
      loadValue: loadValue ?? this.loadValue,
      loadUnit: loadUnit ?? this.loadUnit,
      loadSource: loadSource ?? this.loadSource,
      loadScope: loadScope ?? this.loadScope,
      reps: reps ?? this.reps,
      repsLeft: repsLeft ?? this.repsLeft,
      repsRight: repsRight ?? this.repsRight,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutSetId.present) {
      map['workout_set_id'] = Variable<String>(workoutSetId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (loadValue.present) {
      map['load_value'] = Variable<double>(loadValue.value);
    }
    if (loadUnit.present) {
      map['load_unit'] = Variable<String>(
          $SetSegmentsTable.$converterloadUnit.toSql(loadUnit.value));
    }
    if (loadSource.present) {
      map['load_source'] = Variable<String>(
          $SetSegmentsTable.$converterloadSource.toSql(loadSource.value));
    }
    if (loadScope.present) {
      map['load_scope'] = Variable<String>(
          $SetSegmentsTable.$converterloadScope.toSql(loadScope.value));
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (repsLeft.present) {
      map['reps_left'] = Variable<int>(repsLeft.value);
    }
    if (repsRight.present) {
      map['reps_right'] = Variable<int>(repsRight.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('workoutSetId: $workoutSetId, ')
          ..write('seq: $seq, ')
          ..write('loadValue: $loadValue, ')
          ..write('loadUnit: $loadUnit, ')
          ..write('loadSource: $loadSource, ')
          ..write('loadScope: $loadScope, ')
          ..write('reps: $reps, ')
          ..write('repsLeft: $repsLeft, ')
          ..write('repsRight: $repsRight')
          ..write(')'))
        .toString();
  }
}

class $BodyweightEntriesTable extends BodyweightEntries
    with TableInfo<$BodyweightEntriesTable, BodyweightEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyweightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
      'kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, date, kg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bodyweight_entries';
  @override
  VerificationContext validateIntegrity(Insertable<BodyweightEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyweightEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyweightEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      kg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}kg'])!,
    );
  }

  @override
  $BodyweightEntriesTable createAlias(String alias) {
    return $BodyweightEntriesTable(attachedDatabase, alias);
  }
}

class BodyweightEntryRow extends DataClass
    implements Insertable<BodyweightEntryRow> {
  final int id;
  final DateTime date;
  final double kg;
  const BodyweightEntryRow(
      {required this.id, required this.date, required this.kg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['kg'] = Variable<double>(kg);
    return map;
  }

  BodyweightEntriesCompanion toCompanion(bool nullToAbsent) {
    return BodyweightEntriesCompanion(
      id: Value(id),
      date: Value(date),
      kg: Value(kg),
    );
  }

  factory BodyweightEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyweightEntryRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      kg: serializer.fromJson<double>(json['kg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'kg': serializer.toJson<double>(kg),
    };
  }

  BodyweightEntryRow copyWith({int? id, DateTime? date, double? kg}) =>
      BodyweightEntryRow(
        id: id ?? this.id,
        date: date ?? this.date,
        kg: kg ?? this.kg,
      );
  BodyweightEntryRow copyWithCompanion(BodyweightEntriesCompanion data) {
    return BodyweightEntryRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      kg: data.kg.present ? data.kg.value : this.kg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyweightEntryRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kg: $kg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, kg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyweightEntryRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.kg == this.kg);
}

class BodyweightEntriesCompanion extends UpdateCompanion<BodyweightEntryRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> kg;
  const BodyweightEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.kg = const Value.absent(),
  });
  BodyweightEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double kg,
  })  : date = Value(date),
        kg = Value(kg);
  static Insertable<BodyweightEntryRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? kg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (kg != null) 'kg': kg,
    });
  }

  BodyweightEntriesCompanion copyWith(
      {Value<int>? id, Value<DateTime>? date, Value<double>? kg}) {
    return BodyweightEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      kg: kg ?? this.kg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyweightEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kg: $kg')
          ..write(')'))
        .toString();
  }
}

class $SeedMetaTable extends SeedMeta
    with TableInfo<$SeedMetaTable, SeedMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeedMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seed_meta';
  @override
  VerificationContext validateIntegrity(Insertable<SeedMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SeedMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeedMetaData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SeedMetaTable createAlias(String alias) {
    return $SeedMetaTable(attachedDatabase, alias);
  }
}

class SeedMetaData extends DataClass implements Insertable<SeedMetaData> {
  final String key;
  final String value;
  const SeedMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SeedMetaCompanion toCompanion(bool nullToAbsent) {
    return SeedMetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SeedMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeedMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SeedMetaData copyWith({String? key, String? value}) => SeedMetaData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SeedMetaData copyWithCompanion(SeedMetaCompanion data) {
    return SeedMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeedMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeedMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class SeedMetaCompanion extends UpdateCompanion<SeedMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SeedMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeedMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SeedMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeedMetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SeedMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeedMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $WorkoutDaysTable workoutDays = $WorkoutDaysTable(this);
  late final $PlannedExercisesTable plannedExercises =
      $PlannedExercisesTable(this);
  late final $WeekPlansTable weekPlans = $WeekPlansTable(this);
  late final $WeekPlanSlotsTable weekPlanSlots = $WeekPlanSlotsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionExercisesTable sessionExercises =
      $SessionExercisesTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $SetSegmentsTable setSegments = $SetSegmentsTable(this);
  late final $BodyweightEntriesTable bodyweightEntries =
      $BodyweightEntriesTable(this);
  late final $SeedMetaTable seedMeta = $SeedMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        exercises,
        workoutDays,
        plannedExercises,
        weekPlans,
        weekPlanSlots,
        sessions,
        sessionExercises,
        workoutSets,
        setSegments,
        bodyweightEntries,
        seedMeta
      ];
}

typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  required String id,
  Value<bool> isCustom,
  required String name,
  Value<List<String>> aliases,
  required Muscle primaryMuscle,
  Value<List<String>> secondaryMuscles,
  required Equipment equipment,
  Value<Execution> defaultExecution,
  Value<String?> variantOf,
  Value<double?> incrementOverride,
  Value<double> equipmentIncrement,
  Value<bool> archived,
  Value<int> rowid,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<String> id,
  Value<bool> isCustom,
  Value<String> name,
  Value<List<String>> aliases,
  Value<Muscle> primaryMuscle,
  Value<List<String>> secondaryMuscles,
  Value<Equipment> equipment,
  Value<Execution> defaultExecution,
  Value<String?> variantOf,
  Value<double?> incrementOverride,
  Value<double> equipmentIncrement,
  Value<bool> archived,
  Value<int> rowid,
});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlannedExercisesTable, List<PlannedExerciseRow>>
      _plannedExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.plannedExercises,
              aliasName: 'exercises__id__planned_exercises__exercise_id');

  $$PlannedExercisesTableProcessedTableManager get plannedExercisesRefs {
    final manager = $$PlannedExercisesTableTableManager(
            $_db, $_db.plannedExercises)
        .filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_plannedExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExerciseRow>>
      _sessionExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sessionExercises,
              aliasName: 'exercises__id__session_exercises__exercise_id');

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
            $_db, $_db.sessionExercises)
        .filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_sessionExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get aliases => $composableBuilder(
          column: $table.aliases,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Muscle, Muscle, String> get primaryMuscle =>
      $composableBuilder(
          column: $table.primaryMuscle,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get secondaryMuscles => $composableBuilder(
          column: $table.secondaryMuscles,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Equipment, Equipment, String> get equipment =>
      $composableBuilder(
          column: $table.equipment,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Execution, Execution, String>
      get defaultExecution => $composableBuilder(
          column: $table.defaultExecution,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get variantOf => $composableBuilder(
      column: $table.variantOf, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get incrementOverride => $composableBuilder(
      column: $table.incrementOverride,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get equipmentIncrement => $composableBuilder(
      column: $table.equipmentIncrement,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnFilters(column));

  Expression<bool> plannedExercisesRefs(
      Expression<bool> Function($$PlannedExercisesTableFilterComposer f) f) {
    final $$PlannedExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plannedExercises,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlannedExercisesTableFilterComposer(
              $db: $db,
              $table: $db.plannedExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sessionExercisesRefs(
      Expression<bool> Function($$SessionExercisesTableFilterComposer f) f) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessionExercises,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionExercisesTableFilterComposer(
              $db: $db,
              $table: $db.sessionExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primaryMuscle => $composableBuilder(
      column: $table.primaryMuscle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
      column: $table.secondaryMuscles,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipment => $composableBuilder(
      column: $table.equipment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultExecution => $composableBuilder(
      column: $table.defaultExecution,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantOf => $composableBuilder(
      column: $table.variantOf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get incrementOverride => $composableBuilder(
      column: $table.incrementOverride,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get equipmentIncrement => $composableBuilder(
      column: $table.equipmentIncrement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Muscle, String> get primaryMuscle =>
      $composableBuilder(
          column: $table.primaryMuscle, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get secondaryMuscles =>
      $composableBuilder(
          column: $table.secondaryMuscles, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Equipment, String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Execution, String> get defaultExecution =>
      $composableBuilder(
          column: $table.defaultExecution, builder: (column) => column);

  GeneratedColumn<String> get variantOf =>
      $composableBuilder(column: $table.variantOf, builder: (column) => column);

  GeneratedColumn<double> get incrementOverride => $composableBuilder(
      column: $table.incrementOverride, builder: (column) => column);

  GeneratedColumn<double> get equipmentIncrement => $composableBuilder(
      column: $table.equipmentIncrement, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> plannedExercisesRefs<T extends Object>(
      Expression<T> Function($$PlannedExercisesTableAnnotationComposer a) f) {
    final $$PlannedExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plannedExercises,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlannedExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.plannedExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sessionExercisesRefs<T extends Object>(
      Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessionExercises,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.sessionExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExercisesTable,
    ExerciseRow,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableAnnotationComposer,
    $$ExercisesTableCreateCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder,
    (ExerciseRow, $$ExercisesTableReferences),
    ExerciseRow,
    PrefetchHooks Function(
        {bool plannedExercisesRefs, bool sessionExercisesRefs})> {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<List<String>> aliases = const Value.absent(),
            Value<Muscle> primaryMuscle = const Value.absent(),
            Value<List<String>> secondaryMuscles = const Value.absent(),
            Value<Equipment> equipment = const Value.absent(),
            Value<Execution> defaultExecution = const Value.absent(),
            Value<String?> variantOf = const Value.absent(),
            Value<double?> incrementOverride = const Value.absent(),
            Value<double> equipmentIncrement = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExercisesCompanion(
            id: id,
            isCustom: isCustom,
            name: name,
            aliases: aliases,
            primaryMuscle: primaryMuscle,
            secondaryMuscles: secondaryMuscles,
            equipment: equipment,
            defaultExecution: defaultExecution,
            variantOf: variantOf,
            incrementOverride: incrementOverride,
            equipmentIncrement: equipmentIncrement,
            archived: archived,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<bool> isCustom = const Value.absent(),
            required String name,
            Value<List<String>> aliases = const Value.absent(),
            required Muscle primaryMuscle,
            Value<List<String>> secondaryMuscles = const Value.absent(),
            required Equipment equipment,
            Value<Execution> defaultExecution = const Value.absent(),
            Value<String?> variantOf = const Value.absent(),
            Value<double?> incrementOverride = const Value.absent(),
            Value<double> equipmentIncrement = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExercisesCompanion.insert(
            id: id,
            isCustom: isCustom,
            name: name,
            aliases: aliases,
            primaryMuscle: primaryMuscle,
            secondaryMuscles: secondaryMuscles,
            equipment: equipment,
            defaultExecution: defaultExecution,
            variantOf: variantOf,
            incrementOverride: incrementOverride,
            equipmentIncrement: equipmentIncrement,
            archived: archived,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {plannedExercisesRefs = false, sessionExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (plannedExercisesRefs) db.plannedExercises,
                if (sessionExercisesRefs) db.sessionExercises
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plannedExercisesRefs)
                    await $_getPrefetchedData<ExerciseRow, $ExercisesTable,
                            PlannedExerciseRow>(
                        currentTable: table,
                        referencedTable: $$ExercisesTableReferences
                            ._plannedExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExercisesTableReferences(db, table, p0)
                                .plannedExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.exerciseId == item.id),
                        typedResults: items),
                  if (sessionExercisesRefs)
                    await $_getPrefetchedData<ExerciseRow, $ExercisesTable,
                            SessionExerciseRow>(
                        currentTable: table,
                        referencedTable: $$ExercisesTableReferences
                            ._sessionExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExercisesTableReferences(db, table, p0)
                                .sessionExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.exerciseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExercisesTable,
    ExerciseRow,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableAnnotationComposer,
    $$ExercisesTableCreateCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder,
    (ExerciseRow, $$ExercisesTableReferences),
    ExerciseRow,
    PrefetchHooks Function(
        {bool plannedExercisesRefs, bool sessionExercisesRefs})>;
typedef $$WorkoutDaysTableCreateCompanionBuilder = WorkoutDaysCompanion
    Function({
  required String id,
  required String name,
  Value<bool> archived,
  Value<int> rowid,
});
typedef $$WorkoutDaysTableUpdateCompanionBuilder = WorkoutDaysCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<bool> archived,
  Value<int> rowid,
});

final class $$WorkoutDaysTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutDaysTable, WorkoutDayRow> {
  $$WorkoutDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlannedExercisesTable, List<PlannedExerciseRow>>
      _plannedExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.plannedExercises,
              aliasName: 'workout_days__id__planned_exercises__workout_day_id');

  $$PlannedExercisesTableProcessedTableManager get plannedExercisesRefs {
    final manager =
        $$PlannedExercisesTableTableManager($_db, $_db.plannedExercises).filter(
            (f) => f.workoutDayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_plannedExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutDaysTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutDaysTable> {
  $$WorkoutDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnFilters(column));

  Expression<bool> plannedExercisesRefs(
      Expression<bool> Function($$PlannedExercisesTableFilterComposer f) f) {
    final $$PlannedExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plannedExercises,
        getReferencedColumn: (t) => t.workoutDayId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlannedExercisesTableFilterComposer(
              $db: $db,
              $table: $db.plannedExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutDaysTable> {
  $$WorkoutDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutDaysTable> {
  $$WorkoutDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> plannedExercisesRefs<T extends Object>(
      Expression<T> Function($$PlannedExercisesTableAnnotationComposer a) f) {
    final $$PlannedExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plannedExercises,
        getReferencedColumn: (t) => t.workoutDayId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlannedExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.plannedExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutDaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutDaysTable,
    WorkoutDayRow,
    $$WorkoutDaysTableFilterComposer,
    $$WorkoutDaysTableOrderingComposer,
    $$WorkoutDaysTableAnnotationComposer,
    $$WorkoutDaysTableCreateCompanionBuilder,
    $$WorkoutDaysTableUpdateCompanionBuilder,
    (WorkoutDayRow, $$WorkoutDaysTableReferences),
    WorkoutDayRow,
    PrefetchHooks Function({bool plannedExercisesRefs})> {
  $$WorkoutDaysTableTableManager(_$AppDatabase db, $WorkoutDaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutDaysCompanion(
            id: id,
            name: name,
            archived: archived,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<bool> archived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutDaysCompanion.insert(
            id: id,
            name: name,
            archived: archived,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkoutDaysTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({plannedExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (plannedExercisesRefs) db.plannedExercises
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plannedExercisesRefs)
                    await $_getPrefetchedData<WorkoutDayRow, $WorkoutDaysTable,
                            PlannedExerciseRow>(
                        currentTable: table,
                        referencedTable: $$WorkoutDaysTableReferences
                            ._plannedExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutDaysTableReferences(db, table, p0)
                                .plannedExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutDayId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkoutDaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutDaysTable,
    WorkoutDayRow,
    $$WorkoutDaysTableFilterComposer,
    $$WorkoutDaysTableOrderingComposer,
    $$WorkoutDaysTableAnnotationComposer,
    $$WorkoutDaysTableCreateCompanionBuilder,
    $$WorkoutDaysTableUpdateCompanionBuilder,
    (WorkoutDayRow, $$WorkoutDaysTableReferences),
    WorkoutDayRow,
    PrefetchHooks Function({bool plannedExercisesRefs})>;
typedef $$PlannedExercisesTableCreateCompanionBuilder
    = PlannedExercisesCompanion Function({
  Value<int> id,
  required String workoutDayId,
  required String exerciseId,
  required int sortOrder,
  Value<int> targetSets,
  Value<bool> defaultUnilateral,
});
typedef $$PlannedExercisesTableUpdateCompanionBuilder
    = PlannedExercisesCompanion Function({
  Value<int> id,
  Value<String> workoutDayId,
  Value<String> exerciseId,
  Value<int> sortOrder,
  Value<int> targetSets,
  Value<bool> defaultUnilateral,
});

final class $$PlannedExercisesTableReferences extends BaseReferences<
    _$AppDatabase, $PlannedExercisesTable, PlannedExerciseRow> {
  $$PlannedExercisesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutDaysTable _workoutDayIdTable(_$AppDatabase db) =>
      db.workoutDays
          .createAlias('planned_exercises__workout_day_id__workout_days__id');

  $$WorkoutDaysTableProcessedTableManager get workoutDayId {
    final $_column = $_itemColumn<String>('workout_day_id')!;

    final manager = $$WorkoutDaysTableTableManager($_db, $_db.workoutDays)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('planned_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlannedExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedExercisesTable> {
  $$PlannedExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get defaultUnilateral => $composableBuilder(
      column: $table.defaultUnilateral,
      builder: (column) => ColumnFilters(column));

  $$WorkoutDaysTableFilterComposer get workoutDayId {
    final $$WorkoutDaysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutDayId,
        referencedTable: $db.workoutDays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutDaysTableFilterComposer(
              $db: $db,
              $table: $db.workoutDays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableFilterComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlannedExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedExercisesTable> {
  $$PlannedExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get defaultUnilateral => $composableBuilder(
      column: $table.defaultUnilateral,
      builder: (column) => ColumnOrderings(column));

  $$WorkoutDaysTableOrderingComposer get workoutDayId {
    final $$WorkoutDaysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutDayId,
        referencedTable: $db.workoutDays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutDaysTableOrderingComposer(
              $db: $db,
              $table: $db.workoutDays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableOrderingComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlannedExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedExercisesTable> {
  $$PlannedExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => column);

  GeneratedColumn<bool> get defaultUnilateral => $composableBuilder(
      column: $table.defaultUnilateral, builder: (column) => column);

  $$WorkoutDaysTableAnnotationComposer get workoutDayId {
    final $$WorkoutDaysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutDayId,
        referencedTable: $db.workoutDays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutDaysTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutDays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlannedExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlannedExercisesTable,
    PlannedExerciseRow,
    $$PlannedExercisesTableFilterComposer,
    $$PlannedExercisesTableOrderingComposer,
    $$PlannedExercisesTableAnnotationComposer,
    $$PlannedExercisesTableCreateCompanionBuilder,
    $$PlannedExercisesTableUpdateCompanionBuilder,
    (PlannedExerciseRow, $$PlannedExercisesTableReferences),
    PlannedExerciseRow,
    PrefetchHooks Function({bool workoutDayId, bool exerciseId})> {
  $$PlannedExercisesTableTableManager(
      _$AppDatabase db, $PlannedExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> workoutDayId = const Value.absent(),
            Value<String> exerciseId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> targetSets = const Value.absent(),
            Value<bool> defaultUnilateral = const Value.absent(),
          }) =>
              PlannedExercisesCompanion(
            id: id,
            workoutDayId: workoutDayId,
            exerciseId: exerciseId,
            sortOrder: sortOrder,
            targetSets: targetSets,
            defaultUnilateral: defaultUnilateral,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String workoutDayId,
            required String exerciseId,
            required int sortOrder,
            Value<int> targetSets = const Value.absent(),
            Value<bool> defaultUnilateral = const Value.absent(),
          }) =>
              PlannedExercisesCompanion.insert(
            id: id,
            workoutDayId: workoutDayId,
            exerciseId: exerciseId,
            sortOrder: sortOrder,
            targetSets: targetSets,
            defaultUnilateral: defaultUnilateral,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlannedExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workoutDayId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workoutDayId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutDayId,
                    referencedTable: $$PlannedExercisesTableReferences
                        ._workoutDayIdTable(db),
                    referencedColumn: $$PlannedExercisesTableReferences
                        ._workoutDayIdTable(db)
                        .id,
                  ) as T;
                }
                if (exerciseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.exerciseId,
                    referencedTable:
                        $$PlannedExercisesTableReferences._exerciseIdTable(db),
                    referencedColumn: $$PlannedExercisesTableReferences
                        ._exerciseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlannedExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlannedExercisesTable,
    PlannedExerciseRow,
    $$PlannedExercisesTableFilterComposer,
    $$PlannedExercisesTableOrderingComposer,
    $$PlannedExercisesTableAnnotationComposer,
    $$PlannedExercisesTableCreateCompanionBuilder,
    $$PlannedExercisesTableUpdateCompanionBuilder,
    (PlannedExerciseRow, $$PlannedExercisesTableReferences),
    PlannedExerciseRow,
    PrefetchHooks Function({bool workoutDayId, bool exerciseId})>;
typedef $$WeekPlansTableCreateCompanionBuilder = WeekPlansCompanion Function({
  required String routineId,
  required int version,
  Value<int> rowid,
});
typedef $$WeekPlansTableUpdateCompanionBuilder = WeekPlansCompanion Function({
  Value<String> routineId,
  Value<int> version,
  Value<int> rowid,
});

class $$WeekPlansTableFilterComposer
    extends Composer<_$AppDatabase, $WeekPlansTable> {
  $$WeekPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get routineId => $composableBuilder(
      column: $table.routineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$WeekPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $WeekPlansTable> {
  $$WeekPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get routineId => $composableBuilder(
      column: $table.routineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$WeekPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeekPlansTable> {
  $$WeekPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$WeekPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeekPlansTable,
    WeekPlanRow,
    $$WeekPlansTableFilterComposer,
    $$WeekPlansTableOrderingComposer,
    $$WeekPlansTableAnnotationComposer,
    $$WeekPlansTableCreateCompanionBuilder,
    $$WeekPlansTableUpdateCompanionBuilder,
    (WeekPlanRow, BaseReferences<_$AppDatabase, $WeekPlansTable, WeekPlanRow>),
    WeekPlanRow,
    PrefetchHooks Function()> {
  $$WeekPlansTableTableManager(_$AppDatabase db, $WeekPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> routineId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekPlansCompanion(
            routineId: routineId,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String routineId,
            required int version,
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekPlansCompanion.insert(
            routineId: routineId,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeekPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WeekPlansTable,
    WeekPlanRow,
    $$WeekPlansTableFilterComposer,
    $$WeekPlansTableOrderingComposer,
    $$WeekPlansTableAnnotationComposer,
    $$WeekPlansTableCreateCompanionBuilder,
    $$WeekPlansTableUpdateCompanionBuilder,
    (WeekPlanRow, BaseReferences<_$AppDatabase, $WeekPlansTable, WeekPlanRow>),
    WeekPlanRow,
    PrefetchHooks Function()>;
typedef $$WeekPlanSlotsTableCreateCompanionBuilder = WeekPlanSlotsCompanion
    Function({
  required String routineId,
  required int version,
  required Weekday weekday,
  Value<String?> workoutDayId,
  Value<int> rowid,
});
typedef $$WeekPlanSlotsTableUpdateCompanionBuilder = WeekPlanSlotsCompanion
    Function({
  Value<String> routineId,
  Value<int> version,
  Value<Weekday> weekday,
  Value<String?> workoutDayId,
  Value<int> rowid,
});

class $$WeekPlanSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $WeekPlanSlotsTable> {
  $$WeekPlanSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get routineId => $composableBuilder(
      column: $table.routineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Weekday, Weekday, String> get weekday =>
      $composableBuilder(
          column: $table.weekday,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get workoutDayId => $composableBuilder(
      column: $table.workoutDayId, builder: (column) => ColumnFilters(column));
}

class $$WeekPlanSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeekPlanSlotsTable> {
  $$WeekPlanSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get routineId => $composableBuilder(
      column: $table.routineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workoutDayId => $composableBuilder(
      column: $table.workoutDayId,
      builder: (column) => ColumnOrderings(column));
}

class $$WeekPlanSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeekPlanSlotsTable> {
  $$WeekPlanSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Weekday, String> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get workoutDayId => $composableBuilder(
      column: $table.workoutDayId, builder: (column) => column);
}

class $$WeekPlanSlotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeekPlanSlotsTable,
    WeekPlanSlot,
    $$WeekPlanSlotsTableFilterComposer,
    $$WeekPlanSlotsTableOrderingComposer,
    $$WeekPlanSlotsTableAnnotationComposer,
    $$WeekPlanSlotsTableCreateCompanionBuilder,
    $$WeekPlanSlotsTableUpdateCompanionBuilder,
    (
      WeekPlanSlot,
      BaseReferences<_$AppDatabase, $WeekPlanSlotsTable, WeekPlanSlot>
    ),
    WeekPlanSlot,
    PrefetchHooks Function()> {
  $$WeekPlanSlotsTableTableManager(_$AppDatabase db, $WeekPlanSlotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekPlanSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekPlanSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekPlanSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> routineId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<Weekday> weekday = const Value.absent(),
            Value<String?> workoutDayId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekPlanSlotsCompanion(
            routineId: routineId,
            version: version,
            weekday: weekday,
            workoutDayId: workoutDayId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String routineId,
            required int version,
            required Weekday weekday,
            Value<String?> workoutDayId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekPlanSlotsCompanion.insert(
            routineId: routineId,
            version: version,
            weekday: weekday,
            workoutDayId: workoutDayId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeekPlanSlotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WeekPlanSlotsTable,
    WeekPlanSlot,
    $$WeekPlanSlotsTableFilterComposer,
    $$WeekPlanSlotsTableOrderingComposer,
    $$WeekPlanSlotsTableAnnotationComposer,
    $$WeekPlanSlotsTableCreateCompanionBuilder,
    $$WeekPlanSlotsTableUpdateCompanionBuilder,
    (
      WeekPlanSlot,
      BaseReferences<_$AppDatabase, $WeekPlanSlotsTable, WeekPlanSlot>
    ),
    WeekPlanSlot,
    PrefetchHooks Function()>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required DateTime date,
  Value<String?> workoutDayId,
  Value<int?> routineVersion,
  Value<List<String>> intendedExerciseIds,
  Value<String?> currentExerciseId,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<String?> workoutDayId,
  Value<int?> routineVersion,
  Value<List<String>> intendedExerciseIds,
  Value<String?> currentExerciseId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExerciseRow>>
      _sessionExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sessionExercises,
              aliasName: 'sessions__id__session_exercises__session_id');

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
            $_db, $_db.sessionExercises)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_sessionExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workoutDayId => $composableBuilder(
      column: $table.workoutDayId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get routineVersion => $composableBuilder(
      column: $table.routineVersion,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get intendedExerciseIds => $composableBuilder(
          column: $table.intendedExerciseIds,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get currentExerciseId => $composableBuilder(
      column: $table.currentExerciseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> sessionExercisesRefs(
      Expression<bool> Function($$SessionExercisesTableFilterComposer f) f) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessionExercises,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionExercisesTableFilterComposer(
              $db: $db,
              $table: $db.sessionExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workoutDayId => $composableBuilder(
      column: $table.workoutDayId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get routineVersion => $composableBuilder(
      column: $table.routineVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intendedExerciseIds => $composableBuilder(
      column: $table.intendedExerciseIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentExerciseId => $composableBuilder(
      column: $table.currentExerciseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get workoutDayId => $composableBuilder(
      column: $table.workoutDayId, builder: (column) => column);

  GeneratedColumn<int> get routineVersion => $composableBuilder(
      column: $table.routineVersion, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String>
      get intendedExerciseIds => $composableBuilder(
          column: $table.intendedExerciseIds, builder: (column) => column);

  GeneratedColumn<String> get currentExerciseId => $composableBuilder(
      column: $table.currentExerciseId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  Expression<T> sessionExercisesRefs<T extends Object>(
      Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessionExercises,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.sessionExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    SessionRow,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (SessionRow, $$SessionsTableReferences),
    SessionRow,
    PrefetchHooks Function({bool sessionExercisesRefs})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> workoutDayId = const Value.absent(),
            Value<int?> routineVersion = const Value.absent(),
            Value<List<String>> intendedExerciseIds = const Value.absent(),
            Value<String?> currentExerciseId = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            date: date,
            workoutDayId: workoutDayId,
            routineVersion: routineVersion,
            intendedExerciseIds: intendedExerciseIds,
            currentExerciseId: currentExerciseId,
            startedAt: startedAt,
            endedAt: endedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            Value<String?> workoutDayId = const Value.absent(),
            Value<int?> routineVersion = const Value.absent(),
            Value<List<String>> intendedExerciseIds = const Value.absent(),
            Value<String?> currentExerciseId = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            date: date,
            workoutDayId: workoutDayId,
            routineVersion: routineVersion,
            intendedExerciseIds: intendedExerciseIds,
            currentExerciseId: currentExerciseId,
            startedAt: startedAt,
            endedAt: endedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SessionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sessionExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionExercisesRefs) db.sessionExercises
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionExercisesRefs)
                    await $_getPrefetchedData<SessionRow, $SessionsTable,
                            SessionExerciseRow>(
                        currentTable: table,
                        referencedTable: $$SessionsTableReferences
                            ._sessionExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0)
                                .sessionExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    SessionRow,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (SessionRow, $$SessionsTableReferences),
    SessionRow,
    PrefetchHooks Function({bool sessionExercisesRefs})>;
typedef $$SessionExercisesTableCreateCompanionBuilder
    = SessionExercisesCompanion Function({
  Value<int> id,
  required String sessionId,
  required String exerciseId,
  required int planOrder,
  Value<bool> offPlan,
});
typedef $$SessionExercisesTableUpdateCompanionBuilder
    = SessionExercisesCompanion Function({
  Value<int> id,
  Value<String> sessionId,
  Value<String> exerciseId,
  Value<int> planOrder,
  Value<bool> offPlan,
});

final class $$SessionExercisesTableReferences extends BaseReferences<
    _$AppDatabase, $SessionExercisesTable, SessionExerciseRow> {
  $$SessionExercisesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_exercises__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('session_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSetRow>>
      _workoutSetsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workoutSets,
              aliasName:
                  'session_exercises__id__workout_sets__session_exercise_id');

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets)
        .filter(
            (f) => f.sessionExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get planOrder => $composableBuilder(
      column: $table.planOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get offPlan => $composableBuilder(
      column: $table.offPlan, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableFilterComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> workoutSetsRefs(
      Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.sessionExerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableFilterComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get planOrder => $composableBuilder(
      column: $table.planOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get offPlan => $composableBuilder(
      column: $table.offPlan, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableOrderingComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get planOrder =>
      $composableBuilder(column: $table.planOrder, builder: (column) => column);

  GeneratedColumn<bool> get offPlan =>
      $composableBuilder(column: $table.offPlan, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> workoutSetsRefs<T extends Object>(
      Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.sessionExerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionExercisesTable,
    SessionExerciseRow,
    $$SessionExercisesTableFilterComposer,
    $$SessionExercisesTableOrderingComposer,
    $$SessionExercisesTableAnnotationComposer,
    $$SessionExercisesTableCreateCompanionBuilder,
    $$SessionExercisesTableUpdateCompanionBuilder,
    (SessionExerciseRow, $$SessionExercisesTableReferences),
    SessionExerciseRow,
    PrefetchHooks Function(
        {bool sessionId, bool exerciseId, bool workoutSetsRefs})> {
  $$SessionExercisesTableTableManager(
      _$AppDatabase db, $SessionExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> exerciseId = const Value.absent(),
            Value<int> planOrder = const Value.absent(),
            Value<bool> offPlan = const Value.absent(),
          }) =>
              SessionExercisesCompanion(
            id: id,
            sessionId: sessionId,
            exerciseId: exerciseId,
            planOrder: planOrder,
            offPlan: offPlan,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sessionId,
            required String exerciseId,
            required int planOrder,
            Value<bool> offPlan = const Value.absent(),
          }) =>
              SessionExercisesCompanion.insert(
            id: id,
            sessionId: sessionId,
            exerciseId: exerciseId,
            planOrder: planOrder,
            offPlan: offPlan,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SessionExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {sessionId = false,
              exerciseId = false,
              workoutSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutSetsRefs) db.workoutSets],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$SessionExercisesTableReferences._sessionIdTable(db),
                    referencedColumn: $$SessionExercisesTableReferences
                        ._sessionIdTable(db)
                        .id,
                  ) as T;
                }
                if (exerciseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.exerciseId,
                    referencedTable:
                        $$SessionExercisesTableReferences._exerciseIdTable(db),
                    referencedColumn: $$SessionExercisesTableReferences
                        ._exerciseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutSetsRefs)
                    await $_getPrefetchedData<SessionExerciseRow,
                            $SessionExercisesTable, WorkoutSetRow>(
                        currentTable: table,
                        referencedTable: $$SessionExercisesTableReferences
                            ._workoutSetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionExercisesTableReferences(db, table, p0)
                                .workoutSetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionExerciseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SessionExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionExercisesTable,
    SessionExerciseRow,
    $$SessionExercisesTableFilterComposer,
    $$SessionExercisesTableOrderingComposer,
    $$SessionExercisesTableAnnotationComposer,
    $$SessionExercisesTableCreateCompanionBuilder,
    $$SessionExercisesTableUpdateCompanionBuilder,
    (SessionExerciseRow, $$SessionExercisesTableReferences),
    SessionExerciseRow,
    PrefetchHooks Function(
        {bool sessionId, bool exerciseId, bool workoutSetsRefs})>;
typedef $$WorkoutSetsTableCreateCompanionBuilder = WorkoutSetsCompanion
    Function({
  required String id,
  required int sessionExerciseId,
  required String exerciseId,
  required int seq,
  Value<Execution> execution,
  Value<int?> aggregateReps,
  Value<List<String>> tags,
  Value<String?> tempo,
  Value<DateTime?> startedAt,
  Value<DateTime?> endedAt,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$WorkoutSetsTableUpdateCompanionBuilder = WorkoutSetsCompanion
    Function({
  Value<String> id,
  Value<int> sessionExerciseId,
  Value<String> exerciseId,
  Value<int> seq,
  Value<Execution> execution,
  Value<int?> aggregateReps,
  Value<List<String>> tags,
  Value<String?> tempo,
  Value<DateTime?> startedAt,
  Value<DateTime?> endedAt,
  Value<String?> note,
  Value<int> rowid,
});

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSetRow> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionExercisesTable _sessionExerciseIdTable(_$AppDatabase db) => db
      .sessionExercises
      .createAlias('workout_sets__session_exercise_id__session_exercises__id');

  $$SessionExercisesTableProcessedTableManager get sessionExerciseId {
    final $_column = $_itemColumn<int>('session_exercise_id')!;

    final manager =
        $$SessionExercisesTableTableManager($_db, $_db.sessionExercises)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SetSegmentsTable, List<SetSegmentRow>>
      _setSegmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.setSegments,
              aliasName: 'workout_sets__id__set_segments__workout_set_id');

  $$SetSegmentsTableProcessedTableManager get setSegmentsRefs {
    final manager = $$SetSegmentsTableTableManager($_db, $_db.setSegments)
        .filter(
            (f) => f.workoutSetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_setSegmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq => $composableBuilder(
      column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Execution, Execution, String> get execution =>
      $composableBuilder(
          column: $table.execution,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get aggregateReps => $composableBuilder(
      column: $table.aggregateReps, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get tempo => $composableBuilder(
      column: $table.tempo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$SessionExercisesTableFilterComposer get sessionExerciseId {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionExerciseId,
        referencedTable: $db.sessionExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionExercisesTableFilterComposer(
              $db: $db,
              $table: $db.sessionExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> setSegmentsRefs(
      Expression<bool> Function($$SetSegmentsTableFilterComposer f) f) {
    final $$SetSegmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setSegments,
        getReferencedColumn: (t) => t.workoutSetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetSegmentsTableFilterComposer(
              $db: $db,
              $table: $db.setSegments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq => $composableBuilder(
      column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get execution => $composableBuilder(
      column: $table.execution, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aggregateReps => $composableBuilder(
      column: $table.aggregateReps,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tempo => $composableBuilder(
      column: $table.tempo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$SessionExercisesTableOrderingComposer get sessionExerciseId {
    final $$SessionExercisesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionExerciseId,
        referencedTable: $db.sessionExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionExercisesTableOrderingComposer(
              $db: $db,
              $table: $db.sessionExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Execution, String> get execution =>
      $composableBuilder(column: $table.execution, builder: (column) => column);

  GeneratedColumn<int> get aggregateReps => $composableBuilder(
      column: $table.aggregateReps, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$SessionExercisesTableAnnotationComposer get sessionExerciseId {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionExerciseId,
        referencedTable: $db.sessionExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.sessionExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> setSegmentsRefs<T extends Object>(
      Expression<T> Function($$SetSegmentsTableAnnotationComposer a) f) {
    final $$SetSegmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setSegments,
        getReferencedColumn: (t) => t.workoutSetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetSegmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.setSegments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutSetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSetRow,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSetRow, $$WorkoutSetsTableReferences),
    WorkoutSetRow,
    PrefetchHooks Function({bool sessionExerciseId, bool setSegmentsRefs})> {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> sessionExerciseId = const Value.absent(),
            Value<String> exerciseId = const Value.absent(),
            Value<int> seq = const Value.absent(),
            Value<Execution> execution = const Value.absent(),
            Value<int?> aggregateReps = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String?> tempo = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutSetsCompanion(
            id: id,
            sessionExerciseId: sessionExerciseId,
            exerciseId: exerciseId,
            seq: seq,
            execution: execution,
            aggregateReps: aggregateReps,
            tags: tags,
            tempo: tempo,
            startedAt: startedAt,
            endedAt: endedAt,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int sessionExerciseId,
            required String exerciseId,
            required int seq,
            Value<Execution> execution = const Value.absent(),
            Value<int?> aggregateReps = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String?> tempo = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutSetsCompanion.insert(
            id: id,
            sessionExerciseId: sessionExerciseId,
            exerciseId: exerciseId,
            seq: seq,
            execution: execution,
            aggregateReps: aggregateReps,
            tags: tags,
            tempo: tempo,
            startedAt: startedAt,
            endedAt: endedAt,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkoutSetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {sessionExerciseId = false, setSegmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (setSegmentsRefs) db.setSegments],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionExerciseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionExerciseId,
                    referencedTable: $$WorkoutSetsTableReferences
                        ._sessionExerciseIdTable(db),
                    referencedColumn: $$WorkoutSetsTableReferences
                        ._sessionExerciseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setSegmentsRefs)
                    await $_getPrefetchedData<WorkoutSetRow, $WorkoutSetsTable,
                            SetSegmentRow>(
                        currentTable: table,
                        referencedTable: $$WorkoutSetsTableReferences
                            ._setSegmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutSetsTableReferences(db, table, p0)
                                .setSegmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutSetId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkoutSetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSetRow,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSetRow, $$WorkoutSetsTableReferences),
    WorkoutSetRow,
    PrefetchHooks Function({bool sessionExerciseId, bool setSegmentsRefs})>;
typedef $$SetSegmentsTableCreateCompanionBuilder = SetSegmentsCompanion
    Function({
  Value<int> id,
  required String workoutSetId,
  required int seq,
  Value<double?> loadValue,
  Value<LoadUnit> loadUnit,
  required LoadSource loadSource,
  Value<LoadScope> loadScope,
  Value<int?> reps,
  Value<int?> repsLeft,
  Value<int?> repsRight,
});
typedef $$SetSegmentsTableUpdateCompanionBuilder = SetSegmentsCompanion
    Function({
  Value<int> id,
  Value<String> workoutSetId,
  Value<int> seq,
  Value<double?> loadValue,
  Value<LoadUnit> loadUnit,
  Value<LoadSource> loadSource,
  Value<LoadScope> loadScope,
  Value<int?> reps,
  Value<int?> repsLeft,
  Value<int?> repsRight,
});

final class $$SetSegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $SetSegmentsTable, SetSegmentRow> {
  $$SetSegmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutSetsTable _workoutSetIdTable(_$AppDatabase db) =>
      db.workoutSets
          .createAlias('set_segments__workout_set_id__workout_sets__id');

  $$WorkoutSetsTableProcessedTableManager get workoutSetId {
    final $_column = $_itemColumn<String>('workout_set_id')!;

    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutSetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SetSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SetSegmentsTable> {
  $$SetSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq => $composableBuilder(
      column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get loadValue => $composableBuilder(
      column: $table.loadValue, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<LoadUnit, LoadUnit, String> get loadUnit =>
      $composableBuilder(
          column: $table.loadUnit,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<LoadSource, LoadSource, String>
      get loadSource => $composableBuilder(
          column: $table.loadSource,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<LoadScope, LoadScope, String> get loadScope =>
      $composableBuilder(
          column: $table.loadScope,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repsLeft => $composableBuilder(
      column: $table.repsLeft, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repsRight => $composableBuilder(
      column: $table.repsRight, builder: (column) => ColumnFilters(column));

  $$WorkoutSetsTableFilterComposer get workoutSetId {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutSetId,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableFilterComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SetSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetSegmentsTable> {
  $$SetSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq => $composableBuilder(
      column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get loadValue => $composableBuilder(
      column: $table.loadValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loadUnit => $composableBuilder(
      column: $table.loadUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loadSource => $composableBuilder(
      column: $table.loadSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loadScope => $composableBuilder(
      column: $table.loadScope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repsLeft => $composableBuilder(
      column: $table.repsLeft, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repsRight => $composableBuilder(
      column: $table.repsRight, builder: (column) => ColumnOrderings(column));

  $$WorkoutSetsTableOrderingComposer get workoutSetId {
    final $$WorkoutSetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutSetId,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableOrderingComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SetSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetSegmentsTable> {
  $$SetSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<double> get loadValue =>
      $composableBuilder(column: $table.loadValue, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LoadUnit, String> get loadUnit =>
      $composableBuilder(column: $table.loadUnit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LoadSource, String> get loadSource =>
      $composableBuilder(
          column: $table.loadSource, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LoadScope, String> get loadScope =>
      $composableBuilder(column: $table.loadScope, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get repsLeft =>
      $composableBuilder(column: $table.repsLeft, builder: (column) => column);

  GeneratedColumn<int> get repsRight =>
      $composableBuilder(column: $table.repsRight, builder: (column) => column);

  $$WorkoutSetsTableAnnotationComposer get workoutSetId {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutSetId,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SetSegmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SetSegmentsTable,
    SetSegmentRow,
    $$SetSegmentsTableFilterComposer,
    $$SetSegmentsTableOrderingComposer,
    $$SetSegmentsTableAnnotationComposer,
    $$SetSegmentsTableCreateCompanionBuilder,
    $$SetSegmentsTableUpdateCompanionBuilder,
    (SetSegmentRow, $$SetSegmentsTableReferences),
    SetSegmentRow,
    PrefetchHooks Function({bool workoutSetId})> {
  $$SetSegmentsTableTableManager(_$AppDatabase db, $SetSegmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> workoutSetId = const Value.absent(),
            Value<int> seq = const Value.absent(),
            Value<double?> loadValue = const Value.absent(),
            Value<LoadUnit> loadUnit = const Value.absent(),
            Value<LoadSource> loadSource = const Value.absent(),
            Value<LoadScope> loadScope = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<int?> repsLeft = const Value.absent(),
            Value<int?> repsRight = const Value.absent(),
          }) =>
              SetSegmentsCompanion(
            id: id,
            workoutSetId: workoutSetId,
            seq: seq,
            loadValue: loadValue,
            loadUnit: loadUnit,
            loadSource: loadSource,
            loadScope: loadScope,
            reps: reps,
            repsLeft: repsLeft,
            repsRight: repsRight,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String workoutSetId,
            required int seq,
            Value<double?> loadValue = const Value.absent(),
            Value<LoadUnit> loadUnit = const Value.absent(),
            required LoadSource loadSource,
            Value<LoadScope> loadScope = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<int?> repsLeft = const Value.absent(),
            Value<int?> repsRight = const Value.absent(),
          }) =>
              SetSegmentsCompanion.insert(
            id: id,
            workoutSetId: workoutSetId,
            seq: seq,
            loadValue: loadValue,
            loadUnit: loadUnit,
            loadSource: loadSource,
            loadScope: loadScope,
            reps: reps,
            repsLeft: repsLeft,
            repsRight: repsRight,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SetSegmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workoutSetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workoutSetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutSetId,
                    referencedTable:
                        $$SetSegmentsTableReferences._workoutSetIdTable(db),
                    referencedColumn:
                        $$SetSegmentsTableReferences._workoutSetIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SetSegmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SetSegmentsTable,
    SetSegmentRow,
    $$SetSegmentsTableFilterComposer,
    $$SetSegmentsTableOrderingComposer,
    $$SetSegmentsTableAnnotationComposer,
    $$SetSegmentsTableCreateCompanionBuilder,
    $$SetSegmentsTableUpdateCompanionBuilder,
    (SetSegmentRow, $$SetSegmentsTableReferences),
    SetSegmentRow,
    PrefetchHooks Function({bool workoutSetId})>;
typedef $$BodyweightEntriesTableCreateCompanionBuilder
    = BodyweightEntriesCompanion Function({
  Value<int> id,
  required DateTime date,
  required double kg,
});
typedef $$BodyweightEntriesTableUpdateCompanionBuilder
    = BodyweightEntriesCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<double> kg,
});

class $$BodyweightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BodyweightEntriesTable> {
  $$BodyweightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kg => $composableBuilder(
      column: $table.kg, builder: (column) => ColumnFilters(column));
}

class $$BodyweightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyweightEntriesTable> {
  $$BodyweightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kg => $composableBuilder(
      column: $table.kg, builder: (column) => ColumnOrderings(column));
}

class $$BodyweightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyweightEntriesTable> {
  $$BodyweightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => column);
}

class $$BodyweightEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BodyweightEntriesTable,
    BodyweightEntryRow,
    $$BodyweightEntriesTableFilterComposer,
    $$BodyweightEntriesTableOrderingComposer,
    $$BodyweightEntriesTableAnnotationComposer,
    $$BodyweightEntriesTableCreateCompanionBuilder,
    $$BodyweightEntriesTableUpdateCompanionBuilder,
    (
      BodyweightEntryRow,
      BaseReferences<_$AppDatabase, $BodyweightEntriesTable, BodyweightEntryRow>
    ),
    BodyweightEntryRow,
    PrefetchHooks Function()> {
  $$BodyweightEntriesTableTableManager(
      _$AppDatabase db, $BodyweightEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyweightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyweightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyweightEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> kg = const Value.absent(),
          }) =>
              BodyweightEntriesCompanion(
            id: id,
            date: date,
            kg: kg,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required double kg,
          }) =>
              BodyweightEntriesCompanion.insert(
            id: id,
            date: date,
            kg: kg,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BodyweightEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BodyweightEntriesTable,
    BodyweightEntryRow,
    $$BodyweightEntriesTableFilterComposer,
    $$BodyweightEntriesTableOrderingComposer,
    $$BodyweightEntriesTableAnnotationComposer,
    $$BodyweightEntriesTableCreateCompanionBuilder,
    $$BodyweightEntriesTableUpdateCompanionBuilder,
    (
      BodyweightEntryRow,
      BaseReferences<_$AppDatabase, $BodyweightEntriesTable, BodyweightEntryRow>
    ),
    BodyweightEntryRow,
    PrefetchHooks Function()>;
typedef $$SeedMetaTableCreateCompanionBuilder = SeedMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SeedMetaTableUpdateCompanionBuilder = SeedMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SeedMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SeedMetaTable> {
  $$SeedMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SeedMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SeedMetaTable> {
  $$SeedMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SeedMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeedMetaTable> {
  $$SeedMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SeedMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SeedMetaTable,
    SeedMetaData,
    $$SeedMetaTableFilterComposer,
    $$SeedMetaTableOrderingComposer,
    $$SeedMetaTableAnnotationComposer,
    $$SeedMetaTableCreateCompanionBuilder,
    $$SeedMetaTableUpdateCompanionBuilder,
    (SeedMetaData, BaseReferences<_$AppDatabase, $SeedMetaTable, SeedMetaData>),
    SeedMetaData,
    PrefetchHooks Function()> {
  $$SeedMetaTableTableManager(_$AppDatabase db, $SeedMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeedMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeedMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeedMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SeedMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SeedMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SeedMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SeedMetaTable,
    SeedMetaData,
    $$SeedMetaTableFilterComposer,
    $$SeedMetaTableOrderingComposer,
    $$SeedMetaTableAnnotationComposer,
    $$SeedMetaTableCreateCompanionBuilder,
    $$SeedMetaTableUpdateCompanionBuilder,
    (SeedMetaData, BaseReferences<_$AppDatabase, $SeedMetaTable, SeedMetaData>),
    SeedMetaData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$WorkoutDaysTableTableManager get workoutDays =>
      $$WorkoutDaysTableTableManager(_db, _db.workoutDays);
  $$PlannedExercisesTableTableManager get plannedExercises =>
      $$PlannedExercisesTableTableManager(_db, _db.plannedExercises);
  $$WeekPlansTableTableManager get weekPlans =>
      $$WeekPlansTableTableManager(_db, _db.weekPlans);
  $$WeekPlanSlotsTableTableManager get weekPlanSlots =>
      $$WeekPlanSlotsTableTableManager(_db, _db.weekPlanSlots);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(_db, _db.sessionExercises);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$SetSegmentsTableTableManager get setSegments =>
      $$SetSegmentsTableTableManager(_db, _db.setSegments);
  $$BodyweightEntriesTableTableManager get bodyweightEntries =>
      $$BodyweightEntriesTableTableManager(_db, _db.bodyweightEntries);
  $$SeedMetaTableTableManager get seedMeta =>
      $$SeedMetaTableTableManager(_db, _db.seedMeta);
}
