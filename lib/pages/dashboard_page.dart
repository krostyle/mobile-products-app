import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'title': 'Productos',
        'subtitle': 'Ver y gestionar productos',
        'icon': Icons.shopping_bag,
        'route': '/products',
      },
      {
        'title': 'Categorías',
        'subtitle': 'Ver y gestionar categorías',
        'icon': Icons.category,
        'route': '/categories',
      },
      {
        'title': 'Proveedores',
        'subtitle': 'Ver y gestionar proveedores',
        'icon': Icons.store,
        'route': '/suppliers',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Módulos')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final m = modules[index];
            return InkWell(
              onTap: () => Navigator.pushNamed(context, m['route'] as String),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        m['icon'] as IconData,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        m['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        m['subtitle'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
