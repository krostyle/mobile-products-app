// dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_products_app/models/supplier.dart';
import 'package:mobile_products_app/providers/suppliers_provider.dart';
import 'package:mobile_products_app/services/product_service.dart'; // Se asume método updateProductSupplier(productId, newSupplierId)

class SupplierDetailPage extends StatefulWidget {
  final Supplier? supplier;

  const SupplierDetailPage({super.key, this.supplier});

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameC;
  late final TextEditingController _emailC;
  late final TextEditingController _phoneC;
  late final TextEditingController _addressC;
  bool _saving = false;

  bool get isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.supplier?.name ?? '');
    _emailC = TextEditingController(text: widget.supplier?.email ?? '');
    _phoneC = TextEditingController(text: widget.supplier?.phone ?? '');
    _addressC = TextEditingController(text: widget.supplier?.address ?? '');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _addressC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final prov = context.read<SuppliersProvider>();
    final supplier = Supplier(
      id: widget.supplier?.id ?? '',
      name: _nameC.text.trim(),
      email: _emailC.text.trim().isEmpty ? null : _emailC.text.trim(),
      phone: _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
      address: _addressC.text.trim().isEmpty ? null : _addressC.text.trim(),
      productIds: widget.supplier?.productIds ?? [],
    );
    if (isEditing) {
      final ok = await prov.updateSupplier(supplier);
      if (ok)
        Navigator.pop(context);
      else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error al actualizar')));
      }
    } else {
      final created = await prov.createSupplier(supplier);
      if (created != null)
        Navigator.pop(context);
      else
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error al crear')));
    }
    setState(() => _saving = false);
  }

  Future<void> _delete() async {
    if (!isEditing) return;
    final prov = context.read<SuppliersProvider>();
    final current = widget.supplier!;
    // Si no tiene productos, confirmar eliminación simple
    if (current.productIds.isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar proveedor'),
          content: const Text('¿Eliminar este proveedor?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        setState(() => _saving = true);
        final ok = await prov.deleteSupplier(current.id);
        setState(() => _saving = false);
        if (ok)
          Navigator.pop(context);
        else
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Error al eliminar')));
      }
      return;
    }

    // Si tiene productos: ofrecer transferir a otro proveedor
    final otherSuppliers = prov.suppliers
        .where((s) => s.id != current.id)
        .toList();
    if (otherSuppliers.isEmpty) {
      // No hay a quién transferir
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se puede eliminar'),
          content: const Text(
            'Este proveedor tiene productos asociados y no hay otros proveedores para transferirlos. Crea otro proveedor primero.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }

    String? selectedSupplierId = otherSuppliers.first.id;

    final transferConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Transferir productos antes de eliminar'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'El proveedor tiene ${current.productIds.length} productos. Selecciona un proveedor destino para transferirlos:',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSupplierId,
                    items: otherSuppliers
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setStateDialog(() => selectedSupplierId = v),
                    decoration: const InputDecoration(
                      labelText: 'Proveedor destino',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Transferir y eliminar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (transferConfirmed != true) return;
    if (selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un proveedor destino válido')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      // Actualizar cada producto en la base de datos (ProductService debe implementar updateProductSupplier)
      final futures = current.productIds.map(
        (pid) => ProductService.updateProductSupplier(pid, selectedSupplierId!),
      );
      await Future.wait(futures);

      // Mantener estado local de proveedores: agregar productIds al destino y limpiar/actualizar el actual
      for (final pid in current.productIds) {
        await prov.addProductToSupplier(selectedSupplierId!, pid);
        // intentamos quitar del proveedor actual para mantener consistencia local (opcional)
        await prov.removeProductFromSupplier(current.id, pid);
      }

      // Finalmente eliminar el proveedor actual
      final ok = await prov.deleteSupplier(current.id);
      setState(() => _saving = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Productos transferidos y proveedor eliminado'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error eliminando proveedor después de transferir'),
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error durante la transferencia: $e')),
      );
    }
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar proveedor' : 'Nuevo proveedor'),
        actions: [
          if (isEditing)
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _saving
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameC,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: _validateName,
                      ),
                      TextFormField(
                        controller: _emailC,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextFormField(
                        controller: _phoneC,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      TextFormField(
                        controller: _addressC,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _save,
                        child: Text(isEditing ? 'Actualizar' : 'Crear'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
