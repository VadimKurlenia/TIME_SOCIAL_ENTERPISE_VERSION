import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  final Dio dio;

  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000',

          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true, // Показывать, что мы отправляем
        responseBody: true, // Показывать, что FastAPI возвращает
        requestHeader: false, // Скрываем заголовки, чтобы не спамить в консоль
        responseHeader: false,
      ),
    );
  }
}
