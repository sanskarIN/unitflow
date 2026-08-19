import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/converter/domain/unit_models.dart';
import '../features/converter/presentation/converter_controller.dart';
import '../features/converter/presentation/converter_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'app_controller.dart';
import 'theme/app_theme.dart';

final class AppShell extends StatefulWidget {
  const AppShell({required this.appController, super.key});

  final AppController appController;

  @override
  State<AppShell> createState() => _AppShellState();
}

final class _AppShellState extends State<AppShell> {
  late final ConverterController _converterController = ConverterController(
    appController: widget.appController,
  );
  int _selectedIndex = 0;

  @override
  void dispose() {
    _converterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.appController,
    builder: (context, _) => CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () =>
            _select(0),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () =>
            _select(1),
        const SingleActivator(LogicalKeyboardKey.comma, control: true): () =>
            _select(2),
        const SingleActivator(LogicalKeyboardKey.digit1, meta: true): () =>
            _select(0),
        const SingleActivator(LogicalKeyboardKey.digit2, meta: true): () =>
            _select(1),
        const SingleActivator(LogicalKeyboardKey.comma, meta: true): () =>
            _select(2),
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useRail = constraints.maxWidth >= 800;
            final content = _content();
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.swap_calls,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Text('UnitFlow'),
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    tooltip: 'Search unit library',
                    onPressed: () => _select(1),
                    icon: const Icon(Icons.search),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ),
              body: Column(
                children: <Widget>[
                  if (widget.appController.warning != null)
                    MaterialBanner(
                      content: Text(widget.appController.warning!),
                      leading: const Icon(Icons.warning_amber_outlined),
                      actions: <Widget>[
                        TextButton(
                          onPressed: widget.appController.clearWarning,
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                  Expanded(
                    child: useRail
                        ? Row(
                            children: <Widget>[
                              NavigationRail(
                                selectedIndex: _selectedIndex,
                                onDestinationSelected: _select,
                                labelType: NavigationRailLabelType.all,
                                destinations: const <NavigationRailDestination>[
                                  NavigationRailDestination(
                                    icon: Icon(Icons.swap_horiz_outlined),
                                    selectedIcon: Icon(Icons.swap_horiz),
                                    label: Text('Convert'),
                                  ),
                                  NavigationRailDestination(
                                    icon: Icon(Icons.library_books_outlined),
                                    selectedIcon: Icon(Icons.library_books),
                                    label: Text('Library'),
                                  ),
                                  NavigationRailDestination(
                                    icon: Icon(Icons.settings_outlined),
                                    selectedIcon: Icon(Icons.settings),
                                    label: Text('Settings'),
                                  ),
                                ],
                              ),
                              const VerticalDivider(width: 1),
                              Expanded(child: content),
                            ],
                          )
                        : content,
                  ),
                ],
              ),
              bottomNavigationBar: useRail
                  ? null
                  : NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _select,
                      destinations: const <NavigationDestination>[
                        NavigationDestination(
                          icon: Icon(Icons.swap_horiz_outlined),
                          selectedIcon: Icon(Icons.swap_horiz),
                          label: 'Convert',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.library_books_outlined),
                          selectedIcon: Icon(Icons.library_books),
                          label: 'Library',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.settings_outlined),
                          selectedIcon: Icon(Icons.settings),
                          label: 'Settings',
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    ),
  );

  Widget _content() => IndexedStack(
    index: _selectedIndex,
    children: <Widget>[
      ConverterScreen(controller: _converterController),
      LibraryScreen(appController: widget.appController, onOpenPair: _openPair),
      SettingsScreen(
        appController: widget.appController,
        onOpenAbout: _openAbout,
      ),
    ],
  );

  void _select(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _openPair(PinnedPair pair) {
    _converterController.applyPinnedPair(pair);
    setState(() => _selectedIndex = 0);
  }

  Future<void> _openAbout() => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: SafeArea(child: AboutScreen())),
    ),
  );
}
