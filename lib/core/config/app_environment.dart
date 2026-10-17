/// Deployment environment for the mobile client.
enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment fromString(String value) {
    return switch (value.toLowerCase()) {
      'production' || 'prod' => AppEnvironment.prod,
      'staging' || 'stage' => AppEnvironment.staging,
      _ => AppEnvironment.dev,
    };
  }

  /// Dotenv asset file name for this environment.
  String get envFileName => switch (this) {
        AppEnvironment.prod => '.env.prod',
        AppEnvironment.staging => '.env.staging',
        AppEnvironment.dev => '.env.dev',
      };

  String get label => switch (this) {
        AppEnvironment.prod => 'Production',
        AppEnvironment.staging => 'Staging',
        AppEnvironment.dev => 'Development',
      };

  bool get isProduction => this == AppEnvironment.prod;
}
