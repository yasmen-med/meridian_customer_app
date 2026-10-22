import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../controllers/order_controller.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  String _getTranslatedStatus(BuildContext context, String status) {
    switch (status) {
      case 'Placed':
        return context.tr('stage_placed');
      case 'Preparing':
        return context.tr('stage_preparing');
      case 'Out for Delivery':
        return context.tr('stage_out_for_delivery');
      case 'Delivered':
        return context.tr('stage_delivered');
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderController>().orders;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('my_orders'))),
      // Center list and constrain max width on tablets
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 72,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr('no_orders_yet'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];

                      // Calculate total item quantity in order
                      final totalUnits = order.items.fold(
                        0,
                        (sum, item) => sum + item.quantity,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                              child: Icon(
                                Icons.receipt_long,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          title: Text(
                            '${context.tr('order_prefix')} #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$totalUnits ${context.tr('items')} · \$${order.totalPrice.toStringAsFixed(2)}\n'
                              '${context.tr('status')}: ${_getTranslatedStatus(context, order.status)}',
                              style: const TextStyle(height: 1.3),
                            ),
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderTrackingScreen(order: order),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
