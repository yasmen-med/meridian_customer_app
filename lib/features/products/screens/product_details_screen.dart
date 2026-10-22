import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../models/product.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('view_details'))),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 650;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWideScreen ? 900 : 550),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: isWideScreen
                      ? _buildWideLayout(context, product)
                      : _buildNarrowLayout(context, product),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(product, height: 240),
        const SizedBox(height: 24),
        _buildProductInfo(context, product),
        const SizedBox(height: 24),
        _buildQuantitySelector(context),
        const SizedBox(height: 24),
        _buildAddToCartButton(context, product),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, Product product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildImage(product, height: 350)),
        const SizedBox(width: 32),

        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductInfo(context, product),
              const SizedBox(height: 24),
              _buildQuantitySelector(context),
              const SizedBox(height: 24),
              _buildAddToCartButton(context, product),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(Product product, {required double height}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
          ? Image.network(
              product.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.medical_services_outlined,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                );
              },
            )
          : Center(
              child: Icon(
                Icons.medical_services_outlined,
                size: 80,
                color: colorScheme.primary,
              ),
            ),
    );
  }

  Widget _buildProductInfo(BuildContext context, Product product) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.trCategory(product.category),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.getName(context.langCode),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.getDescription(context.langCode),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
              icon: const Icon(Icons.remove),
              color: colorScheme.onSurface,
              disabledColor: colorScheme.onSurface.withValues(alpha: 0.3),
              tooltip: 'Decrease quantity',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$quantity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => quantity++),
              icon: const Icon(Icons.add),
              color: colorScheme.primary,
              tooltip: 'Increase quantity',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, Product product) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          context.read<CartController>().addProduct(
            product,
            quantity: quantity,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${product.getName(context.langCode)} ${context.tr('added_to_cart')}',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.shopping_cart_outlined),
        label: Text(context.tr('add_to_cart')),
      ),
    );
  }
}
