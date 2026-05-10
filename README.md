# Lexis

**Offline Knowledge Vault**

Capture anything. Organize your mind. Keep it private.

Lexis is a private, offline-first knowledge vault for notes, ideas, tasks,
journal entries, references, and code snippets. It is built with Flutter,
Riverpod, GoRouter, and Hive, with all user data stored locally on the device.
There is no backend requirement, no account system, and no internet dependency.

## What Lexis Does

Lexis is designed to feel like a calm personal workspace rather than a generic
notes list. It helps you capture thoughts quickly, organize them into spaces and
tags, retrieve them through local search, and keep your knowledge private.

Core workflow:

```txt
Capture -> Organize -> Retrieve -> Review
```

Lexis is useful for:

- Personal notes and thinking
- Project ideas
- Tasks and lightweight planning
- Journal entries
- Saved references
- Code snippets
- Offline knowledge management

## Current Features

### Vault Dashboard

- Home screen built around a private vault workflow.
- Quick capture for fast note entry.
- Pinned items section.
- Recently updated section.
- All notes section.
- Smart filters for notes, ideas, tasks, pinned items, and recent items.

### Knowledge Items

Lexis stores more than plain notes. Each item can be one of:

- Note
- Idea
- Task
- Journal
- Reference
- Code snippet

Each item supports:

- Title
- Markdown content
- Plain text preview
- Word count
- Summary
- Type
- Status
- Pinning
- Archiving
- Trash / restore
- Spaces
- Tags
- Backlinks through `[[Note Title]]` links
- Attachment metadata
- Daily note date metadata

### Offline Smart Assist

Lexis includes a private, offline Smart Assist layer. It does not call an API
and does not send note content anywhere.

After saving a note, Smart Assist can:

- Generate a title for empty or untitled notes.
- Generate a concise summary from the note content.
- Suggest matching existing tags.
- Show tag suggestions for explicit user approval before applying them.

Smart Assist is deterministic and local-first. It is meant to make Lexis feel
more intelligent while preserving privacy.

Smart Assist settings include:

- Enable or disable Smart Assist.
- Auto-title empty notes.
- Generate summaries.
- Suggest matching tags.
- Regenerate suggestions manually from the note editor.

### Markdown Editor

- Calm dark writing surface.
- Markdown editing.
- Markdown preview toggle.
- Word count.
- Updated timestamp.
- Pin and archive actions.
- Space and tag organization.
- Attachment metadata list.
- Backlink count when the note links to other notes.
- Manual Smart Assist regeneration.

### Daily Notes

- Open today's daily note from the Vault.
- Create one canonical journal note per date.
- Store daily notes with stable `YYYY-MM-DD` metadata.
- Reopen the same daily note instead of creating duplicates.

### Backlinks

- Parse wiki-style links such as `[[Project Plan]]`.
- Resolve links to existing note titles.
- Store linked note IDs on the source note.
- Rebuild backlinks during JSON import.

### Attachments

- Add files from the note editor.
- Store attachment metadata in Hive.
- Link attachment IDs to notes.
- Remove attachment metadata from notes.
- Include attachment metadata in JSON backups.

### Spaces

Spaces are high-level containers for organizing knowledge.

- Create spaces.
- Rename spaces.
- Archive or remove spaces.
- View note counts.
- Open notes inside a space.

### Tags

Tags connect related ideas across spaces.

- Create tags.
- Rename tags.
- Assign tags to notes.
- Delete tags.
- View note counts.
- Use tags in search and filtering.

### Search

Search is fully local and works without a server.

- Full-text note search.
- Filter by note type.
- Filter by space.
- Filter by tag.
- Filter pinned items.
- Ranked results based on title, content, recency, and pinning.

### Archive And Trash

- Archive old notes without deleting them.
- Restore archived notes.
- Move notes to trash.
- Restore deleted notes.
- Permanently delete notes.
- Empty trash.

### Settings

- True black mode.
- Markdown preview default.
- Delete confirmation.
- Word count visibility.
- Smart Assist controls.
- Archive and trash shortcuts.
- JSON export/import.
- Merge or replace from backup.
- Biometric app lock setting.
- Encryption key preparation.
- Cloud sync-ready setting.
- Clear all local data.

## Design Direction

Lexis uses a dark, focused visual system:

- Near-black background
- Dark teal primary color
- Cyan highlights
- Subtle borders
- Rounded cards
- Minimal navigation
- Calm typography
- No bright or noisy interface patterns

The goal is a premium private workspace that feels fast, quiet, and useful.

## Tech Stack

- Flutter
- Riverpod
- GoRouter
- Hive / Hive Flutter
- Flutter Markdown
- File Picker
- Share Plus
- Flutter Secure Storage
- Local Auth
- Google Fonts
- UUID
- Intl

## Architecture

Lexis uses a feature-first architecture with clear separation between UI,
controllers, domain models, repositories, and Hive-backed data sources.

```txt
lib/
  main.dart
  app/
    app_bootstrap.dart
    lexis_app.dart

  core/
    local_storage/
    router/
    sync/
    theme/
    utils/

  shared/
    widgets/

  features/
    ai_assist/
    attachments/
    backup/
    daily_notes/
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
    security/
    sync/
    settings/
```

Main dependency flow:

```txt
UI
  -> Riverpod controllers
  -> repository contracts
  -> Hive datasources
  -> Hive boxes
```

Important architecture rules:

- Widgets do not access Hive directly.
- Domain entities are independent from Hive.
- IDs are UUID strings.
- The app runs offline by default.
- Smart Assist is local and does not use cloud AI.
- Backup/import is versioned JSON.
- Cloud sync is currently sync-ready local metadata, not a connected provider.

## Local Storage

Lexis stores app data in Hive boxes:

- `notes_box`
- `spaces_box`
- `tags_box`
- `settings_box`
- `search_index_box`
- `trash_box`
- `attachments_box`
- `sync_queue_box`

The current implementation is Hive-only. Older Drift/SQLite development storage
is not used.

Privacy status:

- Hive remains the local database.
- A device-secured encryption key can be prepared with secure storage.
- Full encrypted-box migration is intentionally conservative so existing local
  data is not destroyed.
- Biometric/device authentication can lock the app on supported platforms.

## Launch Readiness

Lexis is ready as a strong local-first MVP or beta release.

The app already has:

- A complete Hive-backed data layer.
- Note creation and editing.
- Spaces and tags.
- Search and filters.
- Archive and trash.
- Settings.
- Offline Smart Assist.
- JSON backup export/import.
- Daily notes.
- Backlink parsing.
- Attachment metadata.
- Biometric app lock UI.
- Sync-ready local change queue.
- Polished dark UI.
- Tests for core utilities, Hive note models, settings, search, and Smart
  Assist, backups, daily notes, backlinks, and sync records.

Before a public app-store launch, the remaining polish should be:

- Add real screenshots.
- Finalize app icon assets for every platform.
- Complete full encrypted-box migration after broader device QA.
- Add real cloud sync provider connection.
- Test on multiple physical Android/iOS devices.
- Review accessibility on small screens.
- Add release signing and store metadata.

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

Run code generation if generated files are changed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Screens

- Vault
- Search
- Spaces
- Space notes
- Tags
- Tag notes
- Note editor
- Archive
- Trash
- Settings
- Daily note route

## Screenshots

Screenshots are coming soon.

Suggested screenshots:

- Vault dashboard
- Note editor
- Search with filters
- Spaces
- Tags
- Settings with Smart Assist
- Daily note
- JSON backup/import settings

## Roadmap

Good next features:

- Full encrypted Hive migration toggle
- Real cloud sync provider
- Backup ZIP export with attachment file payloads
- Calendar view
- Attachment preview/open actions
- Better tag recommendation controls
- Optional cloud AI provider with explicit privacy controls
- Backlink graph view

## Project Status

Lexis is a private, offline-first Flutter knowledge vault with a real local data
layer, structured architecture, polished dark UI, and useful core workflows. It
is not just a Flutter template or a simple notes demo anymore. It is ready for
hands-on testing, iteration, and beta packaging.
