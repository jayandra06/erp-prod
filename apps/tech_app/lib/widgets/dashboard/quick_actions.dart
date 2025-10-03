import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Create RFQ',
        'subtitle': 'Request for Quotation',
        'icon': Icons.add_circle_outline,
        'color': const Color(0xFF4CAF50),
        'route': '/rfq/create',
      },
      {
        'title': 'Manage Users',
        'subtitle': 'User Management',
        'icon': Icons.people_outline,
        'color': const Color(0xFF2196F3),
        'route': '/users',
      },
      {
        'title': 'View Quotes',
        'subtitle': 'Review Quotes',
        'icon': Icons.rate_review_outlined,
        'color': const Color(0xFFFF9800),
        'route': '/quotes',
      },
      {
        'title': 'System Health',
        'subtitle': 'Monitor System',
        'icon': Icons.monitor_heart_outlined,
        'color': const Color(0xFF9C27B0),
        'route': '/health',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // TODO: Navigate to route
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${action['title']} - Coming Soon!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    action['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action['subtitle'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
