import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_products_app/models/supplier.dart';

class SupplierService {
  static Future<List<Supplier>> getSuppliers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('suppliers')
        .get();
    return snapshot.docs
        .map((doc) => Supplier.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Future<Supplier?> getSupplierById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('suppliers')
        .doc(id)
        .get();
    if (doc.exists) {
      return Supplier.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  static Future<Supplier> createSupplier(Supplier supplier) async {
    final docRef = await FirebaseFirestore.instance
        .collection('suppliers')
        .add(supplier.toMap());
    final createdDoc = await docRef.get();
    return Supplier.fromFirestore(createdDoc.data()!, createdDoc.id);
  }

  static Future<void> updateSupplier(Supplier supplier) async {
    await FirebaseFirestore.instance
        .collection('suppliers')
        .doc(supplier.id)
        .update(supplier.toMap());
  }

  static Future<void> deleteSupplier(String id) async {
    await FirebaseFirestore.instance.collection('suppliers').doc(id).delete();
  }
}
