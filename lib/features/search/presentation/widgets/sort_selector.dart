import 'package:flutter/material.dart';
import 'package:rahmani_project/features/search/domain/entities/search_enums.dart';

/// Sort option selector chips.
class SortSelector extends StatelessWidget {
  const SortSelector({
    required this.selected,
    required this.onSelected,
    this.showRelevance = true,
    super.key,
  });

  final SearchSortOption selected;
  final ValueChanged<SearchSortOption> onSelected;
  final bool showRelevance;

  @override
  Widget build(BuildContext context) {
    final options = SearchSortOption.values
        .where((o) => showRelevance || o != SearchSortOption.relevance)
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(option.labelFa),
              selected: selected == option,
              onSelected: (_) => onSelected(option),
            ),
          );
        }).toList(),
      ),
    );
  }
}
