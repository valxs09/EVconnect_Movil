import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../config/theme.dart';
import '../../widgets/custom_input.dart';

// =================================================================
// PANTALLA DE CREAR CUENTA (Register Screen)
// =================================================================

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  // Widget para simular la entrada de teléfono con bandera (adaptado a CustomInputField)
  Widget _buildPhonePrefix() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇪🇸', style: TextStyle(fontSize: 20)),
          const Icon(CupertinoIcons.chevron_down, color: kTextDark, size: 16),
          Container(
            width: 1,
            height: 20,
            color: kTextDark.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Función para navegar de vuelta a la pantalla de inicio de sesión
    void navigateToSignIn() {
      Navigator.of(context).pop();
    }

    return Scaffold(
      backgroundColor: kPrimaryDark,
      appBar: AppBar(
        backgroundColor: kPrimaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: kWhite),
          onPressed: navigateToSignIn,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Logo
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
              const Text('Create account', style: kTitleStyle),
              const SizedBox(height: 10),

              // Subtítulo y Enlace de Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: kSubtitleStyle),
                  GestureDetector(
                    onTap: navigateToSignIn,
                    child: const Text('Login',
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline)),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Campos de entrada
              const CustomInputField(
                hintText: 'Lois Becket',
                prefixIcon: CupertinoIcons.person,
              ),
              const SizedBox(height: 20),
              const CustomInputField(
                hintText: 'Loisbecket@gmail.com',
                prefixIcon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Nota: Usamos Iconos de Material aquí para el calendario, ya que CupertinoIcons no tiene uno tan claro.
              const CustomInputField(
                hintText: '18/03/2024',
                prefixIcon: Icons.calendar_today,
                suffixIcon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              // Campo de teléfono personalizado
              CustomInputField(
                hintText: '(454) 726-0592',
                prefixIcon: CupertinoIcons.phone, // Placeholder
                keyboardType: TextInputType.phone,
                customPrefix: _buildPhonePrefix(),
              ),
              const SizedBox(height: 20),
              const CustomInputField(
                hintText: '********',
                prefixIcon: CupertinoIcons.lock_fill,
                suffixIcon: CupertinoIcons.eye_slash,
                isPassword: true,
              ),
              const SizedBox(height: 60),

              // Botón de Registro
              ElevatedButton(
                onPressed: () {
                  // Acción de Registro (Integración con AuthService)
                },
                style: kPrimaryButtonStyle,
                child: const Text(
                  'Register',
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
