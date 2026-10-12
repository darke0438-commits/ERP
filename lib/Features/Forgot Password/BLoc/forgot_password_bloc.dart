import 'package:erp_app/Features/Forgot Password/BLoc/forgot_password_event.dart';
import 'package:erp_app/Features/Forgot Password/BLoc/forgot_password_state.dart';
import 'package:erp_app/Features/Forgot Password/Model/forgot_password_model.dart';
import 'package:erp_app/api_manager/api_checker.dart';
import 'package:erp_app/api_manager/api_client.dart';
import 'package:erp_app/api_manager/api_endPoints.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(),
      super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
  }

  final ApiClient _apiClient;

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());

    // Build request based on selected method
    ForgotPasswordRequest request;
    switch (event.methodIndex) {
      case 0: // Email
        request = ForgotPasswordRequest(email: event.inputValue);
        break;
      case 1: // Mobile
        request = ForgotPasswordRequest(mobile: event.inputValue);
        break;
      case 2: // Student ID
        request = ForgotPasswordRequest(studentId: event.inputValue);
        break;
      default:
        request = ForgotPasswordRequest();
    }

    final response = await _apiClient.postData(
      ApiEndPoints.requestReset,
      body: request.toJson(),
    );

    final apiError = ApiChecker.checkApi(response);
    if (apiError != null) {
      String errorMessage = _getErrorMessage(
        response.statusCode,
        response.body,
        apiError,
      );
      emit(ForgotPasswordFailure(errorMessage));
      return;
    }

    if (response.body is! Map<String, dynamic>) {
      emit(const ForgotPasswordFailure('Invalid response from server.'));
      return;
    }

    final forgotPasswordResponse = ForgotPasswordResponse.fromJson(
      response.body as Map<String, dynamic>,
    );

    if (forgotPasswordResponse.statusCode == 200) {
      emit(const ForgotPasswordSuccess());
    } else {
      emit(
        ForgotPasswordFailure(
          forgotPasswordResponse.message.isNotEmpty
              ? forgotPasswordResponse.message
              : 'Request failed. Please try again.',
        ),
      );
    }
  }

  String _getErrorMessage(int statusCode, dynamic body, String fallback) {
    final message =
        body is Map<String, dynamic> && body['message'] is String
            ? body['message'] as String
            : fallback;

    if (statusCode == 404) {
      return 'Email not found. Please check your email or try other options.';
    }
    if (statusCode == 400) {
      return 'Invalid input. Please check your details and try again.';
    }
    if (statusCode == 500) {
      return 'Server error. Please try again later.';
    }
    if (statusCode == 1) {
      return 'Network error. Please check your connection.';
    }

    return message.isNotEmpty ? message : 'Request failed. Please try again.';
  }
}
