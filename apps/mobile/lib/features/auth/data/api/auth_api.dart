import 'package:dio/dio.dart';
import '../models/token_model.dart';
import '../models/user_models.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<TokenModel> login({
    required String login,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/token',
      data: {'login': login, 'password': password},
    );
    return TokenModel.fromJson(response.data);
  }

  Future<UserOutResponse> register(UserCreateRequest request) async {
    final response = await _dio.post('/auth/register', data: request.toJson());
    return UserOutResponse.fromJson(response.data);
  }
}
