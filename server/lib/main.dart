import 'package:firebase_functions/firebase_functions.dart';

void main(List<String> args) async {
  await fireUp(args, (firebase) {
    // =========================================================================
    // HTTPS onRequest Functions
    // =========================================================================

    // HTTPS onRequest example - using parameterized configuration
    firebase.https.onRequest(
      name: 'helloWorld',
      // ignore: non_const_argument_for_const_parameter
      (request) async {
        // Access parameter value at runtime
        return Response.ok('hello!');
      },
    );

    // =========================================================================
    // HTTPS Callable Functions (onCall / onCallWithData)
    // =========================================================================

    // Basic callable function - untyped data
    firebase.https.onCall(name: 'greet', (request, response) async {
      final data = request.data as Map<String, dynamic>?;
      final name = data?['name'] ?? 'World';
      return CallableResult({'message': 'Hello, $name!'});
    });

    // Callable function with typed data using fromJson
    firebase.https.onCallWithData<GreetRequest, GreetResponse>(
      name: 'greetTyped',
      fromJson: GreetRequest.fromJson,
      (request, response) async {
        return GreetResponse(message: 'Hello, ${request.data.name}!');
      },
    );

    // Callable function demonstrating error handling
    firebase.https.onCall(name: 'divide', (request, response) async {
      final data = request.data as Map<String, dynamic>?;
      final a = (data?['a'] as num?)?.toDouble();
      final b = (data?['b'] as num?)?.toDouble();

      if (a == null || b == null) {
        throw InvalidArgumentError('Both "a" and "b" are required');
      }

      if (b == 0) {
        throw FailedPreconditionError('Cannot divide by zero');
      }

      return CallableResult({'result': a / b});
    });

    // Callable function with streaming support
    firebase.https.onCall(
      name: 'countdown',
      options: const CallableOptions(
        heartBeatIntervalSeconds: HeartBeatIntervalSeconds(5),
      ),
      (request, response) async {
        final data = request.data as Map<String, dynamic>?;
        final start = (data?['start'] as num?)?.toInt() ?? 10;

        // Stream countdown if client supports it
        if (request.acceptsStreaming) {
          for (var i = start; i >= 0; i--) {
            await response.sendChunk({'count': i});
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
        }

        return CallableResult({'message': 'Countdown complete!'});
      },
    );

    print('Functions registered successfully!');
  });
}

// =============================================================================
// Data classes for typed callable functions
// =============================================================================

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
