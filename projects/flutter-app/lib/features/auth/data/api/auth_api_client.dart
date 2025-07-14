import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../domain/models/auth_models.dart';
import '../../domain/models/user.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  @POST('/auth/login')
  Future<AuthResponse> login(@Body() Map<String, dynamic> request);

  @POST('/auth/register')
  Future<AuthResponse> signup(@Body() Map<String, dynamic> request);

  @POST('/auth/social-login')
  Future<AuthResponse> socialLogin(@Body() Map<String, dynamic> request);

  @POST('/auth/refresh')
  Future<AuthResponse> refreshToken(@Body() Map<String, dynamic> request);

  @POST('/auth/logout')
  Future<void> logout();

  @GET('/auth/me')
  Future<User> getCurrentUser();

  @POST('/auth/password-reset')
  Future<void> requestPasswordReset(@Body() Map<String, dynamic> request);

  @POST('/auth/password-change')
  Future<void> changePassword(@Body() Map<String, dynamic> request);

  @POST('/auth/email-verification')
  Future<void> verifyEmail(@Body() Map<String, dynamic> request);

  @POST('/auth/email-verification/resend')
  Future<void> resendEmailVerification();

  @POST('/auth/biometric/setup')
  Future<void> setupBiometric(@Body() Map<String, dynamic> request);

  @DELETE('/auth/biometric')
  Future<void> removeBiometric();

  @GET('/auth/check-email')
  Future<Map<String, bool>> checkEmailAvailability(@Query('email') String email);

  @GET('/auth/check-username')
  Future<Map<String, bool>> checkUsernameAvailability(@Query('username') String username);
}