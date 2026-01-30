import 'package:json_annotation/json_annotation.dart';

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
}
