// Named route paths used with go_router.
abstract final class RouteNames {

  static const String splash = '/';

  static const String home = '/home';

  static const String categories = '/categories';
  static const String search = '/search';
  static const String searchResults = '/search/results';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static String checkoutConfirmation(String orderId) => '/checkout/confirmation/$orderId';
  static const String orders = '/orders';
  static String orderDetail(String orderId) => '/orders/$orderId';
  static String orderPay(String orderId) => '/orders/$orderId/pay';
  static String paymentResult(String orderId) => '/orders/$orderId/payment-result';

  static String categoryProducts(String categoryId) => '/categories/$categoryId/products';

  static const String login = '/login';

  static const String otpVerification = '/login/otp';

  static const String accountRecovery = '/login/recovery';

  static const String blocked = '/blocked';



  static const String profile = '/profile';

  static const String profileEdit = '/profile/edit';

  static const String profileChangePhone = '/profile/change-phone';

  static const String profileAddresses = '/profile/addresses';

  /// Full-screen address form (outside bottom-nav shell — avoids ANR on push).
  static const String profileAddressAdd = '/addresses/add';

  static const String profileSettings = '/profile/settings';



  static String profileAddressEdit(String id) => '/addresses/$id/edit';

  static const String seller = '/seller';
  static const String sellerVerify = '/seller/verify';
  static const String sellerApply = '/seller/apply';
  static const String sellerBooths = '/seller/booths';

  static String sellerBoothDetail(String id) => '/seller/booths/$id';
  static String sellerBoothEdit(String id) => '/seller/booths/$id/edit';

  static const String sellerProducts = '/seller/products';
  static const String sellerProductCreate = '/seller/products/create';
  static String sellerProductEdit(String id) => '/seller/products/$id/edit';
  static const String sellerCategories = '/seller/categories';
  static const String sellerOrders = '/seller/orders';
  static String sellerOrderDetail(String id) => '/seller/orders/$id';

  static const String sellerBalance = '/seller/balance';
  static const String sellerBankAccounts = '/seller/bank-accounts';
  static const String sellerBankAccountAdd = '/seller/bank-accounts/add';
  static const String sellerSettlementRequest = '/seller/settlements/request';
  static const String sellerSettlements = '/seller/settlements';

  static String sellerBoothListings(String boothId) => '/seller/booths/$boothId/listings';
  static String sellerBoothListingAdd(String boothId) => '/seller/booths/$boothId/listings/add';
  static String sellerBoothListingEdit(String boothId, String listingId) =>
      '/seller/booths/$boothId/listings/$listingId/edit';

  static String publicBooth(String slug) => '/booth/$slug';
  static String productDetail(String listingId) => '/product/$listingId';

  static const String favorites = '/favorites';
  static const String following = '/following';

  static const String chat = '/chat';
  static String chatDetail(String conversationId) => '/chat/$conversationId';

  static String writeReview(String orderItemId) => '/review/$orderItemId';

  static const String notifications = '/notifications';

  static const String report = '/report';
  static const String myReports = '/my-reports';

  static const String support = '/support';
  static const String supportCreate = '/support/create';
  static String ticketDetail(String ticketId) => '/support/$ticketId';

  static const String about = '/about';
  static const String privacyPolicy = '/legal/privacy';
  static const String termsOfService = '/legal/terms';
}

