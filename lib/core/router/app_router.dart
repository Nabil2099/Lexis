import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../../features/archive/presentation/screens/archive_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/spaces/presentation/screens/space_notes_screen.dart';
import '../../features/spaces/presentation/screens/spaces_screen.dart';
import '../../features/tags/presentation/screens/tag_notes_screen.dart';
import '../../features/tags/presentation/screens/tags_screen.dart';
import '../../features/trash/presentation/screens/trash_screen.dart';
import '../../features/vault/presentation/screens/vault_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const vault = '/vault';
  static const search = '/search';
  static const spaces = '/spaces';
  static const tags = '/tags';
  static const archive = '/archive';
  static const trash = '/trash';
  static const settings = '/settings';
  static const newNote = '/note/new';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _vaultNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'vault');
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _spacesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'spaces');
final _tagsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tags');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.vault,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _vaultNavigatorKey,
          routes: [
            GoRoute(
                path: AppRoutes.vault, builder: (_, __) => const VaultScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _searchNavigatorKey,
          routes: [
            GoRoute(
                path: AppRoutes.search,
                builder: (_, __) => const SearchScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _spacesNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.spaces,
              builder: (_, __) => const SpacesScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return SpaceNotesScreen(
                        spaceId: id,
                        spaceName: state.extra as String? ?? 'Space');
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _tagsNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.tags,
              builder: (_, __) => const TagsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return TagNotesScreen(
                        tagId: id, tagName: state.extra as String? ?? 'Tag');
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
                path: AppRoutes.settings,
                builder: (_, __) => const SettingsScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.newNote,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const NoteEditorScreen(),
    ),
    GoRoute(
      path: '/note/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) =>
          NoteEditorScreen(noteId: state.pathParameters['id']),
    ),
    GoRoute(
      path: AppRoutes.archive,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ArchiveScreen(),
    ),
    GoRoute(
      path: AppRoutes.trash,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const TrashScreen(),
    ),
    GoRoute(path: '/', redirect: (_, __) => AppRoutes.vault),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(index,
                initialLocation: index == navigationShell.currentIndex);
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: 'Vault'),
            NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.manage_search),
                label: 'Search'),
            NavigationDestination(
                icon: Icon(Icons.workspaces_outline),
                selectedIcon: Icon(Icons.workspaces),
                label: 'Spaces'),
            NavigationDestination(
                icon: Icon(Icons.sell_outlined),
                selectedIcon: Icon(Icons.sell),
                label: 'Tags'),
            NavigationDestination(
                icon: Icon(Icons.tune),
                selectedIcon: Icon(Icons.tune),
                label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
