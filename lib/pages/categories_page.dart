import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: const Center(
        child: Text('Aquí irá la lista y gestión de categorías'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // abrir formulario de crear categoría
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
