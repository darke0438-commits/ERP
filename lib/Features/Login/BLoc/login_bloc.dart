import 'package:erp_app/Features/Login/BLoc/login_event.dart';
import 'package:erp_app/Features/Login/BLoc/login_state.dart';
import 'package:erp_app/Services/user_service.dart';
import 'package:erp_app/api_manager/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(),
      super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  final ApiClient _apiClient;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    try {
      final loginResponse = await UserService.login(
        loginId: event.loginId,
        password: event.password,
      );

      if (!loginResponse.isAuthenticated) {
        emit(
          LoginFailure(
            loginResponse.message.isEmpty
                ? 'Login failed: No token received'
                : loginResponse.message,
          ),
        );
        return;
      }

      await _apiClient.saveLoginTokens(
        token: loginResponse.token,
        refreshToken: loginResponse.refreshToken,
      );
      emit(LoginSuccess(loginResponse.message));
    } catch (error) {
      emit(LoginFailure('Login failed: $error'));
    }
  }
}
