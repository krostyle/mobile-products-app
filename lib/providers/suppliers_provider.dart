import 'package:flutter/cupertino.dart';
import 'package:mobile_products_app/models/supplier.dart';
import 'package:mobile_products_app/services/supplier_service.dart';

class SuppliersProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _loading = false;
  String? _error;

  SuppliersProvider({bool autoLoad = false}) {
    if (autoLoad) loadSuppliers();
  }

  List<Supplier> get suppliers => List.unmodifiable(_suppliers);

  bool get isLoading => _loading;

  String? get error => _error;

  Future<void> loadSuppliers() async {
    _setLoading(true);
    _error = null;
    try {
      final items = await SupplierService.getSuppliers();
      _suppliers = items;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Supplier? getById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Supplier?> createSupplier(Supplier supplier) async {
    _setLoading(true);
    _error = null;
    try {
      final created = await SupplierService.createSupplier(supplier);
      _suppliers.add(created);
      return created;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateSupplier(Supplier supplier) async {
    _setLoading(true);
    _error = null;
    try {
      await SupplierService.updateSupplier(supplier);
      final idx = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (idx != -1) {
        _suppliers[idx] = supplier;
      } else {
        _suppliers.add(supplier);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteSupplier(String id) async {
    _setLoading(true);
    _error = null;
    try {
      await SupplierService.deleteSupplier(id);
      _suppliers.removeWhere((s) => s.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addProductToSupplier(String supplierId, String productId) async {
    final s = getById(supplierId);
    if (s == null) return false;
    if (s.productIds.contains(productId)) return true;
    final updated = Supplier(
      id: s.id,
      name: s.name,
      email: s.email,
      phone: s.phone,
      address: s.address,
      productIds: List<String>.from(s.productIds)..add(productId),
    );
    return await updateSupplier(updated);
  }

  Future<bool> removeProductFromSupplier(
    String supplierId,
    String productId,
  ) async {
    final s = getById(supplierId);
    if (s == null) return false;
    if (!s.productIds.contains(productId)) return true;
    final updated = Supplier(
      id: s.id,
      name: s.name,
      email: s.email,
      phone: s.phone,
      address: s.address,
      productIds: List<String>.from(s.productIds)..remove(productId),
    );
    return await updateSupplier(updated);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
