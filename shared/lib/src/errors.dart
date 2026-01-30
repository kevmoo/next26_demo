import 'package:json_schema_builder/json_schema_builder.dart';

class RequestValidationError extends Error {
  /// A user friendly message describing the error.
  final String message;

  /// The validation errors.
  final List<ValidationError> errors;

  RequestValidationError(this.message, this.errors);
}
