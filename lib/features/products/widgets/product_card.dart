import 'package:flutter/material.dart';
import '../../../core/localization/app_translations.dart';
import 'package:meridian_customer_app/features/products/screens/product_details_screen.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.medical_services_outlined,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                      )
                    : Icon(
                        Icons.medical_services_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              product.getName(context.langCode),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              product.getDescription(context.langCode),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 36,
              child: FilledButton(
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: Text(
                  context.tr('view_details'),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
