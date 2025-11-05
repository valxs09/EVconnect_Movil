import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../config/theme.dart';
import '../../widgets/custom_input.dart';
import '../../services/auth_service.dart';



class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetEmail() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un correo electrónico'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.sendPasswordResetEmail(email);
      
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un enlace de recuperación a tu correo'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo enviar el correo de recuperación'),
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
    return Scaffold(
      backgroundColor: kPrimaryDark,
      appBar: AppBar(
        backgroundColor: kPrimaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: kWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Logo
              Image.asset(
                'assets/logo.png',
                width: 80,
                height: 80,
                // Placeholder del logo si la imagen no se carga
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

              // Título principal
              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: kWhite,
                ),
              ),
              const SizedBox(height: 10),

              // Instrucciones
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Enter your email to receive a password reset link.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: kWhite.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),

              // Campo de entrada de Email
              CustomInputField(
                controller: _emailController,
                hintText: 'admin@gmail.com',
                prefixIcon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 50),

              // Botón de Enviar
              ElevatedButton(
                onPressed: _isLoading ? null : sendResetEmail,
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
                        'Send Reset Link',
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
