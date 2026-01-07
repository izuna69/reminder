# Gemini Project Context: Reminder App

## Project Overview

This is a mobile-first "Reminder" application built with Flutter. Its primary purpose is to allow users to create, manage, and receive notifications for their to-do items.

The project was bootstrapped from a standard Flutter template and has since evolved to include several key features. It was initially designed with a local `sqflite` database for persistence, but was later refactored to use a temporary, in-memory data store at the user's request. **This means all tasks are lost when the app is closed.**

### Key Technologies & Libraries

*   **Framework:** Flutter
*   **Language:** Dart
*   **State Management:** `flutter_riverpod` using the `StateNotifier` pattern. The state is managed in-memory.
*   **Local Notifications:** `flutter_local_notifications` for scheduling reminders.
*   **Home Screen Widget:** `home_widget` for displaying tasks on the Android home screen.
*   **Internationalization/Formatting:** `intl` for date formatting.
*   **Theming:** Supports light and dark mode switching.

### Architecture

The application follows a clean, provider-based architecture, separating concerns into different layers:

*   `lib/models`: Contains the core data structure (`Task`, `ChecklistItem`). Models are immutable.
*   `lib/providers`: Holds the Riverpod notifiers (`TaskListNotifier`, `ThemeNotifier`) that manage the application's state.
*   `lib/screens`: Contains the main UI widgets for each screen (`HomeScreen`, `AddEditTaskScreen`).
*   `lib/services`: Encapsulates logic for external interactions, like scheduling notifications (`NotificationService`) and updating the home screen widget (`WidgetService`).
*   `docs/`: Contains project planning documents in Korean.

## Building and Running

This is a standard Flutter project.

1.  **Get Dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Run the App:**
    Connect a device or start an emulator, then run:
    ```bash
    flutter run
    ```

3.  **Run Tests:**
    The project contains a default widget test.
    ```bash
    flutter test
    ```

4.  **Build the App:**
    To build a release version for Android, use:
    ```bash
    flutter build apk
    ```
    Or for an App Bundle:
    ```bash
    flutter build appbundle
    ```

## Development Conventions

*   **State Management:** Use `flutter_riverpod`. For managing a list of items, follow the pattern in `TaskListNotifier` (`StateNotifier<List<Task>>`).
*   **Data Models:** Models in `lib/models` should be immutable (annotated with `@immutable`) and include a `copyWith` method.
*   **No Persistence:** Per user request, the project currently **does not** have a persistence layer. All data is managed in-memory by `TaskListNotifier` and will be lost on app restart. Future persistence logic should be integrated into the existing notifiers.
*   **Platform-Specific Code:** Features that are not web-compatible (like local notifications and `sqflite` FFI initialization for desktop) are guarded with `if (!kIsWeb)`.
*   **Language:** UI text is in Korean. Code, comments, and variable names are in English.
