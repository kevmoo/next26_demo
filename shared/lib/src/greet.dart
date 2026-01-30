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

  static final jsonSchema = S.fromMap(_$GreetRequestJsonSchema);

  static Future<List<ValidationError>> validate(Map<String, dynamic> data) =>
      jsonSchema.validate(data);
}

/// Response data for the greetTyped callable function.
@JsonSerializable(createJsonSchema: true)
class GreetResponse {
  final String message;

  GreetResponse({required this.message});

  factory GreetResponse.fromJson(Map<String, dynamic> json) =>
      _$GreetResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GreetResponseToJson(this);

  static final jsonSchema = S.fromMap(_$GreetResponseJsonSchema);

  static Future<List<ValidationError>> validate(Map<String, dynamic> data) =>
      jsonSchema.validate(data);
}
