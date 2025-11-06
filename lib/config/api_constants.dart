class ApiConstants {
  static const String baseUrl = 'https://evconnect-3ydy.onrender.com'; // URL base de la API
  static const String apiVersion = '/api';
  
  // Endpoints
  static const String register = '$apiVersion/user/register';
  static const String login = '$apiVersion/user/login';
  
  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}