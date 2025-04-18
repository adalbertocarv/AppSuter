// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ponto_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPontoModelCollection on Isar {
  IsarCollection<PontoModel> get pontoModels => this.collection();
}

const PontoModelSchema = CollectionSchema(
  name: r'PontoModel',
  id: -4391602801693878120,
  properties: {
    r'abrigos': PropertySchema(
      id: 0,
      name: r'abrigos',
      type: IsarType.objectList,
      target: r'AbrigoModel',
    ),
    r'baia': PropertySchema(
      id: 1,
      name: r'baia',
      type: IsarType.bool,
    ),
    r'dataVisita': PropertySchema(
      id: 2,
      name: r'dataVisita',
      type: IsarType.string,
    ),
    r'endereco': PropertySchema(
      id: 3,
      name: r'endereco',
      type: IsarType.string,
    ),
    r'idUsuario': PropertySchema(
      id: 4,
      name: r'idUsuario',
      type: IsarType.long,
    ),
    r'imagensPatologiaPaths': PropertySchema(
      id: 5,
      name: r'imagensPatologiaPaths',
      type: IsarType.stringList,
    ),
    r'imgBlobPaths': PropertySchema(
      id: 6,
      name: r'imgBlobPaths',
      type: IsarType.stringList,
    ),
    r'latitude': PropertySchema(
      id: 7,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'latitudeInterpolado': PropertySchema(
      id: 8,
      name: r'latitudeInterpolado',
      type: IsarType.double,
    ),
    r'linhaEscolares': PropertySchema(
      id: 9,
      name: r'linhaEscolares',
      type: IsarType.bool,
    ),
    r'linhaStpc': PropertySchema(
      id: 10,
      name: r'linhaStpc',
      type: IsarType.bool,
    ),
    r'longitude': PropertySchema(
      id: 11,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'longitudeInterpolado': PropertySchema(
      id: 12,
      name: r'longitudeInterpolado',
      type: IsarType.double,
    ),
    r'patologia': PropertySchema(
      id: 13,
      name: r'patologia',
      type: IsarType.bool,
    ),
    r'pisoTatil': PropertySchema(
      id: 14,
      name: r'pisoTatil',
      type: IsarType.bool,
    ),
    r'rampa': PropertySchema(
      id: 15,
      name: r'rampa',
      type: IsarType.bool,
    )
  },
  estimateSize: _pontoModelEstimateSize,
  serialize: _pontoModelSerialize,
  deserialize: _pontoModelDeserialize,
  deserializeProp: _pontoModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'AbrigoModel': AbrigoModelSchema},
  getId: _pontoModelGetId,
  getLinks: _pontoModelGetLinks,
  attach: _pontoModelAttach,
  version: '3.1.0+1',
);

int _pontoModelEstimateSize(
  PontoModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.abrigos.length * 3;
  {
    final offsets = allOffsets[AbrigoModel]!;
    for (var i = 0; i < object.abrigos.length; i++) {
      final value = object.abrigos[i];
      bytesCount += AbrigoModelSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.dataVisita.length * 3;
  bytesCount += 3 + object.endereco.length * 3;
  bytesCount += 3 + object.imagensPatologiaPaths.length * 3;
  {
    for (var i = 0; i < object.imagensPatologiaPaths.length; i++) {
      final value = object.imagensPatologiaPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.imgBlobPaths.length * 3;
  {
    for (var i = 0; i < object.imgBlobPaths.length; i++) {
      final value = object.imgBlobPaths[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _pontoModelSerialize(
  PontoModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<AbrigoModel>(
    offsets[0],
    allOffsets,
    AbrigoModelSchema.serialize,
    object.abrigos,
  );
  writer.writeBool(offsets[1], object.baia);
  writer.writeString(offsets[2], object.dataVisita);
  writer.writeString(offsets[3], object.endereco);
  writer.writeLong(offsets[4], object.idUsuario);
  writer.writeStringList(offsets[5], object.imagensPatologiaPaths);
  writer.writeStringList(offsets[6], object.imgBlobPaths);
  writer.writeDouble(offsets[7], object.latitude);
  writer.writeDouble(offsets[8], object.latitudeInterpolado);
  writer.writeBool(offsets[9], object.linhaEscolares);
  writer.writeBool(offsets[10], object.linhaStpc);
  writer.writeDouble(offsets[11], object.longitude);
  writer.writeDouble(offsets[12], object.longitudeInterpolado);
  writer.writeBool(offsets[13], object.patologia);
  writer.writeBool(offsets[14], object.pisoTatil);
  writer.writeBool(offsets[15], object.rampa);
}

PontoModel _pontoModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PontoModel();
  object.abrigos = reader.readObjectList<AbrigoModel>(
        offsets[0],
        AbrigoModelSchema.deserialize,
        allOffsets,
        AbrigoModel(),
      ) ??
      [];
  object.baia = reader.readBool(offsets[1]);
  object.dataVisita = reader.readString(offsets[2]);
  object.endereco = reader.readString(offsets[3]);
  object.id = id;
  object.idUsuario = reader.readLong(offsets[4]);
  object.imagensPatologiaPaths = reader.readStringList(offsets[5]) ?? [];
  object.imgBlobPaths = reader.readStringList(offsets[6]) ?? [];
  object.latitude = reader.readDouble(offsets[7]);
  object.latitudeInterpolado = reader.readDouble(offsets[8]);
  object.linhaEscolares = reader.readBool(offsets[9]);
  object.linhaStpc = reader.readBool(offsets[10]);
  object.longitude = reader.readDouble(offsets[11]);
  object.longitudeInterpolado = reader.readDouble(offsets[12]);
  object.patologia = reader.readBool(offsets[13]);
  object.pisoTatil = reader.readBool(offsets[14]);
  object.rampa = reader.readBool(offsets[15]);
  return object;
}

P _pontoModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<AbrigoModel>(
            offset,
            AbrigoModelSchema.deserialize,
            allOffsets,
            AbrigoModel(),
          ) ??
          []) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pontoModelGetId(PontoModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pontoModelGetLinks(PontoModel object) {
  return [];
}

void _pontoModelAttach(IsarCollection<dynamic> col, Id id, PontoModel object) {
  object.id = id;
}

extension PontoModelQueryWhereSort
    on QueryBuilder<PontoModel, PontoModel, QWhere> {
  QueryBuilder<PontoModel, PontoModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PontoModelQueryWhere
    on QueryBuilder<PontoModel, PontoModel, QWhereClause> {
  QueryBuilder<PontoModel, PontoModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PontoModel, PontoModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterWhereClause> idBetween(
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
}

extension PontoModelQueryFilter
    on QueryBuilder<PontoModel, PontoModel, QFilterCondition> {
  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      abrigosLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'abrigos',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> abrigosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'abrigos',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      abrigosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'abrigos',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      abrigosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'abrigos',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      abrigosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'abrigos',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      abrigosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'abrigos',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> baiaEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baia',
        value: value,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> dataVisitaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataVisita',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      dataVisitaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataVisita',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      dataVisitaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataVisita',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> dataVisitaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataVisita',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      dataVisitaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dataVisita',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      dataVisitaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dataVisita',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      dataVisitaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataVisita',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> dataVisitaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataVisita',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      dataVisitaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataVisita',
        value: '',
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      dataVisitaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataVisita',
        value: '',
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> enderecoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endereco',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      enderecoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endereco',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> enderecoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endereco',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> enderecoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endereco',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      enderecoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'endereco',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> enderecoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'endereco',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> enderecoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'endereco',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> enderecoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'endereco',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      enderecoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endereco',
        value: '',
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      enderecoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'endereco',
        value: '',
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> idUsuarioEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idUsuario',
        value: value,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      idUsuarioGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idUsuario',
        value: value,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> idUsuarioLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idUsuario',
        value: value,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> idUsuarioBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idUsuario',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagensPatologiaPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagensPatologiaPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagensPatologiaPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagensPatologiaPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imagensPatologiaPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imgBlobPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imgBlobPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imgBlobPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imgBlobPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      imgBlobPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      latitudeInterpoladoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitudeInterpolado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      latitudeInterpoladoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitudeInterpolado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      latitudeInterpoladoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitudeInterpolado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      latitudeInterpoladoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitudeInterpolado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      linhaEscolaresEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linhaEscolares',
        value: value,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> linhaStpcEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linhaStpc',
        value: value,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      longitudeInterpoladoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitudeInterpolado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      longitudeInterpoladoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitudeInterpolado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      longitudeInterpoladoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitudeInterpolado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition>
      longitudeInterpoladoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitudeInterpolado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> patologiaEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patologia',
        value: value,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> pisoTatilEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pisoTatil',
        value: value,
      ));
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> rampaEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rampa',
        value: value,
      ));
    });
  }
}

extension PontoModelQueryObject
    on QueryBuilder<PontoModel, PontoModel, QFilterCondition> {
  QueryBuilder<PontoModel, PontoModel, QAfterFilterCondition> abrigosElement(
      FilterQuery<AbrigoModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'abrigos');
    });
  }
}

extension PontoModelQueryLinks
    on QueryBuilder<PontoModel, PontoModel, QFilterCondition> {}

extension PontoModelQuerySortBy
    on QueryBuilder<PontoModel, PontoModel, QSortBy> {
  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByBaia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baia', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByBaiaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baia', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByDataVisita() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVisita', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByDataVisitaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVisita', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByEndereco() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endereco', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByEnderecoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endereco', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByIdUsuario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idUsuario', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByIdUsuarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idUsuario', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      sortByLatitudeInterpolado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitudeInterpolado', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      sortByLatitudeInterpoladoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitudeInterpolado', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByLinhaEscolares() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linhaEscolares', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      sortByLinhaEscolaresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linhaEscolares', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByLinhaStpc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linhaStpc', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByLinhaStpcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linhaStpc', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      sortByLongitudeInterpolado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitudeInterpolado', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      sortByLongitudeInterpoladoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitudeInterpolado', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByPatologia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patologia', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByPatologiaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patologia', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByPisoTatil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pisoTatil', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByPisoTatilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pisoTatil', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByRampa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rampa', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> sortByRampaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rampa', Sort.desc);
    });
  }
}

extension PontoModelQuerySortThenBy
    on QueryBuilder<PontoModel, PontoModel, QSortThenBy> {
  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByBaia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baia', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByBaiaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baia', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByDataVisita() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVisita', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByDataVisitaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataVisita', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByEndereco() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endereco', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByEnderecoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endereco', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByIdUsuario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idUsuario', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByIdUsuarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idUsuario', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      thenByLatitudeInterpolado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitudeInterpolado', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      thenByLatitudeInterpoladoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitudeInterpolado', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByLinhaEscolares() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linhaEscolares', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      thenByLinhaEscolaresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linhaEscolares', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByLinhaStpc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linhaStpc', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByLinhaStpcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linhaStpc', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      thenByLongitudeInterpolado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitudeInterpolado', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy>
      thenByLongitudeInterpoladoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitudeInterpolado', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByPatologia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patologia', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByPatologiaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patologia', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByPisoTatil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pisoTatil', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByPisoTatilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pisoTatil', Sort.desc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByRampa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rampa', Sort.asc);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QAfterSortBy> thenByRampaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rampa', Sort.desc);
    });
  }
}

extension PontoModelQueryWhereDistinct
    on QueryBuilder<PontoModel, PontoModel, QDistinct> {
  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByBaia() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baia');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByDataVisita(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataVisita', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByEndereco(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endereco', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByIdUsuario() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idUsuario');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct>
      distinctByImagensPatologiaPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagensPatologiaPaths');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByImgBlobPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imgBlobPaths');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct>
      distinctByLatitudeInterpolado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitudeInterpolado');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByLinhaEscolares() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linhaEscolares');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByLinhaStpc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linhaStpc');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct>
      distinctByLongitudeInterpolado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitudeInterpolado');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByPatologia() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'patologia');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByPisoTatil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pisoTatil');
    });
  }

  QueryBuilder<PontoModel, PontoModel, QDistinct> distinctByRampa() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rampa');
    });
  }
}

extension PontoModelQueryProperty
    on QueryBuilder<PontoModel, PontoModel, QQueryProperty> {
  QueryBuilder<PontoModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PontoModel, List<AbrigoModel>, QQueryOperations>
      abrigosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'abrigos');
    });
  }

  QueryBuilder<PontoModel, bool, QQueryOperations> baiaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baia');
    });
  }

  QueryBuilder<PontoModel, String, QQueryOperations> dataVisitaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataVisita');
    });
  }

  QueryBuilder<PontoModel, String, QQueryOperations> enderecoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endereco');
    });
  }

  QueryBuilder<PontoModel, int, QQueryOperations> idUsuarioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idUsuario');
    });
  }

  QueryBuilder<PontoModel, List<String>, QQueryOperations>
      imagensPatologiaPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagensPatologiaPaths');
    });
  }

  QueryBuilder<PontoModel, List<String>, QQueryOperations>
      imgBlobPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imgBlobPaths');
    });
  }

  QueryBuilder<PontoModel, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<PontoModel, double, QQueryOperations>
      latitudeInterpoladoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitudeInterpolado');
    });
  }

  QueryBuilder<PontoModel, bool, QQueryOperations> linhaEscolaresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linhaEscolares');
    });
  }

  QueryBuilder<PontoModel, bool, QQueryOperations> linhaStpcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linhaStpc');
    });
  }

  QueryBuilder<PontoModel, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<PontoModel, double, QQueryOperations>
      longitudeInterpoladoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitudeInterpolado');
    });
  }

  QueryBuilder<PontoModel, bool, QQueryOperations> patologiaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'patologia');
    });
  }

  QueryBuilder<PontoModel, bool, QQueryOperations> pisoTatilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pisoTatil');
    });
  }

  QueryBuilder<PontoModel, bool, QQueryOperations> rampaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rampa');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const AbrigoModelSchema = Schema(
  name: r'AbrigoModel',
  id: 7271285699875384391,
  properties: {
    r'idTipoAbrigo': PropertySchema(
      id: 0,
      name: r'idTipoAbrigo',
      type: IsarType.long,
    ),
    r'imagensPatologiaPaths': PropertySchema(
      id: 1,
      name: r'imagensPatologiaPaths',
      type: IsarType.stringList,
    ),
    r'imgBlobPaths': PropertySchema(
      id: 2,
      name: r'imgBlobPaths',
      type: IsarType.stringList,
    ),
    r'temPatologia': PropertySchema(
      id: 3,
      name: r'temPatologia',
      type: IsarType.bool,
    )
  },
  estimateSize: _abrigoModelEstimateSize,
  serialize: _abrigoModelSerialize,
  deserialize: _abrigoModelDeserialize,
  deserializeProp: _abrigoModelDeserializeProp,
);

int _abrigoModelEstimateSize(
  AbrigoModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.imagensPatologiaPaths.length * 3;
  {
    for (var i = 0; i < object.imagensPatologiaPaths.length; i++) {
      final value = object.imagensPatologiaPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.imgBlobPaths.length * 3;
  {
    for (var i = 0; i < object.imgBlobPaths.length; i++) {
      final value = object.imgBlobPaths[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _abrigoModelSerialize(
  AbrigoModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.idTipoAbrigo);
  writer.writeStringList(offsets[1], object.imagensPatologiaPaths);
  writer.writeStringList(offsets[2], object.imgBlobPaths);
  writer.writeBool(offsets[3], object.temPatologia);
}

AbrigoModel _abrigoModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AbrigoModel();
  object.idTipoAbrigo = reader.readLongOrNull(offsets[0]);
  object.imagensPatologiaPaths = reader.readStringList(offsets[1]) ?? [];
  object.imgBlobPaths = reader.readStringList(offsets[2]) ?? [];
  object.temPatologia = reader.readBool(offsets[3]);
  return object;
}

P _abrigoModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension AbrigoModelQueryFilter
    on QueryBuilder<AbrigoModel, AbrigoModel, QFilterCondition> {
  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      idTipoAbrigoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idTipoAbrigo',
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      idTipoAbrigoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idTipoAbrigo',
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      idTipoAbrigoEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idTipoAbrigo',
        value: value,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      idTipoAbrigoGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idTipoAbrigo',
        value: value,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      idTipoAbrigoLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idTipoAbrigo',
        value: value,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      idTipoAbrigoBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idTipoAbrigo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagensPatologiaPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagensPatologiaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagensPatologiaPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagensPatologiaPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagensPatologiaPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imagensPatologiaPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagensPatologiaPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imgBlobPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imgBlobPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imgBlobPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imgBlobPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imgBlobPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      imgBlobPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imgBlobPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AbrigoModel, AbrigoModel, QAfterFilterCondition>
      temPatologiaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temPatologia',
        value: value,
      ));
    });
  }
}

extension AbrigoModelQueryObject
    on QueryBuilder<AbrigoModel, AbrigoModel, QFilterCondition> {}
