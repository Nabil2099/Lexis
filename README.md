# Lexis

**Offline Knowledge Vault**

Capture anything. Organize your mind. Keep it private.

Lexis is a private, offline-first knowledge vault for notes, ideas, tasks,
journal entries, references, and code snippets. It is built with Flutter and
stores data locally with Hive, so the app works without a backend, account, or
internet connection.

## What Lexis Is

Lexis is designed to be a calm workspace for personal thinking. It is not just a
basic notes list. The app helps you quickly capture information, organize it
into spaces and tags, search it locally, pin important items, archive old work,
and restore deleted items from trash.

Main workflow:

```txt
Capture -> Organize -> Retrieve -> Review
```

## Core Features

- **Vault dashboard** for quick capture, pinned items, recent items, and smart
  note-type filters.
- **Knowledge item types** for notes, ideas, tasks, journal entries, references,
  and code snippets.
- **Markdown editor** with preview mode and word count.
- **Spaces** for high-level organization.
- **Tags** for connecting related ideas across spaces.
- **Local search** with filters for type, space, tag, and pinned items.
- **Pin, archive, trash, restore, and permanent delete** flows.
- **Settings** for true black mode, markdown preview defaults, delete
  confirmation, and word count visibility.
- **Dark teal visual system** built for a focused private workspace.

## Tech Stack

- Flutter
- Riverpod
- GoRouter
- Hive / Hive Flutter
- Flutter Markdown
- UUID
- Google Fonts

## Project Structure

Lexis uses a feature-first architecture:

```txt
lib/
  main.dart
  app/
    app_bootstrap.dart
    lexis_app.dart

  core/
    local_storage/
    router/
    theme/
    utils/

  shared/
    widgets/

  features/
    vault/
    notes/
      domain/
      data/
      presentation/
    spaces/
    tags/
    search/
    archive/
    trash/
    settings/
```

The main dependency flow is:

```txt
UI
  -> Riverpod controllers
  -> repository contracts
  -> Hive datasources
  -> Hive boxes
```

Domain entities stay independent from Hive. Widgets do not access Hive directly.

## Local Storage

Lexis stores everything on the device using Hive.

Hive boxes:

- `notes_box`
- `spaces_box`
- `tags_box`
- `settings_box`
- `search_index_box`
- `trash_box`

All primary IDs are UUID strings. The current app uses Hive-only storage and
does not import older Drift/SQLite development data.

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

## Development Commands

Format the project:

```bash
dart format .
```

Analyze the code:

```bash
flutter analyze
```

Run tests:

```bash
flutter test --timeout 30s
```

Build for web:

```bash
flutter build web
```

Run code generation if generators are added or changed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Screens

- Vault
- Search
- Spaces
- Tags
- Note editor
- Archive
- Trash
- Settings

## Screenshots

Screenshots are coming soon.

## Roadmap

Planned future improvements:

- Export/import JSON
- Encrypted Hive boxes
- Biometric lock
- Daily notes
- Backlinks
- Calendar view
- Attachments
- Optional AI summarization
- Cloud sync

## Project Status

Lexis is currently a local-first Flutter app with a Hive data layer, feature-first
structure, and a polished dark UI. It is intended to remain private and usable
offline by default.
