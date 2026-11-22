import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common_widget/empty_state_widget.dart';
import '../../../common_widget/hero_page_header.dart';
import '../../../common_widget/hero_search_field.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import 'widgets/all_modules/module_config.dart';
import 'widgets/all_modules/module_filter_chips.dart';
import 'widgets/quick_access_section_widget.dart';

/// "See All" destination: every module, searchable and filterable by category,
/// styled like the dashboard (hero header, chips, dashboard cards).
class AllModulesScreen extends StatefulWidget {
  const AllModulesScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => const AllModulesScreen()));
  }

  @override
  State<AllModulesScreen> createState() => _AllModulesScreenState();
}

class _AllModulesScreenState extends State<AllModulesScreen> {
  final TextEditingController _searchController = TextEditingController();
  ModuleCategory? _category;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppModule> get _visibleModules {
    final query = _query.trim().toLowerCase();
    return ModuleConfig.modules.where((m) {
      final matchesCategory = _category == null || m.category == _category;
      final matchesQuery = query.isEmpty || m.titleKey.tr.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final modules = _visibleModules;
    // Group by category only for the unfiltered "All" view.
    final grouped = _category == null && _query.trim().isEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'All Modules & Features'.tr,
              subtitle: 'Everything you need to run your business in one place.'.tr,
              trailing: HeroCountPill(
                label: '@count modules'.trParams({'count': '${ModuleConfig.modules.length}'}),
              ),
              bottom: HeroSearchField(
                controller: _searchController,
                hintText: 'Search modules'.tr,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            UIHelper.verticalSpace(14.h),
            ModuleFilterChips(
              selected: _category,
              onChanged: (category) => setState(() => _category = category),
            ),
            UIHelper.verticalSpace(6.h),
            Expanded(
              child: modules.isEmpty
                  ? EmptyStateWidget(icon: Icons.search_off_rounded, message: 'No modules found'.tr)
                  : CustomScrollView(
                      slivers: [
                        if (grouped)
                          for (final category in ModuleCategory.values) ...[
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 10.h),
                              sliver: SliverToBoxAdapter(
                                child: DashboardSectionHeader(title: category.labelKey.tr),
                              ),
                            ),
                            _ModuleGrid(modules: modules.where((m) => m.category == category).toList()),
                          ]
                        else ...[
                          SliverToBoxAdapter(child: UIHelper.verticalSpace(10.h)),
                          _ModuleGrid(modules: modules),
                        ],
                        SliverToBoxAdapter(child: UIHelper.verticalSpace(24.h)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  final List<AppModule> modules;

  const _ModuleGrid({required this.modules});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      // Same tile, size and spacing as the dashboard's Quick Access row.
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 10.h,
          mainAxisExtent: 114.h,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final module = modules[index];
            return QuickAccessTile(
              title: module.titleKey.tr,
              iconAsset: module.iconAsset,
              onTap: module.open == null ? null : () => module.open!(context),
            );
          },
          childCount: modules.length,
        ),
      ),
    );
  }
}
