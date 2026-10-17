/// Domain-layer failure types returned by repositories and use cases.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'خطای سرور. لطفاً دوباره تلاش کنید.']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'اتصال اینترنت برقرار نیست.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'لطفاً وارد حساب کاربری شوید.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'مورد درخواستی یافت نشد.']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'خطا در ذخیره‌سازی محلی.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'خطای ناشناخته رخ داد.']);
}
