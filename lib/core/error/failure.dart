// BASE FAILURE
// -----------------------------------------------------------------------------
// All feature-specific failures implement this. Lets generic UI code (like
// an error widget) display any failure without knowing its concrete type.
//
// In clean architecture, failures live in the DOMAIN layer — they describe
// what can go wrong in business terms, not in HTTP-specific terms. The data
// layer catches DioException and translates it to a domain Failure.
// -----------------------------------------------------------------------------

abstract class Failure {
  String get message;
}