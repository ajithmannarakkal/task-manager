# Task Manager - Flutter Clean Architecture Demo

## Architectural Reasoning

This project implements **Feature-First Clean Architecture** combined with **Riverpod** for state management.

### why this stack?
1.  **Clean Architecture**: Separates concerns into Domain (Business Logic), Data (Repository Implementation, Data Store), and Presentation (UI, State). This makes the app testable, maintainable, and independent of external frameworks.
2.  **Feature-First**: Organizes code by feature (`auth`, `tasks`) rather than layer (`controllers`, `views`). This scales better for larger teams, as developers can work on a feature in isolation without merge conflicts in shared folders.
3.  **Riverpod**: detailed below.

### Layer Separation
-   **Domain**: Pure Dart. Contains `Entity`, `Repository Interface`, and `UseCase`. No Flutter dependencies.
-   **Data**: Implementation details. Contains `DTO` (Data Transfer Objects), `RemoteDataSource` (API calls), and `Repository Implementation`.
-   **Presentation**: Flutter widgets and Riverpod Providers.

### Error Handling
We use a functional programming approach with a sealed `Result<T, Failure>` class.
-   **Why?**: It forces the UI to handle both success and failure states (compiler error if you miss one).
-   **No Exceptions**: We catch exceptions in the Repository layer and map them to domain `Failures`.

## State Management (Riverpod)

Riverpod was chosen over Bloc or Provider because:
-   **Compile-time safety**: No `ProviderNotFoundException`.
-   **Dependency Injection**: It couples state management with DI, making it effortless to inject UseCases into Notifiers.
-   **Testing**: `ProviderContainer` allows overriding any provider in tests easily.
-   **AsyncNotifier**: Built-in handling of loading/error/data states reduces boilerplate significantly compared to Bloc.

## Key Assumptions & Key Decisions

1.  **Mock Backend**: A singleton `MockDatabase` simulates a REST API with random latency (300-1000ms) and random errors (5% chance) to demonstrate robust error handling in the UI.
2.  **Optimistic Updates**: Use cases like `updateTaskStatus` verify the optimistic UI update pattern (update local state immediately, revert if server fails).
3.  **Authentication**: Simple session persistence logic is mocked. In a real app, we'd use `flutter_secure_storage` to persist tokens.

## Scalability

This architecture scales well because:
1.  **Independent Features**: A new feature (e.g., "Chat") can be added as a new folder without touching existing code.
2.  **Testability**: core logic (UseCases) is unit-testable without UI or database.
3.  **Replaceable Data Layer**: The `MockDataSource` can be swapped for a `FirebaseDataSource` or `RestApiDataSource` by changing **one line** in the provider definition, without changing any UI or Domain logic.

## Interview Q&A

**Q: Why use UseCases if they just call the Repository?**
A: While simple pass-throughs seem redundant, UseCases provide a consistent API for the ViewModels. They also become the place to put domain logic that involves multiple repositories (e.g., `DeleteUser` might need to clear `AuthRepo`, `TaskRepo`, and `ImageRepo`).

**Q: How would you handle offline support?**
A: I would introduce a `LocalDataSource` (using Hive or Drift) in the Data Layer. The Repository would fetch from LocalMock first, then sync with Remote. The Domain layer wouldn't change.

**Q: Why manual Dependency Injection (RepositoryImpl) instead of GetIt?**
A: Riverpod *is* a DI framework. Using `ref.watch` keeps dependencies explicit and reactive. If a dependency changes (e.g., user logs out), dependent providers automatically rebuild.

## Folder Structure
```
lib/
├── core/
│   ├── error/       # Result, Failure
│   ├── usecases/    # UseCase interface
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   ├── tasks/
│       ├── data/
│       ├── domain/
│       ├── presentation/
└── main.dart
```
