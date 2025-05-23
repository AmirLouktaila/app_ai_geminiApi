import 'package:dio/dio.dart';
import 'dart:convert';

Future<String> ApiGmini(String ApiKey, String text) async {
  Dio dio = Dio();

  final key = ApiKey;
  try {
    final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${key}',
        data: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": text}
              ]
            }
          ]
        }),
        options: Options(headers: {"Content-Type": "application/json"}));
    if (response.data['candidates'] != null &&
        response.data['candidates'].isNotEmpty) {
      var content =response.data['candidates'][0]['content']['parts'][0]['text'];
      return content;
    } else {
      return 'لا يوجد رد من النموذج';
    }
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      print('انتهى وقت الاتصال');
      return 'انتهى وقت الاتصال';
    } else if (e.response?.statusCode == 404) {
      print('لم يتم العثور على البيانات');
      return 'لم يتم العثور على البيانات';
    } else {
      print('حدث خطأ غير معروف: ${e.message}');
      return 'حدث خطأ غير معروف: ${e.message}';
    }
  }
}
