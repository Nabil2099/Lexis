# Lexis — Full Project Scaffold Prompt

> Paste this entire prompt into Cursor (composer), GitHub Copilot chat, or any AI coding assistant.

---

## RULES (follow strictly, no exceptions)

- **Riverpod 3.x only** — use `@riverpod` code-gen for every provider. Never use `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`, or `FamilyNotifier`. These are legacy and forbidden.
- **Never use `.withOpacity()`** — always use `.withValues(alpha: x)` instead.
- **Never use `CardTheme`** — always use `CardThemeData`.
- **Never use `WillPopScope`** — always use `PopScope` with `onPopInvokedWithResult`.
- **Never use deprecated TextTheme names** (`headline1`, `bodyText1`, etc.) — use `displayLarge`, `bodyLarge`, `titleMedium`, etc.
- **Never use `FlatButton`, `RaisedButton`, `OutlineButton`** — use `TextButton`, `ElevatedButton`, `OutlinedButton`.
- **Always use `useMaterial3: true`** in ThemeData.
- **Dart SDK `^3.7.0`, Flutter `>=3.29.0`** — use Dart 3.x features: records, patterns, sealed classes, switch expressions.
- **Always use latest pub.dev versions** — never hardcode old versions from training data.
- **Always use `const` constructors** wherever possible.
- **Guard async gaps** with `ref.mounted` before mutating state.

---

## PROJECT OVERVIEW

**App name:** Lexis  
**Description:** An offline-first note-taking app with markdown support, folders, tags, pin/archive, full-text search, and an OLED dark minimal UI.  
**Backend:** Local only — Isar database, no internet required.  
**UI style:** OLED dark minimal — pure `#000000` background, subtle borders, clean typography, no gradients.

---

## TECH STACK

```yaml
environment:
  sdk: ^3.7.0
  flutter: ">=3.29.0"

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^3.3.0
  riverpod_annotation: ^4.0.2

  # Navigation
  go_router: ^15.0.0

  # Local database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0

  # Models
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # Markdown
  flutter_markdown: ^0.7.4

  # Utilities
  uuid: ^4.4.0
  intl: ^0.20.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  riverpod_generator: ^4.0.3
  isar_generator: ^3.1.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  custom_lint: ^0.7.0
  riverpod_lint: ^4.0.0
```

---

## FOLDER STRUCTURE

Generate the following folder structure with all files:

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── router/
│   │   └── app_router.dart
│   └── database/
│       └── isar_service.dart
├── features/
│   ├── notes/
│   │   ├── data/
│   │   │   ├── note_model.dart          ← Isar schema
│   │   │   └── notes_repository.dart
│   │   ├── presentation/
│   │   │   ├── notifiers/
│   │   │   │   └── notes_notifier.dart  ← @riverpod
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── editor_screen.dart
│   │   │   └── widgets/
│   │   │       ├── note_card.dart
│   │   │       └── note_grid.dart
│   ├── folders/
│   │   ├── data/
│   │   │   ├── folder_model.dart        ← Isar schema
│   │   │   └── folders_repository.dart
│   │   ├── presentation/
│   │   │   ├── notifiers/
│   │   │   │   └── folders_notifier.dart
│   │   │   └── screens/
│   │   │       └── folders_screen.dart
│   ├── tags/
│   │   ├── data/
│   │   │   ├── tag_model.dart           ← Isar schema
│   │   │   └── tags_repository.dart
│   │   ├── presentation/
│   │   │   ├── notifiers/
│   │   │   │   └── tags_notifier.dart
│   │   │   └── widgets/
│   │   │       └── tag_chip.dart
│   └── search/
│       └── presentation/
│           ├── notifiers/
│           │   └── search_notifier.dart
│           └── screens/
│               └── search_screen.dart
└── shared/
    └── widgets/
        ├── empty_state.dart
        └── confirmation_dialog.dart
```

---

## DATA MODELS

### Note (Isar schema)
```dart
// lib/features/notes/data/note_model.dart
@collection
class Note {
  Id id = Isar.autoIncrement;
  late String uuid;
  late String title;
  late String content;           // raw markdown
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isPinned = false;
  bool isArchived = false;
  int? folderId;                 // nullable — note can be outside any folder
  final tags = IsarLinks<Tag>(); // many-to-many
}
```

### Folder (Isar schema)
```dart
@collection
class Folder {
  Id id = Isar.autoIncrement;
  late String name;
  late DateTime createdAt;
  @Backlink(to: 'folderId')
  final notes = IsarLinks<Note>();
}
```

### Tag (Isar schema)
```dart
@collection
class Tag {
  Id id = Isar.autoIncrement;
  late String name;
  late String colorHex;          // e.g. "#FF5733"
}
```

---

## FEATURES TO IMPLEMENT

### 1. Home Screen
- **Two view modes:** grid and list — toggled via icon in AppBar.
- **Sort order:** pinned notes always first, then by `updatedAt` descending.
- **Sections:** "Pinned" section header (only visible if there are pinned notes), then "Notes".
- **FAB:** creates a new note and navigates to `EditorScreen`.
- **Swipe actions on note card:** swipe left to delete (with confirmation), swipe right to pin/unpin.
- **Long press:** shows bottom sheet with options: Pin/Unpin, Move to Folder, Archive, Delete.
- **Empty state:** centered icon + "No notes yet. Tap + to create one."

### 2. Editor Screen
- **Split mode toggle:** switch between Edit (raw markdown `TextField`) and Preview (`MarkdownBody`).
- **Auto-save:** debounced 800ms after last keystroke — no save button needed.
- **AppBar actions:** pin toggle icon, tag picker icon, folder picker icon, delete icon.
- **Title field:** large, borderless `TextField` at top.
- **Content field:** borderless `TextField` with monospace font, expands to fill screen.
- **Tag picker:** bottom sheet showing all tags as chips, multi-select. Option to create new tag inline.
- **Folder picker:** bottom sheet showing folder list, single select.

### 3. Search Screen
- **Real-time search:** queries Isar on every keystroke (debounced 300ms).
- **Searches in:** title and content fields.
- **Filters:** by tag (chip row below search bar), by folder (dropdown).
- **Results:** same `NoteCard` used in home, highlighted match text.
- **Empty state for no results:** "No notes match your search."

### 4. Folders Screen
- **List of folders** with note count badge.
- **Tap folder:** navigates to home filtered by that folder.
- **Create folder:** FAB or AppBar action, shows inline text field.
- **Delete folder:** swipe left — notes in that folder become unfoldered (not deleted).

### 5. Tags
- **Tag management** accessible from settings or tags bottom sheet.
- **Each tag** has a name and a color (pick from 8 preset colors).
- **Delete tag:** removes tag from all notes.

### 6. Archive
- **Archived notes** are hidden from home and search by default.
- **Archive screen** accessible from drawer/navigation — shows all archived notes.
- **Unarchive** from long-press menu.

---

## STATE MANAGEMENT PATTERNS

Use this exact pattern for every notifier:

```dart
// Example: notes_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'notes_notifier.g.dart';

@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  Future<List<Note>> build() async {
    return ref.watch(notesRepositoryProvider).watchAllNotes();
  }

  Future<void> createNote(String title, String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notesRepositoryProvider).createNote(title, content);
      return ref.read(notesRepositoryProvider).getAllNotes();
    });
  }

  Future<void> togglePin(int noteId) async {
    // optimistic update then persist
  }

  Future<void> deleteNote(int noteId) async {
    if (!ref.mounted) return;
    // ...
  }
}
```

---

## THEME (OLED DARK MINIMAL)

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  static const background   = Color(0xFF000000); // true OLED black
  static const surface      = Color(0xFF0D0D0D); // cards
  static const surfaceHigh  = Color(0xFF1A1A1A); // elevated surfaces
  static const border       = Color(0xFF2A2A2A); // subtle dividers
  static const primary      = Color(0xFFFFFFFF); // primary text
  static const secondary    = Color(0xFF8A8A8A); // secondary text
  static const hint         = Color(0xFF4A4A4A); // placeholder
  static const accent       = Color(0xFFE8E8E8); // interactive accent
  static const pinned       = Color(0xFFF5C542); // pin icon
  static const danger       = Color(0xFFFF4545); // delete actions
}

// lib/core/theme/app_theme.dart
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    surface: AppColors.surface,
    onSurface: AppColors.primary,
    primary: AppColors.accent,
    onPrimary: AppColors.background,
    error: AppColors.danger,
  ),
  cardTheme: CardThemeData(                      // ← CardThemeData, not CardTheme
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: AppColors.border, width: 0.5),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.primary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.border,
    thickness: 0.5,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    hintStyle: TextStyle(color: AppColors.hint),
  ),
);
```

---

## NAVIGATION (Go Router)

```dart
// Routes to implement:
// /                  → HomeScreen
// /note/new          → EditorScreen (new note)
// /note/:id          → EditorScreen (existing note)
// /search            → SearchScreen
// /folders           → FoldersScreen
// /folder/:id        → HomeScreen filtered by folder
// /archive           → ArchiveScreen

// Use StatefulShellRoute for bottom navigation:
// Tab 0: Home
// Tab 1: Search
// Tab 2: Folders
```

---

## ISAR SERVICE

```dart
// lib/core/database/isar_service.dart
// Singleton Isar instance, opened once in main()
// Provide via @riverpod provider: isarServiceProvider
// Open with all three schemas: NoteSchema, FolderSchema, TagSchema
```

---

## UI DETAILS

- **Note cards:** rounded 12px, 0.5px border, `AppColors.border`. Show: title (max 2 lines), content preview (max 3 lines, markdown stripped), date (relative: "2h ago", "Yesterday", full date if older), tag chips (max 3 visible, then "+N more"), pin icon if pinned.
- **No shadows anywhere** — use borders only, consistent with OLED minimal aesthetic.
- **Typography:** use `Theme.of(context).textTheme` with new Material 3 names. Title = `titleMedium`, body = `bodyMedium`, date = `labelSmall`.
- **Animations:** use `AnimatedSwitcher` for view mode toggle, `Hero` on note card → editor transition.
- **Bottom navigation:** `NavigationBar` (Material 3), 3 tabs: Notes, Search, Folders.

---

## WHAT TO GENERATE FIRST

Start with this order:

1. `pubspec.yaml` (with all dependencies above)
2. `lib/core/theme/app_colors.dart` and `app_theme.dart`
3. `lib/core/database/isar_service.dart`
4. All three Isar models (`note_model.dart`, `folder_model.dart`, `tag_model.dart`)
5. All three repositories
6. `lib/core/router/app_router.dart`
7. `lib/app.dart` and `lib/main.dart`
8. `HomeScreen` + `NoteCard` widget
9. `EditorScreen`
10. `SearchScreen`
11. `FoldersScreen`

Generate each file completely — no placeholders, no `// TODO`, no truncated code.

---

## UI DESIGN SPEC — ALL SCREENS

> This section defines the exact visual design for every screen. Follow it precisely. Do not deviate from spacing, colors, or component choices unless explicitly stated.

---

### DESIGN SYSTEM TOKENS

```dart
// Spacing scale (use only these values)
// 4, 8, 12, 16, 20, 24, 32, 48

// Border radius scale
// card:         12px
// chip/badge:   20px (pill)
// button:       10px
// bottom sheet: 20px top corners only
// input:        10px

// Typography scale (Material 3 names)
// Screen title:     titleLarge   — weight 600, size 22
// Section header:   titleSmall   — weight 500, size 14, letterSpacing 0.5, ALL CAPS
// Note title:       titleMedium  — weight 500, size 16
// Body / preview:   bodyMedium   — weight 400, size 14, color: AppColors.secondary
// Timestamp:        labelSmall   — weight 400, size 11, color: AppColors.hint
// Tag chip label:   labelSmall   — weight 500, size 11
// Empty state text: bodyMedium   — color: AppColors.hint

// Icon size
// AppBar icons:     22px
// Bottom nav:       24px
// Card actions:     18px
// Empty state icon: 56px, color: AppColors.hint
```

---

### GLOBAL LAYOUT RULES

- `Scaffold` background is always `AppColors.background` (`#000000`).
- `AppBar` has `elevation: 0`, `scrolledUnderElevation: 0`, background `#000000`. Never shows a shadow or color change on scroll.
- All lists use `CustomScrollView` with `SliverList` / `SliverGrid` so AppBar collapses smoothly.
- Bottom `NavigationBar`: background `#0D0D0D`, `indicatorColor: AppColors.surfaceHigh`, no elevation, `height: 64`. Icons only — no labels.
- `BottomSheet`s: background `AppColors.surface` (`#0D0D0D`), top corners rounded `20px`, drag handle `32x4px`, color `AppColors.border`, centered at top with `8px` top padding.
- Dividers: `0.5px`, color `AppColors.border`. Use `Divider` only between sections, never between list items.
- `SnackBar`: background `AppColors.surfaceHigh`, text `AppColors.primary`, no elevation, rounded `10px`.
- FAB: background `AppColors.primary` (white), icon color `AppColors.background` (black), size 56px, no shadow (`elevation: 0`), positioned bottom-right with `16px` margin.

---

### SCREEN 1 — HOME SCREEN

**AppBar:**
```
Left:   App name "Lexis" — titleLarge, weight 600
Right:  [search icon 22px] [view toggle icon 22px] [more_vert icon 22px]
        gap between icons: 4px
```

**View toggle:**
- Grid icon → switches to `SliverGrid`, crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8
- List icon → switches to `SliverList`
- Toggle animates with `AnimatedSwitcher`, duration 200ms

**Pinned section (only if pinned notes exist):**
```
SliverToBoxAdapter:
  Padding(horizontal: 16, vertical: 12)
    Text("PINNED", style: titleSmall, letterSpacing: 0.8, color: AppColors.hint)
SliverList or SliverGrid of pinned notes
SliverToBoxAdapter: Divider with 16px horizontal padding
```

**All notes section:**
```
SliverToBoxAdapter:
  Padding(horizontal: 16, top: 12, bottom: 8)
    Text("NOTES", style: titleSmall ...)
SliverList or SliverGrid of non-pinned, non-archived notes
```

**Note Card (List mode):**
```
Container(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border, width: 0.5),
  ),
  child: Padding(
    padding: EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(Text(note.title, style: titleMedium, maxLines: 2)),
            if (note.isPinned) Icon(Icons.push_pin, size: 14, color: AppColors.pinned)
          ]
        ),
        SizedBox(height: 6),
        Text(strippedPreview, style: bodyMedium, maxLines: 3, overflow: ellipsis),
        SizedBox(height: 10),
        Row(
          children: [
            // tag chips (max 3)
            ...note.tags.take(3).map((t) => TagChip(tag: t)),
            if (note.tags.length > 3) Text("+${note.tags.length - 3}", style: labelSmall),
            Spacer(),
            Text(relativeDate, style: labelSmall, color: AppColors.hint),
          ]
        )
      ]
    )
  )
)
```

**Note Card (Grid mode):**
- Same card, no content preview (title + tags + date only)
- Height: intrinsic (min ~100px)
- Pin icon top-right inside card

**Swipe actions (Dismissible):**
- Swipe LEFT → red background `AppColors.danger.withValues(alpha: 0.15)`, `Icons.delete_outline` icon right-aligned, delete with confirmation dialog
- Swipe RIGHT → amber background `AppColors.pinned.withValues(alpha: 0.1)`, pin icon left-aligned, toggles pin immediately

**Long press bottom sheet (options list):**
```
BottomSheet:
  drag handle
  Padding(16)
  ListTile: leading Icon(isPinned ? unpin : pin), title "Pin" / "Unpin"
  ListTile: leading Icon(folder_open), title "Move to folder"
  ListTile: leading Icon(archive), title "Archive"
  Divider
  ListTile: leading Icon(delete, color: danger), title "Delete", titleStyle: danger
```

**Empty state (no notes):**
```
Center(
  Column(
    Icon(Icons.note_outlined, size: 56, color: AppColors.hint),
    SizedBox(height: 16),
    Text("No notes yet", style: titleMedium, color: AppColors.secondary),
    SizedBox(height: 4),
    Text("Tap + to create one", style: bodyMedium, color: AppColors.hint),
  )
)
```

---

### SCREEN 2 — EDITOR SCREEN

**AppBar:**
```
Left:   Back arrow (auto)
Right:  [edit/preview toggle chip] [pin icon] [tag icon] [folder icon] [delete icon]
        All icons: 22px, color: AppColors.secondary
        Active pin icon color: AppColors.pinned
```

**Edit / Preview toggle (AppBar center or right):**
```
Container(
  decoration: BoxDecoration(
    color: AppColors.surfaceHigh,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.border, width: 0.5),
  ),
  child: Row(
    [_Tab("Edit", isActive), _Tab("Preview", isActive)]
  )
)
// Active tab: background AppColors.primary, text AppColors.background
// Inactive tab: transparent, text AppColors.secondary
// Animate switch with AnimatedContainer, duration 150ms
```

**Title field:**
```
Padding(horizontal: 20, top: 16, bottom: 0)
TextField(
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.primary),
  decoration: InputDecoration(
    hintText: "Title",
    hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.hint),
    border: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  ),
  maxLines: null,
  textCapitalization: TextCapitalization.sentences,
)
```

**Divider between title and content:**
```
Padding(horizontal: 20)
  Divider(color: AppColors.border, thickness: 0.5)
```

**Content field (Edit mode):**
```
Expanded(
  Padding(horizontal: 20, vertical: 12)
  TextField(
    style: TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.7,
      color: AppColors.primary,
    ),
    decoration: InputDecoration(
      hintText: "Start writing…",
      border: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    ),
    maxLines: null,
    expands: true,
    textAlignVertical: TextAlignVertical.top,
  )
)
```

**Content area (Preview mode):**
```
Expanded(
  SingleChildScrollView(
    Padding(horizontal: 20, vertical: 12)
    MarkdownBody(
      data: note.content,
      styleSheet: MarkdownStyleSheet(
        p: bodyMedium with height 1.7,
        h1: displaySmall,
        h2: headlineMedium,
        code: monospace 13px, background: AppColors.surfaceHigh, padding: 2px 6px, radius: 4px,
        codeblockDecoration: BoxDecoration(color: AppColors.surfaceHigh, radius: 8px, border: 0.5px border),
        blockquote: bodyMedium, color: AppColors.secondary, left border: 3px AppColors.border,
      ),
    )
  )
)
```

**Auto-save indicator (bottom of screen):**
```
Align(bottomRight)
  Padding(right: 16, bottom: 8)
  AnimatedOpacity: shows "Saved" text labelSmall, color: AppColors.hint
  Fades in when saved, fades out after 1.5s
```

**Tag picker bottom sheet:**
```
BottomSheet:
  drag handle
  Padding(16)
  Text("Tags", titleMedium)
  SizedBox(height: 12)
  Wrap(spacing: 8, runSpacing: 8,
    ...allTags.map((t) => FilterChip(
      label: Text(t.name),
      selected: note.tags.contains(t),
      selectedColor: Color(t.colorHex).withValues(alpha: 0.2),
      checkmarkColor: Color(t.colorHex),
      side: BorderSide(color: Color(t.colorHex), width: 0.5),
      labelStyle: labelSmall,
    ))
  )
  SizedBox(height: 12)
  TextButton.icon(icon: Icons.add, label: Text("New tag"), ...)
```

**Folder picker bottom sheet:**
```
BottomSheet:
  drag handle
  Text("Move to folder", titleMedium, padding: 16)
  ListTile: leading Icon(folder_off), title "No folder", trailing: radio if selected
  ...folders.map((f) =>
    ListTile: leading Icon(folder, color: AppColors.secondary), title f.name, trailing: radio
  )
```

---

### SCREEN 3 — SEARCH SCREEN

**AppBar:** replaced entirely by a search bar

```
SafeArea(
  Padding(horizontal: 16, vertical: 12)
  Container(
    height: 48,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border, width: 0.5),
    ),
    child: Row(
      Padding(left: 14)
      Icon(Icons.search, size: 20, color: AppColors.hint),
      SizedBox(width: 10),
      Expanded(TextField(
        autofocus: true,
        style: bodyMedium color primary,
        decoration: InputDecoration(hintText: "Search notes…", border: none),
      )),
      if (query.isNotEmpty)
        IconButton(icon: Icons.close, iconSize: 18, onPressed: clear)
    )
  )
)
```

**Filter chips row (below search bar):**
```
SizedBox(height: 44)
SingleChildScrollView(scrollDirection: Axis.horizontal,
  Padding(horizontal: 16)
  Row(
    // "All" chip always first
    FilterChip("All", selected: noFilter),
    SizedBox(width: 8),
    // folder filter
    DropdownButton styled as chip — shows current folder name or "Folder",
    SizedBox(width: 8),
    // tag chips
    ...allTags.map((t) => FilterChip(t.name, selected: activeTag == t))
  )
)
```

**Results list:**
- Same `NoteCard` as home, in list mode
- Match highlight: wrap matched substring in `TextSpan` with background `AppColors.accent.withValues(alpha: 0.2)`, color `AppColors.primary`
- Show result count: `Text("${results.length} notes", labelSmall, color: AppColors.hint)` above list

**Empty state (no query):**
```
Icon(Icons.search, 56px, hint color)
Text("Search your notes", secondary)
```

**Empty state (no results):**
```
Icon(Icons.search_off, 56px, hint color)
Text("No results for "$query"", secondary)
Text("Try different keywords", hint)
```

---

### SCREEN 4 — FOLDERS SCREEN

**AppBar:**
```
Left:  "Folders" — titleLarge
Right: [add icon 22px] — creates new folder inline
```

**Folder list:**
```
ListView.builder(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  itemBuilder: (ctx, i) => Dismissible(
    key: Key(folder.id),
    direction: DismissDirection.endToStart,
    background: red swipe background,
    child: _FolderTile(folder),
  )
)
```

**Folder tile:**
```
Container(
  margin: EdgeInsets.only(bottom: 8),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border, width: 0.5),
  ),
  child: ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.folder_outlined, size: 20, color: AppColors.secondary),
    ),
    title: Text(folder.name, style: titleMedium),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("${folder.noteCount}", style: labelSmall, color: AppColors.hint),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 18, color: AppColors.hint),
      ]
    ),
    onTap: () => navigate to filtered home,
  )
)
```

**Create folder inline (appears at top of list):**
```
AnimatedContainer — slides in from top
Container(
  margin: EdgeInsets.only(bottom: 8, ...),
  decoration: same as folder tile,
  child: ListTile(
    leading: icon,
    title: TextField(
      autofocus: true,
      decoration: InputDecoration(hintText: "Folder name", border: none),
      onSubmitted: createFolder,
    ),
    trailing: IconButton(Icons.check, onPressed: createFolder),
  )
)
```

**Empty state:**
```
Icon(Icons.folder_outlined, 56px, hint)
Text("No folders yet", secondary)
Text("Tap + to create one", hint)
```

---

### SCREEN 5 — ARCHIVE SCREEN

**AppBar:**
```
Left:  back arrow + "Archive" — titleLarge
Right: nothing
```

**Layout:** identical to home screen list mode, but showing only `isArchived == true` notes. No pinned section. No FAB. Swipe left to delete, swipe right to unarchive (restore icon, green tint).

---

### SHARED COMPONENTS

**TagChip:**
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  margin: EdgeInsets.only(right: 4),
  decoration: BoxDecoration(
    color: Color(tag.colorHex).withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Color(tag.colorHex).withValues(alpha: 0.4), width: 0.5),
  ),
  child: Text(tag.name,
    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(tag.colorHex)),
  ),
)
```

**ConfirmationDialog:**
```dart
showDialog → AlertDialog(
  backgroundColor: AppColors.surfaceHigh,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  title: Text("Delete note?", style: titleMedium),
  content: Text("This action cannot be undone.", style: bodyMedium, color: AppColors.secondary),
  actions: [
    TextButton("Cancel", style: text color secondary),
    TextButton("Delete", style: text color danger),
  ]
)
```

**SectionHeader:**
```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Text(title.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.8,
      color: AppColors.hint,
    ),
  ),
)
```

---

### ANIMATIONS SUMMARY

| Trigger | Widget | Duration | Curve |
|---|---|---|---|
| View mode toggle (grid ↔ list) | `AnimatedSwitcher` | 200ms | `easeInOut` |
| Note card → editor | `Hero` on note uuid | default | default |
| Edit ↔ preview toggle | `AnimatedContainer` | 150ms | `easeInOut` |
| "Saved" indicator | `AnimatedOpacity` | 300ms / 800ms | `easeIn` |
| New folder field appears | `AnimatedContainer` height 0→72 | 250ms | `easeOut` |
| FAB | `FloatingActionButton` scale in on first load | 300ms | `easeOut` |

---

### PRESET TAG COLORS

```dart
static const List<Color> tagColors = [
  Color(0xFF5E8EFF), // blue
  Color(0xFF5ED4A3), // teal
  Color(0xFFF5C542), // amber
  Color(0xFFFF6B6B), // red
  Color(0xFFB57BFF), // purple
  Color(0xFFFF9F43), // orange
  Color(0xFF54D4E0), // cyan
  Color(0xFFFF78C4), // pink
];
```

---

## APP ICON

**Design:** Geometric L mark on pure black background. White L stroke with a blue dot accent (`#5E8EFF`) at the top-right corner of the vertical stroke. The dot reads as a cursor/caret — a subtle nod to writing and editing.

**Colors:**
- Background: `#000000`
- L mark: `#FFFFFF`
- Accent dot: `#5E8EFF`
- Border (subtle): `#2A2A2A`

**Usage:**
1. Save the SVG below as `assets/icon/lexis_icon.svg`
2. Export to PNG at 1024×1024 using Inkscape, Figma, or any SVG tool
3. Save as `assets/icon/icon.png`
4. Add `flutter_launcher_icons` to `dev_dependencies`
5. Add to `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/icon/icon.png"
```
6. Run: `dart run flutter_launcher_icons`

**Production SVG (1024×1024):**

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <!-- Background -->
  <rect width="1024" height="1024" rx="224" fill="#000000"/>
  <!-- Subtle border -->
  <rect width="1024" height="1024" rx="224" fill="none" stroke="#2A2A2A" stroke-width="4"/>

  <!-- L mark — vertical stroke -->
  <line x1="348" y1="256" x2="348" y2="768"
        stroke="#FFFFFF" stroke-width="80" stroke-linecap="round"/>

  <!-- L mark — horizontal foot -->
  <line x1="348" y1="768" x2="724" y2="768"
        stroke="#FFFFFF" stroke-width="80" stroke-linecap="round"/>

  <!-- Blue dot accent — top right, aligned with foot end -->
  <circle cx="724" cy="256" r="52" fill="#5E8EFF"/>
</svg>
```

**Splash screen background color:** `#000000`  
**Android status bar color:** `#000000`  
**iOS background:** `#000000`
