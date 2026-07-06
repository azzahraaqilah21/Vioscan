# VioScan Flutter App

AI-powered UV fluorescence skin cancer screening app — converted from Figma Make (React/Vite) to Flutter/Dart.

## Project Structure

```
vioscan_flutter/
├── pubspec.yaml                    # Dependencies & assets config
│
└── lib/
    ├── main.dart                   # Entry point, app init, Hive + ProviderScope
    │
    ├── theme/
    │   └── app_theme.dart          # Colors, light/dark ThemeData
    │
    ├── router/
    │   └── app_router.dart         # go_router: all routes + ShellRoute for bottom nav
    │
    ├── models/
    │   └── scan_result.dart        # ScanResult, DetectedRegion, Patient, enums
    │
    ├── screens/
    │   ├── main_shell.dart         # Bottom navigation bar shell
    │   │
    │   ├── splash/
    │   │   └── splash_screen.dart  # Animated logo → auto-navigate
    │   │
    │   ├── onboarding/
    │   │   └── onboarding_screen.dart  # 3-page PageView with features
    │   │
    │   ├── auth/
    │   │   ├── login_screen.dart   # Email/password + Google OAuth
    │   │   └── register_screen.dart
    │   │
    │   ├── home/
    │   │   └── home_screen.dart    # Dashboard: CTA card, stats grid, recent scans
    │   │
    │   ├── scan/
    │   │   ├── scan_screen.dart    # 3-step scan: area select → camera → AI processing
    │   │   └── scan_result_screen.dart  # Risk level, confidence, image tabs, recs
    │   │
    │   ├── history/
    │   │   └── history_screen.dart # Filtered scan history list
    │   │
    │   ├── education/
    │   │   └── education_screen.dart   # Articles about BCC & skin cancer
    │   │
    │   └── profile/
    │       └── profile_screen.dart     # Patient info, risk factors, settings
    │
    └── widgets/
        ├── risk_badge.dart         # Color-coded risk level pill
        ├── scan_card.dart          # Scan history list item
        └── stat_card.dart          # Dashboard stat tile
```

## Setup

### 1. Install Flutter
Follow https://docs.flutter.dev/get-started/install

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run
```bash
flutter run
```

## Key Packages Used

| Package | Purpose |
|---|---|
| `go_router` | Declarative routing with ShellRoute |
| `flutter_riverpod` | State management |
| `hive_flutter` | Local storage for scan history |
| `camera` | Camera access for UV scanning |
| `fl_chart` | Charts for scan trend history |
| `dio` | HTTP client for API calls |
| `lottie` | Animations |

## Architecture

- **State**: Riverpod providers (add to `lib/providers/` as you scale)
- **Routing**: go_router with nested ShellRoute for persistent bottom nav
- **Theme**: Centralized `AppColors` + `AppTheme` with light/dark support
- **Models**: Plain Dart classes with `fromJson` factories

## Next Steps

1. Add `lib/providers/` — Riverpod providers for auth, scan state
2. Add `lib/services/` — API service (Dio), camera service, AI inference
3. Integrate real camera with the `camera` package in `scan_screen.dart`
4. Add `fl_chart` line chart to home dashboard for scan history trend
5. Add Hive adapters for offline scan result caching
