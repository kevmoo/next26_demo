// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'greet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GreetRequest _$GreetRequestFromJson(Map<String, dynamic> json) =>
    GreetRequest(name: json['name'] as String);

Map<String, dynamic> _$GreetRequestToJson(GreetRequest instance) =>
    <String, dynamic>{'name': instance.name};

const _$GreetRequestJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'name': {'type': 'string'},
  },
  'required': ['name'],
};

GreetResponse _$GreetResponseFromJson(Map<String, dynamic> json) =>
    GreetResponse(message: json['message'] as String);

Map<String, dynamic> _$GreetResponseToJson(GreetResponse instance) =>
    <String, dynamic>{'message': instance.message};

const _$GreetResponseJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'message': {'type': 'string'},
  },
  'required': ['message'],
};
