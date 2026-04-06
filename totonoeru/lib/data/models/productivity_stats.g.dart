// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'productivity_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProductivityStatsCollection on Isar {
  IsarCollection<ProductivityStats> get productivityStats => this.collection();
}

const ProductivityStatsSchema = CollectionSchema(
  name: r'ProductivityStats',
  id: -4216418202499789300,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'focusMinutes': PropertySchema(
      id: 1,
      name: r'focusMinutes',
      type: IsarType.long,
    ),
    r'isToday': PropertySchema(
      id: 2,
      name: r'isToday',
      type: IsarType.bool,
    ),
    r'streakDay': PropertySchema(
      id: 3,
      name: r'streakDay',
      type: IsarType.long,
    ),
    r'tasksCompleted': PropertySchema(
      id: 4,
      name: r'tasksCompleted',
      type: IsarType.long,
    ),
    r'tasksCreated': PropertySchema(
      id: 5,
      name: r'tasksCreated',
      type: IsarType.long,
    )
  },
  estimateSize: _productivityStatsEstimateSize,
  serialize: _productivityStatsSerialize,
  deserialize: _productivityStatsDeserialize,
  deserializeProp: _productivityStatsDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _productivityStatsGetId,
  getLinks: _productivityStatsGetLinks,
  attach: _productivityStatsAttach,
  version: '3.1.0',
);

int _productivityStatsEstimateSize(
  ProductivityStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _productivityStatsSerialize(
  ProductivityStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeLong(offsets[1], object.focusMinutes);
  writer.writeBool(offsets[2], object.isToday);
  writer.writeLong(offsets[3], object.streakDay);
  writer.writeLong(offsets[4], object.tasksCompleted);
  writer.writeLong(offsets[5], object.tasksCreated);
}

ProductivityStats _productivityStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProductivityStats();
  object.date = reader.readDateTime(offsets[0]);
  object.focusMinutes = reader.readLong(offsets[1]);
  object.id = id;
  object.streakDay = reader.readLong(offsets[3]);
  object.tasksCompleted = reader.readLong(offsets[4]);
  object.tasksCreated = reader.readLong(offsets[5]);
  return object;
}

P _productivityStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _productivityStatsGetId(ProductivityStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _productivityStatsGetLinks(
    ProductivityStats object) {
  return [];
}

void _productivityStatsAttach(
    IsarCollection<dynamic> col, Id id, ProductivityStats object) {
  object.id = id;
}

extension ProductivityStatsByIndex on IsarCollection<ProductivityStats> {
  Future<ProductivityStats?> getByDate(DateTime date) {
    return getByIndex(r'date', [date]);
  }

  ProductivityStats? getByDateSync(DateTime date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(DateTime date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(DateTime date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<ProductivityStats?>> getAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<ProductivityStats?> getAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(ProductivityStats object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(ProductivityStats object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<ProductivityStats> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<ProductivityStats> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension ProductivityStatsQueryWhereSort
    on QueryBuilder<ProductivityStats, ProductivityStats, QWhere> {
  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension ProductivityStatsQueryWhere
    on QueryBuilder<ProductivityStats, ProductivityStats, QWhereClause> {
  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterWhereClause>
      dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProductivityStatsQueryFilter
    on QueryBuilder<ProductivityStats, ProductivityStats, QFilterCondition> {
  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      focusMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      focusMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'focusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      focusMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'focusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      focusMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'focusMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      isTodayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isToday',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      streakDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakDay',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      streakDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streakDay',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      streakDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streakDay',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      streakDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streakDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      tasksCompletedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tasksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      tasksCompletedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tasksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      tasksCompletedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tasksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      tasksCompletedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tasksCompleted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      tasksCreatedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tasksCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      tasksCreatedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tasksCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      tasksCreatedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tasksCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterFilterCondition>
      tasksCreatedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tasksCreated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProductivityStatsQueryObject
    on QueryBuilder<ProductivityStats, ProductivityStats, QFilterCondition> {}

extension ProductivityStatsQueryLinks
    on QueryBuilder<ProductivityStats, ProductivityStats, QFilterCondition> {}

extension ProductivityStatsQuerySortBy
    on QueryBuilder<ProductivityStats, ProductivityStats, QSortBy> {
  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusMinutes', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusMinutes', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByIsToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isToday', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByIsTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isToday', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByStreakDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDay', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByStreakDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDay', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByTasksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByTasksCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCreated', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      sortByTasksCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCreated', Sort.desc);
    });
  }
}

extension ProductivityStatsQuerySortThenBy
    on QueryBuilder<ProductivityStats, ProductivityStats, QSortThenBy> {
  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusMinutes', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusMinutes', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByIsToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isToday', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByIsTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isToday', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByStreakDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDay', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByStreakDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDay', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByTasksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.desc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByTasksCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCreated', Sort.asc);
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QAfterSortBy>
      thenByTasksCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCreated', Sort.desc);
    });
  }
}

extension ProductivityStatsQueryWhereDistinct
    on QueryBuilder<ProductivityStats, ProductivityStats, QDistinct> {
  QueryBuilder<ProductivityStats, ProductivityStats, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QDistinct>
      distinctByFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'focusMinutes');
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QDistinct>
      distinctByIsToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isToday');
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QDistinct>
      distinctByStreakDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakDay');
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QDistinct>
      distinctByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasksCompleted');
    });
  }

  QueryBuilder<ProductivityStats, ProductivityStats, QDistinct>
      distinctByTasksCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasksCreated');
    });
  }
}

extension ProductivityStatsQueryProperty
    on QueryBuilder<ProductivityStats, ProductivityStats, QQueryProperty> {
  QueryBuilder<ProductivityStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProductivityStats, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<ProductivityStats, int, QQueryOperations>
      focusMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'focusMinutes');
    });
  }

  QueryBuilder<ProductivityStats, bool, QQueryOperations> isTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isToday');
    });
  }

  QueryBuilder<ProductivityStats, int, QQueryOperations> streakDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakDay');
    });
  }

  QueryBuilder<ProductivityStats, int, QQueryOperations>
      tasksCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasksCompleted');
    });
  }

  QueryBuilder<ProductivityStats, int, QQueryOperations>
      tasksCreatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasksCreated');
    });
  }
}
