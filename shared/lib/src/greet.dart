import 'package:json_annotation/json_annotation.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

part 'greet.g.dart';

/// Request data for the greetTyped callable function.
@JsonSerializable(createJsonSchema: true)
class GreetRequest {
  final String name;

  GreetRequest({required this.name});

  factory GreetRequest.fromJson(Map<String, dynamic> json) =>
      _$GreetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GreetRequestToJson(this);

  static const jsonSchema = _$GreetRequestJsonSchema;

  static Future<List<ValidationError>> validate(Map<String, dynamic> data) =>
      _validate(jsonSchema, data);
}

/// Response data for the greetTyped callable function.
@JsonSerializable(createJsonSchema: true)
class GreetResponse {
  final String message;

  GreetResponse({required this.message});

  factory GreetResponse.fromJson(Map<String, dynamic> json) =>
      _$GreetResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GreetResponseToJson(this);

  static const jsonSchema = _$GreetResponseJsonSchema;

  static Future<List<ValidationError>> validate(Map<String, dynamic> data) =>
      _validate(jsonSchema, data);
}

Future<List<ValidationError>> _validate(
  Map<String, dynamic> schema,
  Map<String, dynamic> data,
) async {
  final requestSchema = S.fromMap(schema);
  final validationErrors = await requestSchema.validate(data);
  return validationErrors;
}
