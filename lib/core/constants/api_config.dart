class ApiConfig {
  // static const String baseUrl = String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: 'http://10.36.193.18:8000/api',
  // );
  static const String local = 'http://192.168.1.5:8000';
  static const String baseUrl = '${local}/api';

  static const String api_token_auth = '${local}/api-token-auth/';
  static const String api_expense_register = '${baseUrl}/register/';
}