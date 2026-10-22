import 'package:flutter/material.dart';
import '../../../core/localization/app_translations.dart';
import 'package:meridian_customer_app/features/checkout/screens/checkout_screen.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('cart'))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Spacer(),
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr('your_cart_is_empty'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('add_products_to_start'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(context.tr('continue_shopping')),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ...items.map(
                              (item) => Card(
                                elevation: 1,
                                shadowColor: Colors.black.withValues(
                                  alpha: 0.06,
                                ),
                                surfaceTintColor: Colors.transparent,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),

                                        child:
                                            item.product.imageUrl != null &&
                                                item
                                                    .product
                                                    .imageUrl!
                                                    .isNotEmpty
                                            ? Image.network(
                                                item.product.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Icon(
                                                        Icons
                                                            .medical_services_outlined,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        size: 23,
                                                      );
                                                    },
                                              )
                                            : Icon(
                                                Icons.medical_services_outlined,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                size: 23,
                                              ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.getName(context.langCode),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    if (item.quantity > 1) {
                                                      cart.updateQuantity(
                                                        item.product.id,
                                                        item.quantity - 1,
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                  ),
                                                  iconSize: 19,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 30,
                                                        minHeight: 30,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                                Text(
                                                  '${item.quantity}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    cart.updateQuantity(
                                                      item.product.id,
                                                      item.quantity + 1,
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.add_circle_outline,
                                                  ),
                                                  iconSize: 19,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 30,
                                                        minHeight: 30,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '\$${item.totalPrice.toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          cart.removeProduct(item.product.id);
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        iconSize: 20,
                                        tooltip: 'Remove product',
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.tr('total'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                    ),
                                    Text(
                                      '\$${cart.totalPrice.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const CheckoutScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(context.tr('proceed_to_checkout')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
