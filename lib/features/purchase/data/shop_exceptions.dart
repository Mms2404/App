sealed class ShopException implements Exception {
  final String message;
  const ShopException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ShopException {
  const NetworkException() : super('No internet connection');
}

class ServerException extends ShopException {
  final int statusCode;
  const ServerException(this.statusCode, String message)
      : super('Server error ($statusCode): $message');
}

class ParseException extends ShopException {
  const ParseException(String details) : super('Failed to parse response: $details');
}

class UnknownShopException extends ShopException {
  const UnknownShopException(String message) : super(message);
}