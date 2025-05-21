import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);

  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body}) {
    return http.post(Uri.parse('$baseUrl$path'), headers: headers, body: body);
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }
}