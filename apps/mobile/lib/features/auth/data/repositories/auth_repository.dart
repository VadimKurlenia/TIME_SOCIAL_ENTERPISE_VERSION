import 'package:dio/dio.dart';
import '../api/auth_api.dart';
import '../models/token_model.dart';
import '../models/user_models.dart';

class AuthRepository {
  final AuthApi _authApi;
  AuthRepository(this._authApi);

  Future<TokenModel> login({
    required String login,
    required String password,
  }) async {
    try {
      return await _authApi.login(login: login, password: password);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Ошибка входа');
    }
  }

  Future<UserOutResponse> register(UserCreateRequest request) async {
    try {
      return await _authApi.register(request);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Ошибка регистрации');
    }
  }
}
