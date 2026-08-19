import 'package:flutter/material.dart';

import '../core/unit_model.dart';
import '../state/app_state.dart';
import '../widgets/converter_card.dart';
import '../widgets/history_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppState _state;
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _state = AppState();
    _inputController = TextEditingController(text: _state.input);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.swap_horiz_rounded),
                SizedBox(width: 10),
                Text('UnitFlow'),
              ],
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Text(
                    'Made by the Sanskar',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SelectionArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _HeroHeader(state: _state),
                        const SizedBox(height: 16),
                        _CategorySelector(state: _state),
                        const SizedBox(height: 16),
                        ConverterCard(
                          state: _state,
                          inputController: _inputController,
                        ),
                        const SizedBox(height: 16),
                        HistorySection(state: _state),
                        const SizedBox(height: 28),
                        const Center(
                          child: Text(
                            'Offline-first • Open source • MIT License',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: <Color>[
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Convert with confidence.',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fast offline conversions, searchable units, batch tools, favorites, recent history, and educational context.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              const Chip(
                avatar: Icon(Icons.offline_bolt_outlined, size: 18),
                label: Text('Offline core'),
              ),
              Chip(
                avatar: const Icon(Icons.category_outlined, size: 18),
                label: Text('${UnitCategory.values.length} categories'),
              ),
              Chip(
                avatar: const Icon(Icons.science_outlined, size: 18),
                label: Text(state.category.label),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UnitCategory.values.map((UnitCategory category) {
                return ChoiceChip(
                  label: Text(category.label),
                  selected: state.category == category,
                  onSelected: (bool selected) {
                    if (selected) {
                      state.setCategory(category);
                    }
                  },
                );
              }).toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}
