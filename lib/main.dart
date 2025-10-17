import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_products_app/pages/categories_page.dart';
import 'package:mobile_products_app/pages/dashboard_page.dart';
import 'package:mobile_products_app/pages/products_page.dart';
import 'package:mobile_products_app/pages/recover_page.dart';
import 'package:mobile_products_app/pages/suppliers_page.dart';
import 'package:mobile_products_app/providers/cart_provider.dart';
import 'package:mobile_products_app/providers/suppliers_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SuppliersProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Products App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/products': (context) => const ProductsPage(),
        '/categories': (context) => const CategoriesPage(),
        '/suppliers': (context) => const SuppliersPage(),
        '/recover': (context) => const RecoverPage(),
      },
    );
  }
}
