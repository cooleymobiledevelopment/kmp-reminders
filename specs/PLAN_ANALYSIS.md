# Plan Analysis: KMP Reminders App

**Document Purpose**: Reference document capturing architecture decisions, gaps analysis, and recommendations for the Reminders app implementation.

**Created**: 2026-01-19

---

## Architecture Overview

The plan consists of 34 spec files organized into 6 feature groups:

| Group | Focus | Specs Count |
|-------|-------|-------------|
| F0.x | Foundation | 4 |
| F1.x | Domain Layer | 5 |
| F2.x | Android UI | 5 |
| F3.x | iOS UI | 5 |
| F4.x | Notifications | 4 |
| F5.x | Backend/Sync | 5 |
| F6.x | Monetization | 4 |
| F7.x | Testing | 1 |

---

## Technology Stack

### Shared (KMP)
- **Database**: SQLDelight 2.0.1 - Type-safe SQL with Kotlin code generation
- **DI**: Koin 3.5.3 - Lightweight DI framework with multiplatform support
- **Networking**: Ktor 2.3.7 - Kotlin-first HTTP client
- **Serialization**: kotlinx.serialization 1.6.2
- **Date/Time**: kotlinx-datetime - Cross-platform date/time handling
- **UUID**: kotlinx-uuid - Cross-platform UUID generation

### Android
- **UI**: Jetpack Compose with Material 3
- **Navigation**: Compose Navigation 2.7.6
- **Notifications**: AlarmManager + NotificationCompat
- **Secure Storage**: EncryptedSharedPreferences

### iOS
- **UI**: Native SwiftUI (not Compose Multiplatform)
- **Navigation**: NavigationStack + TabView
- **Notifications**: UserNotifications framework
- **Secure Storage**: Keychain Services

### Backend
- **Server**: Ktor Server with Netty
- **Database**: PostgreSQL 16 via Exposed ORM
- **Auth**: JWT with refresh tokens
- **Containerization**: Docker + Docker Compose

### Monetization
- **IAP Management**: RevenueCat SDK
- **Products**: Monthly ($4.99) and Annual ($39.99) subscriptions
- **Entitlement**: "premium"

---

## Strengths of the Plan

### 1. Clean Architecture
- Proper separation: domain/data/presentation layers
- Dependency inversion via interfaces
- Use cases encapsulate business logic

### 2. Platform-Appropriate UI Decisions
- Uses Compose for Android (native, performant)
- Uses SwiftUI for iOS (better UX than forcing Compose Multiplatform)
- Maximizes shared business logic while respecting platform conventions

### 3. Comprehensive Sync Architecture
- Offline-first with local SQLite storage
- Change tracking with sync status enum
- Conflict detection and resolution strategies
- Secure token storage per platform

### 4. Well-Defined Dependencies
- Each spec lists prerequisites
- Enables parallel work streams
- Clear sequencing for implementation

### 5. Detailed Implementation Guidance
- Code snippets for key components
- File paths specified
- Verification steps included

---

## Gaps Identified

### Critical (Should Address)

| Gap | Impact | Recommendation |
|-----|--------|----------------|
| Schema Migrations | Breaking changes on updates | Add SQLDelight migration strategy in F0.2 |
| Error Handling | Poor UX on failures | Add error handling patterns document |
| E2E Testing | Quality assurance | Added F7.1 for Maestro tests |

### Important (Should Consider)

| Gap | Impact | Recommendation |
|-----|--------|----------------|
| Background Sync | Stale data | Add WorkManager/BGTaskScheduler specs |
| Accessibility | Excludes users | Add a11y requirements to UI specs |
| Localization | Limited market | Add i18n infrastructure spec |

### Nice to Have (Future)

| Gap | Impact | Recommendation |
|-----|--------|----------------|
| Widgets | Engagement feature | Add widget specs post-MVP |
| Analytics | No usage insights | Add analytics integration spec |
| Deep Linking | Limited sharing | Add URL scheme handling |
| Onboarding | Learning curve | Add first-run experience spec |

---

## Technical Concerns Addressed

### 1. UUID Generation (F1.4)
**Issue**: Original spec used `java.util.UUID` which isn't available on iOS.
**Fix**: Updated to use `com.benasher44:uuid` (kotlinx-uuid) for cross-platform compatibility.

### 2. Android Doze Mode (F4.1)
**Issue**: AlarmManager alarms can be unreliable during Doze mode.
**Fix**: Added `setExactAndAllowWhileIdle()` usage, WorkManager fallback for non-critical reminders, and documentation about battery optimization whitelisting.

### 3. iOS Keychain Implementation (F5.4)
**Issue**: Used outdated Kotlin/Native memory model patterns.
**Fix**: Updated to use modern `@ObjCName` annotations and proper memory management without deprecated `alloc<>` patterns.

### 4. RevenueCat SDK Versions (F6.1)
**Issue**: SDK versions may be outdated.
**Fix**: Updated to RevenueCat Purchases 8.x (Android) and 5.x (iOS) with notes to verify latest versions before implementation.

---

## Implementation Sequencing

### Recommended Wave Approach

```
Wave 1: Foundation (can be done quickly)
├── F0.1: KMP Project Setup
├── F0.2: SQLDelight Setup
├── F0.3: Koin DI Setup
└── F0.4: Ktor Client Setup

Wave 2: Domain Layer
├── F1.1: Reminder Model & Repository
├── F1.2: Recurrence Rule Model
├── F1.3: Label Model & Repository
├── F1.4: Use Cases - CRUD
└── F1.5: Use Cases - Reminder Logic

Wave 3: Basic UI (parallel tracks)
├── Android Track: F2.1 → F2.2
└── iOS Track: F3.1 → F3.2

Wave 4: Full UI (parallel tracks)
├── Android Track: F2.3 → F2.4 → F2.5
└── iOS Track: F3.3 → F3.4 → F3.5

Wave 5: Notifications
├── F4.1: Android Notifications Basic
├── F4.2: Android Notification Actions
├── F4.3: iOS Notifications Basic
└── F4.4: iOS Notification Actions

Wave 6: Backend & Sync
├── F5.1: Backend Setup
├── F5.2: Backend Auth
├── F5.3: Backend Reminder API
├── F5.4: Client Sync Upload
└── F5.5: Client Sync Download

Wave 7: Monetization
├── F6.1: RevenueCat Setup
├── F6.2: Paywall Implementation
├── F6.3: Premium Feature Gating
└── F6.4: Polish & Edge Cases

Wave 8: Testing (ongoing)
└── F7.1: Maestro E2E Tests
```

### Parallelization Opportunities

- Android UI (F2.x) and iOS UI (F3.x) can be developed in parallel after Wave 2
- Backend (F5.1-F5.3) can start during Wave 3 if backend developer available
- E2E tests (F7.1) can begin once basic UI is functional

---

## Free vs Premium Feature Matrix

| Feature | Free | Premium |
|---------|------|---------|
| Reminders | 10 max | Unlimited |
| Labels | 3 max | Unlimited |
| Recurrence | Yes | Yes |
| Notifications | Yes | Yes |
| Cloud Sync | No | Yes |
| Custom Themes | No | Yes |
| Priority Support | No | Yes |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| SQLDelight schema changes break existing data | Medium | High | Implement migrations from start |
| iOS notification permissions denied | High | Medium | Graceful degradation, explain value |
| RevenueCat sandbox testing issues | Medium | Medium | Test early, document setup |
| Sync conflicts confuse users | Medium | Medium | Clear UI for conflict resolution |
| Doze mode delays notifications | Medium | High | Document battery optimization |

---

## Open Questions

1. **Push Notifications**: Should we add push notification support for server-triggered reminders?
2. **Shared Reminders**: Is collaborative/shared reminder functionality planned?
3. **Siri/Google Assistant**: Should we add voice assistant integrations?
4. **Watch Apps**: Are watchOS/Wear OS companion apps in scope?
5. **Data Export**: Should users be able to export their reminders?

---

## Version History

| Date | Changes |
|------|---------|
| 2026-01-19 | Initial analysis document created |
| 2026-01-19 | Added F7.1 Maestro E2E testing spec |
| 2026-01-19 | Updated F1.4, F4.1, F5.4, F6.1 per technical concerns |
