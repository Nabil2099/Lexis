import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/notes/data/note_model.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/notes/presentation/screens/notes_list_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/folders/presentation/screens/folders_screen.dart';
import '../../features/folders/presentation/screens/folder_notes_screen.dart';
import '../../features/archive/presentation/screens/archive_screen.dart';
import '../../features/tags/presentation/screens/tags_screen.dart';

class AppRoutes {
  static const home = '/';
  static const search = '/search';
  static const folders = '/folders';
  static const folderNotes = '/folders/:id';
  static const archive = '/archive';
  static const tags = '/tags';
  static const newNote = '/note/new';
  static const editNote = '/note/:id';
}

// Shell route keys for bottom navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _notesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'notes');
final _foldersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'folders');
final _archiveNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'archive');
final _tagsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tags');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Notes branch (Home)
        StatefulShellBranch(
          navigatorKey: _notesNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const NotesListScreen(),
              routes: [
                GoRoute(
                  path: 'note/new',
                  builder: (context, state) {
                    final folderId = state.extra as int?;
                    return NoteEditorScreen(folderId: folderId);
                  },
                ),
                GoRoute(
                  path: 'note/:id',
                  builder: (context, state) {
                    final note = state.extra as Note;
                    return NoteEditorScreen(note: note);
                  },
                ),
              ],
            ),
          ],
        ),
        // Folders branch
        StatefulShellBranch(
          navigatorKey: _foldersNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.folders,
              builder: (context, state) => const FoldersScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final folderId = int.tryParse(state.pathParameters['id'] ?? '');
                    final folderName = state.extra as String? ?? 'Folder';
                    return FolderNotesScreen(folderId: folderId!, folderName: folderName);
                  },
                ),
              ],
            ),
          ],
        ),
        // Archive branch
        StatefulShellBranch(
          navigatorKey: _archiveNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.archive,
              builder: (context, state) => const ArchiveScreen(),
            ),
          ],
        ),
        // Tags branch
        StatefulShellBranch(
          navigatorKey: _tagsNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.tags,
              builder: (context, state) => const TagsScreen(),
            ),
          ],
        ),
      ],
    ),
    // Search route (outside bottom navigation)
    GoRoute(
      path: AppRoutes.search,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);

// Scaffold with bottom navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Folders',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive_outlined),
            selectedIcon: Icon(Icons.archive),
            label: 'Archive',
          ),
          NavigationDestination(
            icon: Icon(Icons.label_outline),
            selectedIcon: Icon(Icons.label),
            label: 'Tags',
          ),
        ],
      ),
    );
  }
}
