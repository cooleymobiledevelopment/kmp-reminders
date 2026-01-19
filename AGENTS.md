# Reminders App - Development Guide

## App Overview

A cross-platform reminders app with custom snooze, powerful recurrence patterns, and real-time cross-device sync. Built with Kotlin Multiplatform targeting Android and iOS.

## Project Structure

```
brief-1-reminders/
├── composeApp/                    # Shared KMP module + Android app
│   ├── src/
│   │   ├── commonMain/kotlin/     # Shared Kotlin code
│   │   │   └── com/cooleymd/reminders/
│   │   ├── commonTest/kotlin/     # Shared tests
│   │   ├── androidMain/kotlin/    # Android-specific code
│   │   └── iosMain/kotlin/        # iOS-specific code (controllers)
│   └── build.gradle.kts
├── iosApp/                        # iOS app (SwiftUI)
│   └── iosApp/
│       ├── ContentView.swift
│       └── iOSApp.swift
├── backend/                       # Ktor server (to be added)
├── specs/                         # Feature specifications
├── IMPLEMENTATION_PLAN.md         # Task tracking
└── loop.sh                        # Ralph loop orchestrator
```

## Tech Stack

### Shared (KMP)
- **SQLDelight** - Type-safe local database
- **Ktor Client** - HTTP networking
- **Kotlinx.serialization** - JSON parsing
- **Kotlinx.datetime** - Cross-platform date/time
- **Kotlinx.coroutines** - Async operations, Flow
- **Koin** - Dependency injection

### Android
- **Jetpack Compose** - UI framework
- **Material 3** - Design system
- **WorkManager** - Background notification scheduling
- **AlarmManager** - Precise notification timing

### iOS
- **SwiftUI** - UI framework
- **UserNotifications** - Local notifications
- **Combine** - Reactive bindings to KMP flows

### Backend (when added)
- **Ktor Server** - REST API
- **PostgreSQL** - Database
- **Exposed** - Kotlin SQL framework
- **JWT** - Authentication

## Commands

```bash
# Build everything
./gradlew build

# Run all tests
./gradlew check

# Run Android app (requires emulator/device)
./gradlew :composeApp:installDebug

# Clean build
./gradlew clean build

# Run specific test class
./gradlew :composeApp:testDebugUnitTest --tests "com.cooleymd.reminders.*"
```

## Architecture Patterns

### Clean Architecture Layers
1. **Data Layer** (`data/`)
   - Repositories (interface + implementation)
   - Data sources (local SQLDelight, remote Ktor)
   - DTOs and mappers

2. **Domain Layer** (`domain/`)
   - Use cases (single responsibility)
   - Domain models
   - Business logic

3. **Presentation Layer** (`presentation/`)
   - ViewModels (expose StateFlow)
   - UI state classes
   - Navigation

### Code Organization
```
com.cooleymd.reminders/
├── data/
│   ├── local/           # SQLDelight database
│   ├── remote/          # Ktor API client
│   └── repository/      # Repository implementations
├── domain/
│   ├── model/           # Domain entities
│   ├── repository/      # Repository interfaces
│   └── usecase/         # Business logic
├── presentation/
│   ├── home/            # Home screen
│   ├── edit/            # Add/edit reminder
│   └── settings/        # Settings screen
└── di/                  # Koin modules
```

### Platform-Specific Code

Use `expect`/`actual` for platform differences:

```kotlin
// commonMain
expect class NotificationScheduler {
    fun schedule(reminder: Reminder)
    fun cancel(reminderId: String)
}

// androidMain
actual class NotificationScheduler {
    actual fun schedule(reminder: Reminder) {
        // Use WorkManager/AlarmManager
    }
}

// iosMain
actual class NotificationScheduler {
    actual fun schedule(reminder: Reminder) {
        // Bridge to Swift UNUserNotificationCenter
    }
}
```

## Testing Strategy

- **Unit tests** in `commonTest/` for business logic
- **Repository tests** with fake data sources
- **ViewModel tests** with fake use cases
- Tests must pass before committing: `./gradlew check`

## Key Conventions

1. **Immutable data classes** for all models
2. **Repository pattern** for data access
3. **Use cases** encapsulate single business operations
4. **StateFlow** for UI state in ViewModels
5. **Sealed classes** for UI events and states
6. **Coroutines** for async operations (no callbacks)

## Dependencies to Add

When implementing features, add these to `composeApp/build.gradle.kts`:

```kotlin
// SQLDelight
sqldelight("app.cash.sqldelight:runtime:2.0.1")
sqldelight("app.cash.sqldelight:coroutines-extensions:2.0.1")

// Ktor Client
implementation("io.ktor:ktor-client-core:2.3.7")
implementation("io.ktor:ktor-client-content-negotiation:2.3.7")
implementation("io.ktor:ktor-serialization-kotlinx-json:2.3.7")

// Koin
implementation("io.insert-koin:koin-core:3.5.3")
implementation("io.insert-koin:koin-compose:1.1.2")

// DateTime
implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.5.0")
```

## Git Workflow

- One commit per completed task
- Commit message format: `feat(scope): description`
- Always run `./gradlew check` before committing
- Push after each successful commit
