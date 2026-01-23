/// Request data for the greetTyped callable function.
class GreetRequest {
  GreetRequest({required this.name});

  factory GreetRequest.fromJson(Map<String, dynamic> json) {
    return GreetRequest(name: json['name'] as String? ?? 'World');
  }

  final String name;

  Map<String, dynamic> toJson() => {'name': name};
}

/// Response data for the greetTyped callable function.
class GreetResponse {
  GreetResponse({required this.message});

  final String message;

  Map<String, dynamic> toJson() => {'message': message};
}
