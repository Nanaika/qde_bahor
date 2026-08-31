import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  // color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: ThemeDimensions.paddingM,
                crossAxisSpacing: ThemeDimensions.paddingM,
                childAspectRatio: 1.1,
                children: [
                  _AdminMenuCard(
                    title: 'Add type',
                    subtitle: 'Category setup',
                    icon: Icons.category_outlined,
                    color: isDark ? Colors.indigo.shade300 : Colors.indigo,
                    onTap: () => context.push('/add_product_type'),
                  ),
                  _AdminMenuCard(
                    title: 'Manage products',
                    subtitle: 'Edit & Delete',
                    icon: Icons.inventory_2_outlined,
                    color: isDark ? Colors.amber.shade400 : Colors.amber.shade800,
                    onTap: () => context.push('/manage_products'),
                  ),
                  _AdminMenuCard(
                    title: 'Manage orders',
                    subtitle: 'Track status',
                    icon: Icons.receipt_long_outlined,
                    color: isDark ? Colors.purple.shade300 : Colors.purple,
                    onTap: () => context.push('/manage_orders'),
                  ),
                  _AdminMenuCard(
                    title: 'Moderate Users',
                    subtitle: 'Review and verify accounts',
                    icon: Icons.admin_panel_settings_outlined,
                    // Или Icons.how_to_reg_outlined
                    color: isDark ? Colors.cyan.shade300 : Colors.cyan,
                    onTap: () => context.push('/moderate_users'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
