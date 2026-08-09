# The Breakaway — mobile app

Flutter client for Breakaway OS. This scaffold covers the theme and the
Login screen — the first item on the dev roadmap.

## What's here

```
lib/
  main.dart                          entry point, wires theme -> LoginScreen
  core/theme/
    app_colors.dart                  brand palette (emerald / neon / cream)
    app_typography.dart              Inter type scale
    app_theme.dart                   ThemeData assembled from the above
  features/auth/
    presentation/login_screen.dart   email + password form
    widgets/breakaway_mark.dart      signature animated mark (peloton -> breakaway)
```

Role (rider / chef / driver / CEO) is resolved server-side from the JWT
returned on login, per the brand doc — there's no role picker in the UI.

## Getting it running locally

This was scaffolded by hand (no Flutter SDK available in the sandbox that
generated it), so the platform folders (`android/`, `ios/`, etc.) aren't
present yet. To run it:

```bash
flutter create --project-name breakaway_app --org com.thebreakaway .
flutter pub get
flutter run
```

The `flutter create .` step will fill in `android/`, `ios/`, `web/` and
`pubspec.lock` without touching the `lib/` files above.

## Next steps (per the roadmap)

1. **Auth API integration** — `LoginScreen._submit()` has a marked TODO
   where the real call to the NestJS Auth API goes. Store the returned
   JWT with `flutter_secure_storage` and route by the role it encodes.
2. **Strava webhook** — backend-side, for telemetry ingestion.
3. Once auth lands, the next screen is the Rider Dashboard (real-time
   telemetry — pulse, power, cadence, speed, elevation, Di2 + SOS button).
