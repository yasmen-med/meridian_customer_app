import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_translations.dart';
import '../../core/localization/locale_controller.dart';
import '../orders/screens/my_orders_screen.dart';
import '../products/data/product_repository.dart';
import '../cart/screens/cart_screen.dart';
import '../products/widgets/product_card.dart';
import '../products/models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _productRepository = ProductRepository();

  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;

  String selectedCategory = 'All';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final loadProducts = await _productRepository.loadProducts();
      if (!mounted) return;
      setState(() {
        products = loadProducts;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Product loading error: $error');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not load products. Please try again';
        isLoading = false;
      });
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final currentLang = context.read<LocaleController>().languageCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('select_language'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  title: const Text('English'),
                  trailing: currentLang == 'en'
                      ? Icon(Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    context
                        .read<LocaleController>()
                        .setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
                  title: const Text('العربية'),
                  trailing: currentLang == 'ar'
                      ? Icon(Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    context
                        .read<LocaleController>()
                        .setLocale(const Locale('ar'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanQuery = searchQuery.trim().toLowerCase();
    final filteredProducts = products.where((product) {
      final matchCategory =
          selectedCategory == 'All' || product.category == selectedCategory;
      final matchSearch = cleanQuery.isEmpty ||
          product.name.toLowerCase().contains(cleanQuery) ||
          (product.nameAr?.toLowerCase().contains(cleanQuery) ?? false) ||
          product.description.toLowerCase().contains(cleanQuery) ||
          (product.descriptionAr?.toLowerCase().contains(cleanQuery) ?? false);

      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.language),
          tooltip: context.tr('language'),
          onPressed: () => _showLanguageDialog(context),
        ),
        title: Text(
          context.tr('app_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: context.tr('my_orders'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: context.tr('cart'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  context.tr('hello_there'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr('feel_better'),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: context.tr('search_placeholder'),
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardTheme.color ??
                              Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryItem(
                        icon: Icons.grid_view_rounded,
                        title: context.tr('all'),
                        isSelected: selectedCategory == 'All',
                        onTap: () {
                          setState(() {
                            selectedCategory = 'All';
                          });
                        },
                      ),
                      _CategoryItem(
                        icon: Icons.medication_outlined,
                        title: context.tr('medicine'),
                        isSelected: selectedCategory == 'Medicine',
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Medicine';
                          });
                        },
                      ),
                      _CategoryItem(
                        icon: Icons.favorite_outlined,
                        title: context.tr('wellness'),
                        isSelected: selectedCategory == 'Wellness',
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Wellness';
                          });
                        },
                      ),
                      _CategoryItem(
                        icon: Icons.child_care_outlined,
                        title: context.tr('baby_care'),
                        isSelected: selectedCategory == 'Baby Care',
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Baby Care';
                          });
                        },
                      ),
                      _CategoryItem(
                        icon: Icons.spa_outlined,
                        title: context.tr('personal_care'),
                        isSelected: selectedCategory == 'Personal Care',
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Personal Care';
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('popular_products'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (errorMessage != null)
                  Center(
                    child: Column(
                      children: [
                        Text(errorMessage!),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            _loadProducts();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (filteredProducts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No products found.'),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(product: product);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? colorScheme.primary
        : (isDark
            ? colorScheme.surfaceContainerHighest
            : const Color(0xFFE0F5EF));

    final foregroundColor = isSelected
        ? colorScheme.onPrimary
        : (isDark ? colorScheme.onSurface : const Color(0xFF246B59));

    return SizedBox(
      width: 95,
      child: Card(
        color: backgroundColor,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: isDark && !isSelected
              ? BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                )
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 26, color: foregroundColor),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
