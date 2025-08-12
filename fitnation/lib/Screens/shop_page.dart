import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import 'package:fitnation/widgets/common/CustomAppBar.dart';

class ShopPage extends StatefulWidget {
  final String? initialCategory;
  
  const ShopPage({
    super.key,
    this.initialCategory,
  });

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String _selectedCategory = 'all';
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'all';
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    _products = ProductService.getAllProducts();
    _filteredProducts = _products;
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts =
          _products.where((product) {
            final matchesCategory =
                _selectedCategory == 'all' ||
                product.category == _selectedCategory;
            final matchesSearch =
                product.name.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                product.description.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );
            return matchesCategory && matchesSearch;
          }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Athlytiq Store',
        showLogo: false,
        showMenuButton: false, // Disable menu button
        showProfileMenu: true, // Enable profile menu
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryChip(
                  category: 'All',
                  icon: '🏪',
                  isSelected: _selectedCategory == 'all',
                  onTap: () => _selectCategory('all'),
                ),
                CategoryChip(
                  category: 'Equipment',
                  icon: '🏋️',
                  isSelected: _selectedCategory == 'equipment',
                  onTap: () => _selectCategory('equipment'),
                ),
                CategoryChip(
                  category: 'Supplements',
                  icon: '💊',
                  isSelected: _selectedCategory == 'supplements',
                  onTap: () => _selectCategory('supplements'),
                ),
                CategoryChip(
                  category: 'Accessories',
                  icon: '🎒',
                  isSelected: _selectedCategory == 'accessories',
                  onTap: () => _selectCategory('accessories'),
                ),
                CategoryChip(
                  category: 'Clothing',
                  icon: '👕',
                  isSelected: _selectedCategory == 'clothing',
                  onTap: () => _selectCategory('clothing'),
                ),
                CategoryChip(
                  category: 'Footwear',
                  icon: '👟',
                  isSelected: _selectedCategory == 'footwear',
                  onTap: () => _selectCategory('footwear'),
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child:
                _filteredProducts.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return Product_card(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProductDetailPage(product: product),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
