import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
    });
    try {
      await AuthService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      String errorMsg = e.toString();
      bool emailInUse = errorMsg.contains('correo ya está registrado');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          action: emailInUse
              ? SnackBarAction(
                  label: 'Recuperar contraseña',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, '/recover');
                  },
                )
              : null,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'El correo es obligatorio.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'El correo no es válido.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria.';
    if (value.length < 6)
      return 'La contraseña debe tener al menos 6 caracteres.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Iniciar sesión'),
                    ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/recover'),
                child: const Text('¿Olvidaste tu contraseña?'),
              ),

              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
