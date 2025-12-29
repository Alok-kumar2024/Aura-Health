import 'package:aura_heallth/colors/app_colors.dart'; // Adjust path if needed
import 'package:aura_heallth/state/meal_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../../model/meal_data.dart';
import 'analysis_result_screen.dart';

class MealHistoryScreen extends ConsumerStatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  ConsumerState<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends ConsumerState<MealHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. FILTERED LIST (For showing the cards)
    final asyncDisplayedMeals = ref.watch(displayedMealsProvider);

    // 2. FULL LIST (For calculating stats and badge counts correctly)
    final asyncFullList = ref.watch(allMealsNotifier);

    final currentFilter = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(allMealsNotifier.future),
        color: const Color(0xFF1E88E5),
        child: CustomScrollView(
          key: const PageStorageKey<String>('meal_history_scroll'),
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildSliverAppBar(),

            // 1. Stats Summary Row (Uses FULL List)
            SliverToBoxAdapter(
              child: _buildStatsOverview(asyncFullList),
            ),

            // 2. Filter Tabs (Uses FULL List so counts don't disappear)
            SliverPinnedHeader(
              child: _buildFilterTabs(currentFilter, asyncFullList),
            ),

            // 3. The List of Meals (Uses FILTERED List)
            asyncDisplayedMeals.when(
              data: (meals) {
                if (meals.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildMealList(meals);
              },
              error: (error, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: Colors.red[300]),
                      const SizedBox(height: 10),
                      Text('Error loading meals', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
              loading: () => _buildLoadingShimmer(),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSliverAppBar() {
    final searchText = ref.watch(searchQueryProvider);

    return SliverAppBar(
      expandedHeight: 180.0,
      pinned: true,
      backgroundColor: const Color(0xFF1E88E5),
      elevation: 0,
      stretch: true,
      // leading: IconButton(
      //   icon: Container(
      //     padding: const EdgeInsets.all(8),
      //     decoration: BoxDecoration(
      //       color: Colors.white.withOpacity(0.2),
      //       shape: BoxShape.circle,
      //     ),
      //     child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
      //   ),
      //   onPressed: () => Navigator.pop(context),
      // ),
      title: const Text(
        "Meal History",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  // Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      cursorColor: Colors.white,
                      onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                      decoration: InputDecoration(
                        hintText: 'Search food...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: searchText.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(AsyncValue<List<MealData>> asyncMeals) {
    // FIX 1: Use Full List
    final meals = asyncMeals.value ?? [];
    final totalScans = meals.length.toString();

    // FIX 2: Uncommented Average Score Logic
    // String avgScore = "0";
    // if (meals.isNotEmpty) {
    //   final sum = meals.fold(0, (prev, element) => prev + element.safetyScore);
    //   avgScore = (sum / meals.length).toStringAsFixed(0);
    // }

    final alerts = meals.where((m) => m.interactionCount > 0).length.toString();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.qr_code_scanner_rounded,
            color: Colors.blue,
            value: totalScans,
            label: 'Total Scans',
          ),
          const SizedBox(width: 12),
          // _buildStatItem(
          //   icon: Icons.health_and_safety_rounded,
          //   color: Colors.green,
          //   value: avgScore,
          //   label: 'Avg Score',
          // ),
          const SizedBox(width: 12),
          _buildStatItem(
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            value: alerts,
            label: 'Alerts',
            isAlert: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    bool isAlert = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isAlert ? Border.all(color: Colors.orange.withOpacity(0.3)) : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(String currentFilter, AsyncValue<List<MealData>> asyncMeals) {
    // FIX 3: Use Full List for counts
    final meals = asyncMeals.value ?? [];

    final counts = {
      'all': meals.length,
      'safe': meals.where((m) => m.status == 'safe').length,
      'warning': meals.where((m) => m.status == 'warning').length,
      'critical': meals.where((m) => m.status == 'critical').length,
    };

    final safeColor = const Color(0xFF4CAF50);
    final warningColor = const Color(0xFFFF9800);
    final criticalColor = const Color(0xFFF44336);

    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 45,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildFilterPill('All', 'all', counts['all']!, currentFilter),
            const SizedBox(width: 10),
            _buildFilterPill('Safe', 'safe', counts['safe']!, currentFilter, activeColor: safeColor),
            const SizedBox(width: 10),
            _buildFilterPill('Warning', 'warning', counts['warning']!, currentFilter, activeColor: warningColor),
            const SizedBox(width: 10),
            _buildFilterPill('Critical', 'critical', counts['critical']!, currentFilter, activeColor: criticalColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(
      String label,
      String value,
      int count,
      String currentFilter,
      {Color? activeColor}
      ) {
    final isSelected = currentFilter == value;
    final baseColor = activeColor ?? const Color(0xFF1E88E5);

    // UI Improvement: Hide badge if count is 0 (except for 'All')
    final showBadge = count > 0 || value == 'all';

    return InkWell(
      onTap: () => ref.read(filterProvider.notifier).state = value,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? baseColor : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: baseColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final searchQuery = ref.watch(searchQueryProvider);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              searchQuery.isNotEmpty
                  ? 'No results for "$searchQuery"'
                  : 'No meals found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try checking your spelling or adjusting filters.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealList(List<MealData> meals) {
    final groupedMeals = _groupMealsByDate(meals);

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final dateGroup = groupedMeals.keys.elementAt(index);
        final meals = groupedMeals[dateGroup]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(dateGroup),
            ...meals.map((meal) => _buildMealCard(meal)).toList(),
          ],
        );
      }, childCount: groupedMeals.length),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildMealCard(MealData meal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showMealDetail(meal),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Column
                    Column(
                      children: [
                        Text(
                          DateFormat('HH:mm').format(meal.timestamp),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('a').format(meal.timestamp),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Vertical Divider
                    Container(
                      height: 40,
                      width: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.grey.shade100,
                    ),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                meal.mealName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: Colors.black87,
                                ),
                              ),
                              // FIX 4: Uncommented Badge
                              // _buildScoreBadge(meal.safetyScore),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: meal.ingredients
                                .take(4)
                                .map((i) => _buildIngredientChip(i))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Interaction Warning Banner
                if (meal.interactionCount > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0), // Light Orange
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${meal.interactionCount} Interaction${meal.interactionCount > 1 ? 's' : ''} Detected',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.orange.shade300)
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(int score) {
    Color color;
    if (score >= 90) {
      color = const Color(0xFF4CAF50); // Green
    } else if (score >= 70) {
      color = const Color(0xFFFF9800); // Orange
    } else {
      color = const Color(0xFFF44336); // Red
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 13
        ),
      ),
    );
  }

  Widget _buildIngredientChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500
        ),
      ),
    );
  }

  // --- HELPERS ---

  void _showMealDetail(MealData meal) {
    if (meal.rawData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(result: meal.rawData!),
        ),
      );
    }
  }

  Map<String, List<MealData>> _groupMealsByDate(List<MealData> meals) {
    final Map<String, List<MealData>> grouped = {};
    for (var meal in meals) {
      final dateKey = _formatDateKey(meal.timestamp);
      if (!grouped.containsKey(dateKey)) grouped[dateKey] = [];
      grouped[dateKey]!.add(meal);
    }
    return grouped;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final mealDate = DateTime(date.year, date.month, date.day);

    if (mealDate == today) return 'Today';
    if (mealDate == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(date);
  }

  Widget _buildLoadingShimmer() {
    return SliverFillRemaining(
      child: Center(
        child: SpinKitRing(color: const Color(0xFF1E88E5), size: 40, lineWidth: 4),
      ),
    );
  }
}

// Small helper for pinned headers
class SliverPinnedHeader extends StatelessWidget {
  final Widget child;
  const SliverPinnedHeader({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverPinnedHeaderDelegate(child),
    );
  }
}

class _SliverPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverPinnedHeaderDelegate(this.child);
  @override
  double get minExtent => 65; // Height of filter area
  @override
  double get maxExtent => 65;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: child,
    );
  }
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}