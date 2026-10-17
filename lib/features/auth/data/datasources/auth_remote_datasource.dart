import 'package:rahmani_project/core/config/env.dart';
import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// Remote data source for Supabase Auth and profiles.
abstract interface class AuthRemoteDataSource {
  Future<void> assertOtpRateLimit(String phone);

  Future<void> sendOtp(String phone);

  Future<UserModel> verifyOtp({
    required String phone,
    required String otp,
  });

  /// DEV-only direct login: signs in with any phone, no SMS OTP.
  /// Requires a configured `dev-login` Edge Function + `DEV_LOGIN_KEY`.
  Future<UserModel> devSignIn({required String phone});

  /// Starts phone-change OTP for [newPhone]. Returns OTP in DEV when available.
  Future<String?> requestPhoneChange(String newPhone);

  /// Confirms phone-change OTP and updates auth + profile phone.
  Future<UserModel> confirmPhoneChange({
    required String newPhone,
    required String otp,
  });

  /// Account recovery hint (anti-enumeration). Does not reveal if phone exists.
  Future<({bool blocked, String message})> getAccountRecoveryHint(String phone);

  Future<void> signOut();

  Future<UserModel?> fetchProfile(String userId);

  /// Creates the profile row if missing (idempotent).
  Future<UserModel> ensureProfile(String userId, {required String phone});

  Session? get currentSession;

  Stream<AuthState> get authStateChanges;
}

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<void> assertOtpRateLimit(String phone) async {
    try {
      await _client.rpc<void>('assert_otp_rate_limit', params: {'p_phone': phone});
    } on PostgrestException catch (e) {
      if (e.code == 'P0001' || e.message.contains('rate limit')) {
        throw const AuthException(
          'تعداد درخواست‌های کد تأیید بیش از حد مجاز است. ۱۰ دقیقه بعد دوباره تلاش کنید.',
        );
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await assertOtpRateLimit(phone);
      await _client.auth.signInWithOtp(phone: phone);
    } on AppException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: otp,
      );

      final userId = response.user?.id ?? response.session?.user.id;
      if (userId == null) {
        throw const AuthException('ورود ناموفق بود. دوباره تلاش کنید.');
      }

      return await ensureProfile(userId, phone: phone);
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> devSignIn({required String phone}) async {
    final key = Env.devLoginKey;
    if (key.isEmpty) {
      throw const AuthException('ورود مستقیم (dev) غیرفعال است.');
    }

    try {
      final response = await _client.functions
          .invoke('dev-login', body: {'phone': phone}, headers: {'x-dev-login-key': key});

      final data = response.data as Map<String, dynamic>?;
      final password = data?['password'] as String?;
      final email = data?['email'] as String?;
      if (password == null || password.isEmpty) {
        throw const AuthException('ورود مستقیم ناموفق بود. دوباره تلاش کنید.');
      }

      // Prefer synthetic email identity — works even when Phone Auth is disabled.
      if (email != null && email.isNotEmpty) {
        await _client.auth.signInWithPassword(email: email, password: password);
      } else {
        await _client.auth.signInWithPassword(phone: phone, password: password);
      }

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthException('ورود ناموفق بود. دوباره تلاش کنید.');
      }

      return await ensureProfile(userId, phone: phone);
    } on AppException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      final message = e.toString();
      if (message.contains('SocketException') ||
          message.contains('Failed host lookup') ||
          message.contains('ClientException')) {
        throw const AuthException(
          'اتصال به سرور برقرار نشد. اینترنت دستگاه و آدرس SUPABASE_URL را بررسی کنید.',
        );
      }
      if (message.contains('401') || message.contains('404')) {
        throw const AuthException(
          'ورود مستقیم (dev) فعال نیست. DEV_LOGIN_KEY را تنظیم و dev-login را deploy کنید.',
        );
      }
      throw ServerException(message);
    }
  }

  @override
  Future<String?> requestPhoneChange(String newPhone) async {
    try {
      final headers = <String, String>{};
      if (Env.devLoginEnabled && Env.devLoginKey.isNotEmpty) {
        headers['x-dev-login-key'] = Env.devLoginKey;
      }

      final response = await _client.functions.invoke(
        'change-phone',
        body: {'action': 'request', 'new_phone': newPhone},
        headers: headers,
      );

      final data = response.data;
      if (data is! Map) {
        throw const AuthException('درخواست تغییر شماره ناموفق بود.');
      }
      final map = Map<String, dynamic>.from(data);
      if (response.status >= 400) {
        throw AuthException(
          map['message']?.toString() ?? 'درخواست تغییر شماره ناموفق بود.',
        );
      }
      final otp = map['dev_otp']?.toString();
      return (otp != null && otp.isNotEmpty) ? otp : null;
    } on AppException {
      rethrow;
    } on FunctionException catch (e) {
      throw AuthException(_messageFromFunction(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> confirmPhoneChange({
    required String newPhone,
    required String otp,
  }) async {
    try {
      final headers = <String, String>{};
      if (Env.devLoginEnabled && Env.devLoginKey.isNotEmpty) {
        headers['x-dev-login-key'] = Env.devLoginKey;
      }

      final response = await _client.functions.invoke(
        'change-phone',
        body: {
          'action': 'confirm',
          'new_phone': newPhone,
          'otp': otp,
        },
        headers: headers,
      );

      final data = response.data;
      if (data is! Map) {
        throw const AuthException('تأیید تغییر شماره ناموفق بود.');
      }
      final map = Map<String, dynamic>.from(data);
      if (response.status >= 400) {
        throw AuthException(
          map['message']?.toString() ?? 'تأیید تغییر شماره ناموفق بود.',
        );
      }

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthException('نشست کاربری معتبر نیست. دوباره وارد شوید.');
      }

      final profile = await fetchProfile(userId);
      if (profile == null) {
        throw const ServerException('پروفایل کاربر یافت نشد.');
      }
      return profile;
    } on AppException {
      rethrow;
    } on FunctionException catch (e) {
      throw AuthException(_messageFromFunction(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<({bool blocked, String message})> getAccountRecoveryHint(
    String phone,
  ) async {
    try {
      final data = await _client.rpc<dynamic>(
        'get_account_recovery_hint',
        params: {'p_phone': phone},
      );
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        return (
          blocked: map['blocked'] == true,
          message: map['message']?.toString() ??
              'اگر حسابی با این شماره وجود داشته باشد، با ورود و کد تأیید می‌توانید دوباره دسترسی پیدا کنید.',
        );
      }
      return (
        blocked: false,
        message:
            'اگر حسابی با این شماره وجود داشته باشد، با ورود و کد تأیید می‌توانید دوباره دسترسی پیدا کنید.',
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  String _messageFromFunction(FunctionException e) {
    final details = e.details;
    if (details is Map && details['message'] != null) {
      return details['message'].toString();
    }
    if (e.reasonPhrase != null && e.reasonPhrase!.isNotEmpty) {
      return e.reasonPhrase!;
    }
    return 'خطای سرور. دوباره تلاش کنید.';
  }

  @override
  Future<UserModel?> fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select('id, phone, full_name, avatar_url, is_blocked, is_seller')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  /// Ensures a `profiles` row exists after auth (OTP or dev-login).
  ///
  /// The DB trigger usually creates it on `auth.users` INSERT, but returning
  /// users updated via admin API skip that trigger — so we upsert here.
  @override
  Future<UserModel> ensureProfile(
    String userId, {
    required String phone,
  }) async {
    final existing = await fetchProfile(userId);
    if (existing != null) return existing;

    final normalized = phone.trim();
    if (normalized.isEmpty) {
      throw const ServerException('شماره موبایل برای ساخت حساب الزامی است.');
    }

    try {
      await _client.from('profiles').upsert(
        {'id': userId, 'phone': normalized},
        onConflict: 'id',
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }

    final created = await fetchProfile(userId);
    if (created == null) {
      throw const ServerException('ساخت حساب کاربری ناموفق بود.');
    }
    return created;
  }

  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid') || lower.contains('otp')) {
      return 'کد تأیید نامعتبر یا منقضی شده است.';
    }
    if (lower.contains('rate') || lower.contains('too many')) {
      return 'تعداد درخواست‌ها بیش از حد مجاز است. بعداً تلاش کنید.';
    }
    return message;
  }
}
