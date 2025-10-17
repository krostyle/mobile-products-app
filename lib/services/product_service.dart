import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_products_app/models/product.dart';

class ProductService {
  static Future<List<Product>> getProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();
    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Future<Product?> getProductById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(id)
        .get();
    if (doc.exists) {
      return Product.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  static Future<void> updateStock(String id, int newStock) async {
    await FirebaseFirestore.instance.collection('products').doc(id).update({
      'stock': newStock,
    });
  }

  static Future<void> updateProductSupplier(
    String productId,
    String newSupplierId,
  ) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).set({
      'supplierId': newSupplierId,
    }, SetOptions(merge: true));
  }
}
