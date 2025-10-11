import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_products_app/models/product.dart';
import 'package:mobile_products_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({required this.product, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final quantity = cart.getQuantity(widget.product);
    final priceFormat = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name), leading: BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            widget.product.imageUrl.isNotEmpty
                ? Image.network(widget.product.imageUrl, height: 200)
                : const Icon(Icons.image, size: 200),
            const SizedBox(height: 16),
            Text(
              widget.product.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    cart.remove(widget.product);
                    setState(() {});
                  },
                ),
                Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: quantity < widget.product.stock
                      ? () {
                          cart.add(widget.product);
                          setState(() {});
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              priceFormat.format(widget.product.price),
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
