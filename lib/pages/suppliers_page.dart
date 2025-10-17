import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_products_app/models/supplier.dart';
import 'package:mobile_products_app/providers/suppliers_provider.dart';
import 'supplier_detail_page.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  @override
  void initState() {
    super.initState();
    // Cargar proveedores al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<SuppliersProvider>();
      if (prov.suppliers.isEmpty) prov.loadSuppliers();
    });
  }

  Future<void> _refresh() async {
    await context.read<SuppliersProvider>().loadSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<SuppliersProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores')),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: prov.suppliers.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No hay proveedores')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: prov.suppliers.length,
                      itemBuilder: (context, index) {
                        final s = prov.suppliers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.store),
                            title: Text(s.name),
                            subtitle: Text('${s.productIds.length} productos'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SupplierDetailPage(supplier: s),
                                ),
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            SupplierDetailPage(supplier: s),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Eliminar proveedor'),
                                        content: Text(
                                          '¿Eliminar a "${s.name}"? Esta acción no se puede deshacer.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      final ok = await prov.deleteSupplier(
                                        s.id,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ok
                                                ? 'Proveedor eliminado'
                                                : 'Error eliminando proveedor',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupplierDetailPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
