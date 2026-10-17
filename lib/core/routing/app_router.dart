import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/auth/presentation/screens/account_recovery_screen.dart';
import 'package:rahmani_project/features/auth/presentation/screens/blocked_screen.dart';
import 'package:rahmani_project/features/auth/presentation/screens/change_phone_screen.dart';
import 'package:rahmani_project/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:rahmani_project/features/auth/presentation/screens/phone_input_screen.dart';
import 'package:rahmani_project/features/booth/presentation/screens/booth_application_screen.dart';
import 'package:rahmani_project/features/booth/presentation/screens/booth_detail_screen.dart';
import 'package:rahmani_project/features/booth/presentation/screens/booth_edit_screen.dart';
import 'package:rahmani_project/features/booth/presentation/screens/my_booths_screen.dart';
import 'package:rahmani_project/features/seller_dashboard/presentation/screens/seller_dashboard_screen.dart';
import 'package:rahmani_project/features/booth/presentation/screens/seller_verification_screen.dart';
import 'package:rahmani_project/features/home/presentation/screens/booth_public_screen.dart';
import 'package:rahmani_project/features/cart/presentation/screens/cart_screen.dart';
import 'package:rahmani_project/features/chat/presentation/screens/chat_screen.dart';
import 'package:rahmani_project/features/chat/presentation/screens/conversation_list_screen.dart';
import 'package:rahmani_project/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:rahmani_project/features/checkout/presentation/screens/order_confirmation_screen.dart';
import 'package:rahmani_project/features/home/presentation/screens/category_browse_screen.dart';
import 'package:rahmani_project/features/home/presentation/screens/category_products_screen.dart';
import 'package:rahmani_project/features/order/presentation/screens/order_detail_screen.dart';
import 'package:rahmani_project/features/order/presentation/screens/order_list_screen.dart';
import 'package:rahmani_project/features/order/presentation/screens/seller_order_detail_screen.dart';
import 'package:rahmani_project/features/order/presentation/screens/seller_order_list_screen.dart';
import 'package:rahmani_project/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:rahmani_project/features/payment/presentation/screens/payment_screen.dart';
import 'package:rahmani_project/features/home/presentation/screens/home_screen.dart';
import 'package:rahmani_project/features/home/presentation/screens/splash_screen.dart';
import 'package:rahmani_project/features/legal/presentation/screens/legal_screens.dart';
import 'package:rahmani_project/features/listing/presentation/screens/add_listing_screen.dart';
import 'package:rahmani_project/features/listing/presentation/screens/booth_listings_screen.dart';
import 'package:rahmani_project/features/listing/presentation/screens/edit_listing_screen.dart';
import 'package:rahmani_project/features/listing/presentation/screens/product_detail_screen.dart';
import 'package:rahmani_project/features/notification/presentation/screens/notification_list_screen.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';
import 'package:rahmani_project/features/report/presentation/screens/my_reports_screen.dart';
import 'package:rahmani_project/features/report/presentation/screens/report_screen.dart';
import 'package:rahmani_project/features/review/presentation/screens/write_review_screen.dart';
import 'package:rahmani_project/features/product/presentation/screens/category_list_screen.dart';
import 'package:rahmani_project/features/product/presentation/screens/my_products_screen.dart';
import 'package:rahmani_project/features/product/presentation/screens/product_create_screen.dart';
import 'package:rahmani_project/features/product/presentation/screens/product_edit_screen.dart';
import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';
import 'package:rahmani_project/features/profile/presentation/screens/add_edit_address_screen.dart';
import 'package:rahmani_project/features/profile/presentation/screens/addresses_screen.dart';
import 'package:rahmani_project/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:rahmani_project/features/profile/presentation/screens/profile_screen.dart';
import 'package:rahmani_project/features/profile/presentation/screens/settings_screen.dart';
import 'package:rahmani_project/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:rahmani_project/features/favorites/presentation/screens/followed_booths_screen.dart';
import 'package:rahmani_project/features/search/domain/entities/search_enums.dart';
import 'package:rahmani_project/features/search/presentation/screens/search_results_screen.dart';
import 'package:rahmani_project/features/search/presentation/screens/search_screen.dart';
import 'package:rahmani_project/features/settlement/presentation/screens/add_bank_account_screen.dart';
import 'package:rahmani_project/features/settlement/presentation/screens/bank_accounts_screen.dart';
import 'package:rahmani_project/features/settlement/presentation/screens/seller_balance_screen.dart';
import 'package:rahmani_project/features/settlement/presentation/screens/settlement_history_screen.dart';
import 'package:rahmani_project/features/settlement/presentation/screens/settlement_request_screen.dart';
import 'package:rahmani_project/features/support/presentation/screens/create_ticket_screen.dart';
import 'package:rahmani_project/features/support/presentation/screens/ticket_detail_screen.dart';
import 'package:rahmani_project/features/support/presentation/screens/ticket_list_screen.dart';
import 'package:rahmani_project/shared/widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final status = ref.read(authStatusProvider);
      final location = state.matchedLocation;
      final isSplash = location == RouteNames.splash;
      final isLogin = location == RouteNames.login;
      final isOtp = location == RouteNames.otpVerification;
      final isRecovery = location == RouteNames.accountRecovery;
      final isAuthRoute = isLogin || isOtp || isRecovery;
      final isBlockedRoute = location == RouteNames.blocked;

      if (status == AuthStatus.unknown) {
        return isSplash ? null : RouteNames.splash;
      }

      if (isSplash) {
        return switch (status) {
          AuthStatus.authenticated => RouteNames.home,
          AuthStatus.blocked => RouteNames.blocked,
          AuthStatus.unauthenticated => RouteNames.login,
          AuthStatus.unknown => null,
        };
      }

      if (status == AuthStatus.blocked) {
        return isBlockedRoute ? null : RouteNames.blocked;
      }

      // Login-first: no public browse without an account/session.
      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return RouteNames.login;
      }

      if (status == AuthStatus.authenticated && isAuthRoute) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const PhoneInputScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            name: 'otp',
            builder: (context, state) {
              final phone = state.extra as String? ?? '';
              return OtpVerificationScreen(phone: phone);
            },
          ),
          GoRoute(
            path: 'recovery',
            name: 'account-recovery',
            builder: (context, state) => const AccountRecoveryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.blocked,
        name: 'blocked',
        builder: (context, state) => const BlockedScreen(),
      ),
      GoRoute(
        path: RouteNames.seller,
        name: 'seller',
        builder: (context, state) => const SellerDashboardScreen(),
        routes: [
          GoRoute(
            path: 'verify',
            name: 'seller-verify',
            builder: (context, state) => const SellerVerificationScreen(),
          ),
          GoRoute(
            path: 'apply',
            name: 'seller-apply',
            builder: (context, state) => const BoothApplicationScreen(),
          ),
          GoRoute(
            path: 'booths',
            name: 'seller-booths',
            builder: (context, state) => const MyBoothsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'seller-booth-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BoothDetailScreen(boothId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'seller-booth-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BoothEditScreen(boothId: id);
                    },
                  ),
                  GoRoute(
                    path: 'listings',
                    name: 'seller-booth-listings',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BoothListingsScreen(boothId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: 'seller-booth-listing-add',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return AddListingScreen(boothId: id);
                        },
                      ),
                      GoRoute(
                        path: ':listingId/edit',
                        name: 'seller-booth-listing-edit',
                        builder: (context, state) {
                          final boothId = state.pathParameters['id']!;
                          final listingId = state.pathParameters['listingId']!;
                          return EditListingScreen(boothId: boothId, listingId: listingId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'products',
            name: 'seller-products',
            builder: (context, state) => const MyProductsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'seller-product-create',
                builder: (context, state) => const ProductCreateScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'seller-product-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProductEditScreen(productId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'categories',
            name: 'seller-categories',
            builder: (context, state) => const CategoryListScreen(),
          ),
          GoRoute(
            path: 'orders',
            name: 'seller-orders',
            builder: (context, state) => const SellerOrderListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'seller-order-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return SellerOrderDetailScreen(sellerOrderId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'balance',
            name: 'seller-balance',
            builder: (context, state) => const SellerBalanceScreen(),
          ),
          GoRoute(
            path: 'bank-accounts',
            name: 'seller-bank-accounts',
            builder: (context, state) => const BankAccountsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'seller-bank-account-add',
                builder: (context, state) => const AddBankAccountScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'settlements',
            name: 'seller-settlements',
            builder: (context, state) => const SettlementHistoryScreen(),
            routes: [
              GoRoute(
                path: 'request',
                name: 'seller-settlement-request',
                builder: (context, state) => const SettlementRequestScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/booth/:slug',
        name: 'public-booth',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return BoothPublicScreen(boothSlug: slug);
        },
      ),
      GoRoute(
        path: '/product/:listingId',
        name: 'product-detail',
        builder: (context, state) {
          final listingId = state.pathParameters['listingId']!;
          return ProductDetailScreen(listingId: listingId);
        },
      ),
      GoRoute(
        path: RouteNames.search,
        name: 'search',
        builder: (context, state) {
          final tab = state.extra is SearchTab ? state.extra as SearchTab : null;
          return SearchScreen(initialTab: tab);
        },
        routes: [
          GoRoute(
            path: 'results',
            name: 'search-results',
            builder: (context, state) => const SearchResultsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: RouteNames.following,
        name: 'following',
        builder: (context, state) => const FollowedBoothsScreen(),
      ),
      GoRoute(
        path: RouteNames.chat,
        name: 'chat',
        builder: (context, state) => const ConversationListScreen(),
        routes: [
          GoRoute(
            path: ':conversationId',
            name: 'chat-detail',
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              final title = state.extra as String?;
              return ChatScreen(conversationId: conversationId, title: title);
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationListScreen(),
      ),
      GoRoute(
        path: RouteNames.report,
        name: 'report',
        builder: (context, state) {
          final target = state.extra as ReportTarget?;
          if (target == null) {
            return const Scaffold(
              body: Center(child: Text('هدف گزارش نامعتبر است.')),
            );
          }
          return ReportScreen(target: target);
        },
      ),
      GoRoute(
        path: RouteNames.myReports,
        name: 'my-reports',
        builder: (context, state) => const MyReportsScreen(),
      ),
      GoRoute(
        path: RouteNames.support,
        name: 'support',
        builder: (context, state) => const TicketListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'support-create',
            builder: (context, state) => const CreateTicketScreen(),
          ),
          GoRoute(
            path: ':ticketId',
            name: 'support-detail',
            builder: (context, state) {
              final ticketId = state.pathParameters['ticketId']!;
              return TicketDetailScreen(ticketId: ticketId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/review/:orderItemId',
        name: 'write-review',
        builder: (context, state) {
          final orderItemId = state.pathParameters['orderItemId']!;
          final productName = state.extra as String? ?? 'محصول';
          return WriteReviewScreen(
            orderItemId: orderItemId,
            productName: productName,
          );
        },
      ),
      GoRoute(
        path: RouteNames.checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/checkout/confirmation/:orderId',
        name: 'checkout-confirmation',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderConfirmationScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/orders/:orderId',
        name: 'order-detail',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: orderId);
        },
        routes: [
          GoRoute(
            path: 'pay',
            name: 'order-pay',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return PaymentScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: 'payment-result',
            name: 'payment-result',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return PaymentResultScreen(orderId: orderId);
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RouteNames.privacyPolicy,
        name: 'privacy-policy',
        builder: (context, state) =>
            const LegalDocumentScreen(type: LegalDocumentType.privacy),
      ),
      GoRoute(
        path: RouteNames.termsOfService,
        name: 'terms-of-service',
        builder: (context, state) =>
            const LegalDocumentScreen(type: LegalDocumentType.terms),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.categories,
            name: 'categories',
            builder: (context, state) => const CategoryBrowseScreen(),
            routes: [
              GoRoute(
                path: ':categoryId/products',
                name: 'category-products',
                builder: (context, state) {
                  final categoryId = state.pathParameters['categoryId']!;
                  return CategoryProductsScreen(categoryId: categoryId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.cart,
            name: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: RouteNames.orders,
            name: 'orders',
            builder: (context, state) => const OrderListScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'profile-edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'settings',
                name: 'profile-settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'change-phone',
                name: 'profile-change-phone',
                builder: (context, state) => const ChangePhoneScreen(),
              ),
              GoRoute(
                path: 'addresses',
                name: 'profile-addresses',
                builder: (context, state) => const AddressesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.profileAddressAdd,
        name: 'profile-address-add',
        builder: (context, state) => const AddEditAddressScreen(),
      ),
      GoRoute(
        path: '/addresses/:id/edit',
        name: 'profile-address-edit',
        builder: (context, state) {
          final address = state.extra as AddressEntity?;
          return AddEditAddressScreen(address: address);
        },
      ),
    ],
  );
});
