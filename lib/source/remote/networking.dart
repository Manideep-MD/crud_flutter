import 'package:http/http.dart' as http;

class Networking {
  static Future<http.Response> post(url, body) async {
    Map<String, String> header = {'Content-Type': 'application/json'};
    final http.Response res = await http.post(
      Uri.parse(url),
      body: body,
      headers: header,
    );
    return res;
  }

  static Future<http.Response> get(url) async {
    Map<String, String> header = {'Content-Type': 'application/json'};
    final http.Response res = await http.get(Uri.parse(url), headers: header);
    return res;
  }

  static Future<http.Response> delete(url, [Map<String, dynamic>? body]) async {
    Map<String, String> header = {'Content-Type': 'application/json'};
    final http.Response res = await http.delete(
      Uri.parse(url),
      body: body,
      headers: header,
    );
    return res;
  }

  static Future<http.Response> put(url, body) async {
    Map<String, String> header = {'Content-Type': 'application/json'};
    final http.Response res = await http.put(
      Uri.parse(url),
      body: body,
      headers: header,
    );
    return res;
  }

  static checkStatusCode(data) async {
    switch (data.statusCode) {
      case 200: // Ok / api hit successfully
        return data.body;
      case 201: // created
        return data.body;
      case 202: // created
        return data.body;
      case 400: // common error / data not found / exception
        return '';
      case 401: // unauthorized user
        return '';
      case 402: // error / exception
        return '';
      case 404: // not founded / query not working
        return '';
      case 500: // internal server error
        return '';
      default:
        return '';
    }
  }
}
