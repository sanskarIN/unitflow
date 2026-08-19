import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../converter/domain/unit_models.dart';
import 'custom_unit_dialog.dart';

final class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    required this.appController,
    required this.onOpenPair,
    super.key,
  });

  final AppController appController;
  final ValueChanged<PinnedPair> onOpenPair;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

final class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  UnitCategory? _category;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.appController,
    builder: (context, _) {
      final results = widget.appController.engine.catalog.search(
        _query,
        category: _category,
        limit: 200,
      );
      results.sort((left, right) {
        final leftFavorite = widget.appController.state.favoriteUnitIds
            .contains(left.id);
        final rightFavorite = widget.appController.state.favoriteUnitIds
            .contains(right.id);
        if (leftFavorite != rightFavorite) {
          return leftFavorite ? -1 : 1;
        }
        return left.name.compareTo(right.name);
      });

      return CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _Header(onAddCustom: _addCustomUnit),
                      const SizedBox(height: AppSpacing.lg),
                      _PinnedPairs(
                        appController: widget.appController,
                        onOpenPair: widget.onOpenPair,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search units',
                          hintText: 'Name, symbol, or alias',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _CategoryFilter(
                        value: _category,
                        onChanged: (value) => setState(() => _category = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '${results.length} ${results.length == 1 ? 'unit' : 'units'}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (results.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyLibrary(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              sliver: SliverList.separated(
                itemCount: results.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: _UnitTile(
                      unit: results[index],
                      isFavorite: widget.appController.state.favoriteUnitIds
                          .contains(results[index].id),
                      onFavorite: () => widget.appController.toggleFavorite(
                        results[index].id,
                      ),
                      onDeleteCustom: results[index].isBuiltIn
                          ? null
                          : () => _deleteCustomUnit(results[index]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );

  Future<void> _addCustomUnit() async {
    final data = await showCustomUnitDialog(
      context,
      initialCategory: _category ?? UnitCategory.length,
    );
    if (data == null || !mounted) {
      return;
    }
    try {
      await widget.appController.addCustomUnit(data);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not create unit: $error')));
      return;
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${data.name} added.')));
  }

  Future<void> _deleteCustomUnit(UnitDefinition unit) async {
    final data = widget.appController.state.customUnits
        .where((candidate) => candidate.id == unit.id)
        .firstOrNull;
    if (data == null) {
      return;
    }
    await widget.appController.removeCustomUnit(unit.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${unit.name} removed.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => widget.appController.addCustomUnit(data),
        ),
      ),
    );
  }
}

final class _Header extends StatelessWidget {
  const _Header({required this.onAddCustom});

  final VoidCallback onAddCustom;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Unit library',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Search built-in units, favorites, and your own validated custom units.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      FilledButton.icon(
        onPressed: onAddCustom,
        icon: const Icon(Icons.add),
        label: const Text('Custom unit'),
      ),
    ],
  );
}

final class _PinnedPairs extends StatelessWidget {
  const _PinnedPairs({required this.appController, required this.onOpenPair});

  final AppController appController;
  final ValueChanged<PinnedPair> onOpenPair;

  @override
  Widget build(BuildContext context) {
    final pairs = appController.state.pinnedPairs;
    if (pairs.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Pinned pairs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: pairs
                  .map((pair) {
                    final from = appController.engine.catalog.byId(
                      pair.fromUnitId,
                    );
                    final to = appController.engine.catalog.byId(pair.toUnitId);
                    if (from == null || to == null) {
                      return const SizedBox.shrink();
                    }
                    return ActionChip(
                      avatar: const Icon(Icons.push_pin_outlined, size: 18),
                      label: Text('${from.symbol} → ${to.symbol}'),
                      onPressed: () => onOpenPair(pair),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

final class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.value, required this.onChanged});

  final UnitCategory? value;
  final ValueChanged<UnitCategory?> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: FilterChip(
            label: const Text('All'),
            selected: value == null,
            onSelected: (_) => onChanged(null),
          ),
        ),
        ...UnitCategory.values.map(
          (category) => Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FilterChip(
              label: Text(category.label),
              selected: value == category,
              onSelected: (_) => onChanged(category),
            ),
          ),
        ),
      ],
    ),
  );
}

final class _UnitTile extends StatelessWidget {
  const _UnitTile({
    required this.unit,
    required this.isFavorite,
    required this.onFavorite,
    required this.onDeleteCustom,
  });

  final UnitDefinition unit;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback? onDeleteCustom;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: CircleAvatar(
        child: Text(unit.symbol, textAlign: TextAlign.center),
      ),
      title: Text(unit.name),
      subtitle: Text(
        '${unit.category.label} • ${unit.id}${unit.isBuiltIn ? '' : ' • Custom'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: onFavorite,
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          ),
          if (onDeleteCustom != null)
            IconButton(
              tooltip: 'Remove custom unit',
              onPressed: onDeleteCustom,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    ),
  );
}

final class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No units match this search.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    ),
  );
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
