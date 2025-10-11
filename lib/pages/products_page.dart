import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_products_app/models/category.dart';
import 'package:mobile_products_app/models/product.dart';
import 'package:mobile_products_app/providers/cart_provider.dart';
import 'package:mobile_products_app/services/category_service.dart';
import 'package:mobile_products_app/services/product_service.dart';
import 'package:provider/provider.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Category> categories = [];
  String search = '';
  String selectedCategoryId = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cats = await CategoryService.getCategories();
    final prods = await ProductService.getProducts();
    setState(() {
      categories = [Category(id: '', name: 'Todas'), ...cats];
      products = prods;
      filteredProducts = prods;
      selectedCategoryId = '';
      isLoading = false;
    });
  }

  void _filterProducts() {
    setState(() {
      final selectedCategoryName = categories
          .firstWhere(
            (cat) => cat.id == selectedCategoryId,
            orElse: () => Category(id: '', name: 'Todas'),
          )
          .name;

      filteredProducts = products.where((p) {
        final matchesSearch = p.name.toLowerCase().contains(
          search.toLowerCase(),
        );
        final matchesCategory =
            selectedCategoryId == '' || p.category == selectedCategoryName;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final priceFormat = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CartPage()),
                  );
                },
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      cart.totalItems.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      search = value;
                      _filterProducts();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButton<String>(
                    value: selectedCategoryId,
                    items: categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      selectedCategoryId = value!;
                      _filterProducts();
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final quantity = cart.getQuantity(product);
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: product.imageUrl.isNotEmpty
                                ? Image.network(
                                    product.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image, size: 50),
                            title: Text(product.name),
                            subtitle: Text(
                              '${priceFormat.format(product.price)} - Stock: ${product.stock}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => cart.remove(product),
                                ),
                                Container(
                                  width: 28,
                                  alignment: Alignment.center,
                                  child: Text(
                                    quantity.toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: quantity < product.stock
                                      ? () => cart.add(product)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
