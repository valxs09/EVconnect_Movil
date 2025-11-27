import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar Stripe solo en Android e iOS
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      print('🔄 Inicializando Stripe...');

      Stripe.publishableKey =
          'pk_test_51SQEDRGsGUVjmzkud1fhYIystj0z4Ru3tXFqiJy5ftqZdrcpOU8EuOtx4RVA07bJeqi4cAdx3TweA7IbkgkTHTN300dm2NGHCx';

      print('✅ Publishable key configurado');
      print(
        '✅ Stripe inicializado correctamente en ${Platform.operatingSystem}',
      );
    } catch (e) {
      print('❌ Error inicializando Stripe: $e');
      print('⚠️ La app continuará pero los pagos no funcionarán');
    }
  } else {
    print('⚠️ Stripe no está disponible en esta plataforma (solo Android/iOS)');
  }

  // WebSocket se conectará automáticamente cuando el usuario inicie una sesión de carga

  final bool isAuthenticated = await AuthService.isAuthenticated();
  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVconnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
        ),
        useMaterial3: true,
      ),
      initialRoute: isAuthenticated ? AppRoutes.main : AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
