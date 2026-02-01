<p align="center">
  <img src="assets/icons/app_icon.png" width="120" alt="Zan App Icon" />
</p>

<h1 align="center">Zan</h1>

<p align="center">
  Smart personal finance app with invisible double-entry bookkeeping
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey" alt="Platform" />
</p>

## Overview

Zan is a personal finance app that makes double-entry bookkeeping invisible. Users see simple **"From → To"** transfers while the system processes proper debit/credit accounting behind the scenes. Primary target markets are Japan and Korea.

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app (requires .env file)
flutter run --dart-define-from-file=.env
```

## Tech Stack

- **Framework**: Flutter 3.x (iOS / Android)
- **State Management**: Riverpod 2.x
- **Backend**: Supabase (Auth, Database, Storage)
- **Local DB**: Drift (SQLite)
- **Firebase**: Analytics, Crashlytics, Cloud Messaging
- **CI/CD**: GitHub Actions
