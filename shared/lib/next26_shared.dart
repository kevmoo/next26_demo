/// Request data for the greetTyped callable function.
class GreetRequest {
  GreetRequest({required this.name});

  factory GreetRequest.fromJson(Map<String, dynamic> json) =>
      GreetRequest(name: json['name'] as String);

  final String name;

  Map<String, dynamic> toJson() => {'name': name};
}

/// Response data for the greetTyped callable function.
class GreetResponse {
  GreetResponse({required this.message});

  factory GreetResponse.fromJson(Map<String, dynamic> json) =>
      GreetResponse(message: json['message'] as String);

  final String message;

  Map<String, dynamic> toJson() => {'message': message};
}
