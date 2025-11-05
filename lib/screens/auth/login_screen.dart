import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../config/theme.dart';
import '../../widgets/custom_input.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

// =================================================================
// PANTALLA DE INICIO DE SESIÓN (Login Screen)
// =================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales inválidas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void navigateToSignUp() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );
    }
    
    void navigateToForgotPassword() {
      Navigator.of(context).pushNamed('/forgot-password');
    }


    return Scaffold(
      backgroundColor: kPrimaryDark, // Fondo oscuro
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              // Logo (Placeholder)
              Image.asset(
                'assets/logo.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(CupertinoIcons.shield_lefthalf_fill, color: kWhite, size: 40),
                ),
              ),
              const SizedBox(height: 40),

              // Título
              const Text('Sign in to your Account', style: kTitleStyle),
              const SizedBox(height: 10),

              // Subtítulo y Enlace de Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: kSubtitleStyle),
                  GestureDetector(
                    onTap: navigateToSignUp,
                    child: const Text('Sign Up',
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline)),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Campos de entrada
              CustomInputField(
                hintText: 'admin@gmail.com',
                prefixIcon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              CustomInputField(
                hintText: '12345678',
                prefixIcon: CupertinoIcons.lock_fill,
                suffixIcon: _showPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                isPassword: !_showPassword,
                controller: _passwordController,
                onSuffixTap: () => setState(() => _showPassword = !_showPassword),
              ),
              const SizedBox(height: 20),

              // Enlace Olvidé mi contraseña
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: navigateToForgotPassword,
                  child: const Text(
                    'Forgot Your Password ?',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Inicio de Sesión
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: kPrimaryButtonStyle,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: kWhite,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Log In',
                        style: kPrimaryButtonTextStyle,
                      ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}