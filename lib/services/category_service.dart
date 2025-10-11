import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_products_app/models/category.dart';

class CategoryService {
  static Future<List<Category>> getCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .get();
    return snapshot.docs
        .map((doc) => Category.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
