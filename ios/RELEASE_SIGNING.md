# iOS Release Signing

## Prerequisites

- Apple Developer Program membership ($99/year)
- Xcode installed on macOS
- Bundle ID: `com.rahmani.marketplace`

## Steps

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target → **Signing & Capabilities**
3. Set **Team** to your Apple Developer team
4. Enable **Automatically manage signing**
5. Confirm Bundle Identifier: `com.rahmani.marketplace`
6. Add capabilities if needed:
   - Push Notifications
   - Background Modes → Remote notifications

## Firebase (FCM / Crashlytics)

1. Create iOS app in Firebase Console with bundle `com.rahmani.marketplace`
2. Download `GoogleService-Info.plist`
3. Add to `ios/Runner/` via Xcode (Copy items if needed)

## Provisioning profiles

Xcode generates development and distribution profiles automatically when signing is enabled.

For CI (Phase 33), use Fastlane Match or App Store Connect API keys.

## Build IPA

```bash
flutter build ipa \
  --release \
  --dart-define=APP_ENV=prod \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Upload via Xcode Organizer or `xcrun altool` / Transporter.

## Notes

- Single `Runner` scheme is used for all builds (no flavor schemes)
- Test on physical device before App Store submission
- App Store review: 1–7 days typical
