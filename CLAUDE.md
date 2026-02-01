# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Zan (Asset Lite) is a smart personal finance mobile app built on double-entry bookkeeping. The core concept is "Invisible Double-Entry Bookkeeping" — users see simple "From → To" transfers while the system processes proper double-entry accounting (debit/credit) behind the scenes. Primary target market is Japan, with Korea expansion planned.

## Tech Stack

- **Frontend**: Flutter 3.x (cross-platform: iOS / Android / Web)
- **State Management**: Riverpod 2.x (NOT Provider)
- **Routing**: go_router (declarative, type-safe)
- **Local DB**: Drift (SQLite, for offline cache)
- **HTTP**: Dio (with interceptors)
- **Backend**: Supabase (PostgreSQL BaaS) + Supabase Auth + Supabase Storage
- **Auth**: Supabase Auth — Google Sign-In (OAuth), Apple Sign-In (OAuth + nonce/PKCE, iOS only)
- **Firebase**: Analytics (configured), Crashlytics / FCM (미구현)
- **Monetization**: in_app_purchase, Freemium 모델 (구독 + Feature Gate)
- **Privacy**: App Tracking Transparency (ATT)
- **AI/ML** (Phase 2): Gemini 1.5 Flash, Google ML Kit (OCR), Platform STT
- **Infrastructure**: GitHub Actions CI/CD

## Build & Development Commands

```bash
# Create project (if not initialized)
flutter create --org com.zan --project-name zan .

# Get dependencies
flutter pub get

# Run code generation (freezed, drift, json_serializable, go_router_builder)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch --delete-conflicting-outputs

# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/unit/repositories/transaction_repository_test.dart

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Firebase 재설정 (firebase_options.dart 재생성)
flutterfire configure --project=smart-budget-book
```

## Architecture

Clean Architecture with three layers. Dependencies flow inward only: Presentation → Domain ← Data.

```
lib/
├── main.dart                    # App entry, ProviderScope, env loading
├── app.dart                     # MaterialApp, router, theme 설정
├── firebase_options.dart        # FlutterFire CLI 자동 생성 (커밋 포함)
├── config/
│   ├── di/                      # Riverpod provider definitions (feature별 분리)
│   ├── env/                     # Environment variable access (.env)
│   ├── router/                  # go_router configuration, route guards
│   └── theme/                   # App theme 설정
├── core/
│   ├── constants/               # App-wide constants, enums
│   ├── errors/                  # Failure/Exception types
│   ├── extensions/              # Dart extension methods
│   ├── services/                # Analytics, ATT 등 앱 서비스
│   ├── usecase/                 # UseCase base class
│   └── utils/                   # Shared utilities
├── data/
│   ├── datasources/
│   │   ├── local/               # Drift (SQLite) data sources
│   │   └── remote/              # Supabase data sources (auth, transactions 등)
│   ├── models/                  # DTOs (Data Transfer Objects)
│   ├── mappers/                 # DTO ↔ Entity mappers
│   └── repositories/            # Concrete repository implementations
├── domain/
│   ├── entities/                # Business objects (Transaction, Account, etc.)
│   ├── repositories/            # Abstract repository interfaces
│   └── usecases/                # Business logic use cases
├── presentation/
│   ├── screens/                 # Screen widgets (pages)
│   ├── widgets/                 # Reusable UI components
│   └── providers/               # Riverpod Notifiers (ViewModels)
└── l10n/                        # Localization (ARB files)
```

## Double-Entry Bookkeeping Model

This is the core domain concept. Every transaction has:
- `debit_account_id` — the account being debited (assets/expenses increase)
- `credit_account_id` — the account being credited (liabilities/income increase)
- `amount` — always positive integer in smallest currency unit (cents/won)

Balance calculation differs by account type:
- **Asset / Expense**: `initial_balance + SUM(debits) - SUM(credits)`
- **Liability / Income / Equity**: `initial_balance + SUM(credits) - SUM(debits)`

Account types: `asset`, `liability`, `expense`, `income`, `equity`

## Database Schema (Supabase / PostgreSQL)

Key tables with RLS enabled on all:
- `profiles` — extends `auth.users`, stores display_name, default_currency, settings (JSONB)
- `accounts` — user's financial accounts (name, type, category, icon, color, payment_due_day, initial_balance, currency)
- `transactions` — double-entry records (date, amount, debit_account_id, credit_account_id, description, source_type)
- `account_balances` — SQL VIEW computing real-time balances per account

Custom PostgreSQL types: `account_type`, `account_category`, `source_type`
Custom functions: `get_user_balances(user_id)`, `get_monthly_summary(user_id, year, month)`

Amount is stored as INTEGER in smallest unit (1 JPY = 1, 1 KRW = 1). Transactions use soft delete (`deleted_at` field).

## Commit Message Convention

Conventional Commits 기반, 제목은 한글로 작성.

### 형식

```
<타입>(<범위>): <제목>

<본문> (선택)

<꼬리말> (선택)
```

### 타입

| 타입 | 용도 |
|------|------|
| `feat` | 새 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 리팩토링 (기능 변화 없음) |
| `style` | UI/스타일 변경 |
| `test` | 테스트 추가/수정 |
| `docs` | 문서 변경 |
| `chore` | 빌드/CI/설정 변경 |
| `perf` | 성능 개선 |

### 범위 (선택)

| 범위 | 대상 |
|------|------|
| `거래` | 거래 입력/조회/수정 |
| `계좌` | 계좌 관리 |
| `인증` | 로그인/회원가입/소셜 로그인 |
| `홈` | 홈 화면/대시보드 |
| `리포트` | 월간 보고서/통계 |
| `온보딩` | 온보딩 플로우 |
| `구독` | 구독/결제/페이월 |
| `설정` | 앱 설정 |
| `ci` | CI/CD 파이프라인 |
| `db` | DB 스키마/마이그레이션 |

### 규칙

- 제목은 한글, 50자 이내, 마침표 없음
- 타입은 영문 소문자
- 본문은 "무엇을"이 아닌 **"왜"** 중심으로 작성
- Breaking change는 꼬리말에 `BREAKING CHANGE:` 표기

### 예시

```
feat(거래): 지출/수입/이체 탭 전환 방식 도입
fix(인증): Google 로그인 시 빈 serverClientId 방어 처리
test(거래): 복식부기 잔액 계산 테스트 추가
chore(ci): GitHub Actions 워크플로우 추가
```

## Authentication

Supabase Auth 기반, OAuth 소셜 로그인:

- **Google Sign-In**: `google_sign_in` 패키지 → Supabase `signInWithIdToken(provider: OAuthProvider.google)`
- **Apple Sign-In**: `sign_in_with_apple` 패키지 → nonce 생성 + SHA256 해싱 → Supabase `signInWithIdToken(provider: OAuthProvider.apple)` (iOS only)
- **로그아웃 / 계정 삭제**: Supabase Auth API 사용

Apple Sign-In 설정 필요 항목:
1. Apple Developer Console → App ID에 Sign In with Apple capability 활성화
2. Apple Developer → Keys → Sign In with Apple 키 생성 (.p8)
3. Supabase Dashboard → Authentication → Providers → Apple 활성화 (Service ID, Secret Key, Key ID, Team ID)

## Firebase

Firebase 프로젝트: `smart-budget-book`

- `firebase_options.dart`는 `flutterfire configure`로 자동 생성 (커밋 대상)
- `main.dart`에서 `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` 호출
- Android: `com.google.gms.google-services` Gradle 플러그인 적용됨

현재 활성화된 서비스:
- **Analytics**: `AnalyticsService` 싱글턴 (`core/services/analytics_service.dart`)
- **Crashlytics**: 미구현
- **FCM**: 미구현

## Development Conventions

- **TDD strictly enforced** — write tests before implementation. Test structure mirrors `lib/` under `test/unit/`, `test/widget/`, `test/integration/`.
- **Environment variables** loaded from `.env` via `flutter_dotenv`. Never hardcode secrets.
- **Localization**: Korean and English UI with future Japanese expansion. Use `intl` or `easy_localization` with ARB files.
- **Code generation**: Use `freezed` for immutable models, `json_serializable` for serialization, `drift` for local DB schema, `go_router_builder` for type-safe routes.

## Development Phases

- **Phase 1 (MVP)**: Manual transaction input, account management, balance dashboard, monthly reports, onboarding with presets
- **Phase 2**: AI text/voice input (Gemini), OCR receipts (ML Kit), offline mode (Drift sync), multi-currency, data export
- **Phase 3**: Card payment reminders, bank API integration, Korea localization
