import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../models/order.dart';
import '../controllers/order_controller.dart';

class OrderTrackingScreen extends StatelessWidget {
  final CustomerOrder order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Watch order from OrderController so it updates automatically
    final currentOrder = context.watch<OrderController>().orders.firstWhere(
      (o) => o.id == order.id,
      orElse: () => order,
    );
    final currentStatus = currentOrder.status;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('track_order'))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('order_placed_success'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '${context.tr('order_id')}: #${order.id}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.tr('total')}: \$${order.totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.tr('order_status'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),
                  ..._buildTrackingTimeline(context, currentStatus),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTrackingTimeline(
    BuildContext context,
    String currentStatus,
  ) {
    final stages = [
      {
        'status': 'Placed',
        'title': context.tr('stage_placed'),
        'subtitle': context.tr('stage_placed_sub'),
        'icon': Icons.receipt_long,
      },
      {
        'status': 'Preparing',
        'title': context.tr('stage_preparing'),
        'subtitle': context.tr('stage_preparing_sub'),
        'icon': Icons.inventory_2_outlined,
      },
      {
        'status': 'Out for Delivery',
        'title': context.tr('stage_out_for_delivery'),
        'subtitle': context.tr('stage_out_for_delivery_sub'),
        'icon': Icons.delivery_dining,
      },
      {
        'status': 'Delivered',
        'title': context.tr('stage_delivered'),
        'subtitle': context.tr('stage_delivered_sub'),
        'icon': Icons.home_outlined,
      },
    ];

    final currentIndex = stages.indexWhere(
      (stage) => stage['status'] == currentStatus,
    );

    final activeIndex = currentIndex == -1 ? 0 : currentIndex;
    final colorScheme = Theme.of(context).colorScheme;

    return List<Widget>.generate(stages.length, (index) {
      final stage = stages[index];
      final isCompleted = index < activeIndex;
      final isCurrent = index == activeIndex;
      final isActive = index <= activeIndex;

      final stageColor = isActive ? colorScheme.primary : colorScheme.outline;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : stage['icon'] as IconData,
                  color: stageColor,
                  size: 26,
                ),
                if (index < stages.length - 1)
                  Container(
                    width: 2,
                    height: 44,
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: stageColor,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(stage['subtitle'] as String),
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        context.tr('current_status'),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
