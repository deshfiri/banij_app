import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/pill_chip.dart';
import 'module_config.dart';

/// Horizontal category chips; `null` means "All".
class ModuleFilterChips extends StatelessWidget {
  final ModuleCategory? selected;
  final ValueChanged<ModuleCategory?> onChanged;

  const ModuleFilterChips({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <ModuleCategory?>[null, ...ModuleCategory.values];

    return PillChipBar(
      chips: [
        for (final category in options)
          PillChip(
            label: (category?.labelKey ?? 'filter_all').tr,
            icon: category?.icon ?? Icons.grid_view_rounded,
            isSelected: category == selected,
            onTap: () => onChanged(category),
          ),
      ],
    );
  }
}
