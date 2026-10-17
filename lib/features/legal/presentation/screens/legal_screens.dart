import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

enum LegalDocumentType {
  privacy(
    title: 'سیاست حریم خصوصی',
    assetPath: AppConstants.privacyPolicyAsset,
    webUrl: AppConstants.privacyPolicyUrl,
  ),
  terms(
    title: 'شرایط استفاده',
    assetPath: AppConstants.termsOfServiceAsset,
    webUrl: AppConstants.termsOfServiceUrl,
  );

  const LegalDocumentType({
    required this.title,
    required this.assetPath,
    required this.webUrl,
  });

  final String title;
  final String assetPath;
  final String webUrl;
}

final legalDocumentContentProvider =
    FutureProvider.family<String, LegalDocumentType>((ref, type) async {
  return rootBundle.loadString(type.assetPath);
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

/// Displays an in-app legal document with optional web link.
class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({
    required this.type,
    super.key,
  });

  final LegalDocumentType type;

  Future<void> _openWebVersion(BuildContext context) async {
    final uri = Uri.parse(type.webUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('باز کردن لینک وب ممکن نیست')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(legalDocumentContentProvider(type));

    return Scaffold(
      appBar: AppBar(
        title: Text(type.title),
        actions: [
          IconButton(
            tooltip: 'نسخه وب',
            onPressed: () => _openWebVersion(context),
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: contentAsync.when(
        loading: () => AppLoadingIndicator(message: 'در حال بارگذاری ${type.title}...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(legalDocumentContentProvider(type)),
        ),
        data: (content) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
      ),
    );
  }
}

/// About screen with version info and legal links.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('درباره رحمانی')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.storefront,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                packageInfoAsync.when(
                  loading: () => const Text('...'),
                  error: (_, _) => Text('نسخه ${AppConstants.appVersion}'),
                  data: (info) => Text('نسخه ${info.version} (${info.buildNumber})'),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.bundleId,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('سیاست حریم خصوصی'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push(RouteNames.privacyPolicy),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('شرایط استفاده'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push(RouteNames.termsOfService),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('پشتیبانی'),
            subtitle: Text(AppConstants.supportEmail),
            onTap: () => launchUrl(Uri.parse('mailto:${AppConstants.supportEmail}')),
          ),
        ],
      ),
    );
  }
}
