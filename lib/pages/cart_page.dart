import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_products_app/models/product.dart';
import 'package:mobile_products_app/providers/cart_provider.dart';
import 'package:mobile_products_app/services/product_service.dart';
import 'package:provider/provider.dart';
import 'thank_you_page.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, Product> productsMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final ids = cart.items.keys.toList();
    Map<String, Product> tempMap = {};
    for (var id in ids) {
      final product = await ProductService.getProductById(id);
      if (product != null) tempMap[id] = product;
    }
    setState(() {
      productsMap = tempMap;
      isLoading = false;
    });
  }

  Future<void> _finalizePurchase() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final productsInCart = cart.items.keys.toList();
    bool stockOk = true;

    for (var productId in productsInCart) {
      final product = productsMap[productId];
      final quantity = cart.items[productId]!;
      if (product == null || product.stock < quantity) {
        stockOk = false;
        cart.items.remove(productId);
      }
    }

    if (stockOk) {
      // Descontar stock en Firestore
      for (var productId in productsInCart) {
        final product = productsMap[productId];
        final quantity = cart.items[productId]!;
        if (product != null) {
          await ProductService.updateStock(productId, product.stock - quantity);
        }
      }
      cart.items.clear();
      cart.notifyListeners();
      setState(() {});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ThankYouPage()),
      );
    } else {
      cart.notifyListeners();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Algunos productos no tenían stock suficiente y fueron eliminados.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final productsInCart = cart.items.keys.toList();
    final priceFormat = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );

    double total = 0;
    for (var productId in productsInCart) {
      final product = productsMap[productId];
      if (product != null) {
        total += product.price * cart.items[productId]!;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : productsInCart.isEmpty
          ? const Center(child: Text('El carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: productsInCart.length,
                    itemBuilder: (context, index) {
                      final productId = productsInCart[index];
                      final product = productsMap[productId];
                      final quantity = cart.items[productId]!;
                      if (product == null) return const SizedBox();
                      return Card(
                        child: ListTile(
                          leading: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  width: 50,
                                  height: 50,
                                )
                              : const Icon(Icons.image, size: 50),
                          title: Text(product.name),
                          subtitle: Text(
                            'Cantidad: $quantity\nStock: ${product.stock}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => cart.remove(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: quantity < product.stock
                                    ? () => cart.add(product)
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  cart.items.remove(productId);
                                  cart.notifyListeners();
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total: ${priceFormat.format(total)}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _finalizePurchase,
                        child: const Text('Pagar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
