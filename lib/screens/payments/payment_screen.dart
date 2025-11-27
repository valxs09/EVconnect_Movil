import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../services/payment_service.dart';
import '../../widgets/custom_app_bar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  // Colores
  final Color _primaryColor = const Color(0xFF37A686);
  final Color _buttonColor = const Color(0xFF2C403A);
  final Color _backgroundColor = const Color(0xFFF2F2F2);

  Future<void> _handleAddCardWithPaymentSheet() async {
    setState(() => _isLoading = true);

    try {
      // PASO 1: Obtener client_secret del SetupIntent desde el backend
      print('🔄 Paso 1: Obteniendo client_secret del backend...');
      final clientSecret = await PaymentService.createSetupIntent();
      
      if (clientSecret == null) {
        throw Exception('No se pudo crear el SetupIntent');
      }
      
      print('✅ Client secret obtenido: ${clientSecret.substring(0, 20)}...');

      // PASO 2: Inicializar el Payment Sheet con el client_secret
      print('🔄 Paso 2: Inicializando Payment Sheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: 'EVConnect',
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: _primaryColor,
            ),
          ),
        ),
      );

      print('✅ Payment Sheet inicializado');

      // PASO 3: Presentar el Payment Sheet (modal de Stripe)
      print('🔄 Paso 3: Presentando Payment Sheet...');
      await Stripe.instance.presentPaymentSheet();

      print('✅ Payment Sheet completado exitosamente');

      // PASO 4: El Payment Sheet completó el SetupIntent exitosamente
      // Stripe ya procesó la tarjeta y la vinculó al Customer
      // El backend debería recibir un webhook de Stripe (setup_intent.succeeded)
      // que automáticamente guarda la tarjeta
      
      print('🔄 Paso 4: Esperando que el backend procese la tarjeta...');
      
      // Esperar a que el webhook procese (2-3 segundos usualmente)
      await Future.delayed(const Duration(seconds: 3));
      
      // Verificar que la tarjeta se haya agregado consultando la lista
      print('🔄 Paso 5: Verificando tarjeta en el sistema...');
      final cards = await PaymentService.getPaymentMethods();
      
      if (cards.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Tarjeta guardada exitosamente'),
              backgroundColor: Color(0xFF37A686),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(
          'La tarjeta se procesó en Stripe pero aún no aparece en el sistema. '
          'Intenta recargar en unos segundos.',
        );
      }
    } on StripeException catch (e) {
      print('❌ Error de Stripe: ${e.error.message}');
      
      if (mounted) {
        // Si el usuario canceló, no mostrar error
        if (e.error.code == FailureCode.Canceled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Operación cancelada'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.error.localizedMessage ?? "Error desconocido"}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error general: $e');
      
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMsg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const CustomAppBar(
        title: 'Agregar Tarjeta',
        showBackButton: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono de tarjeta
              Icon(
                Icons.credit_card,
                size: 100,
                color: _primaryColor,
              ),
              const SizedBox(height: 30),

              // Título
              const Text(
                'Agregar Método de Pago',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              // Descripción
              const Text(
                'Usa el formulario seguro de Stripe para\nagregar tu tarjeta de crédito o débito',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Botón para abrir Payment Sheet
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAddCardWithPaymentSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Agregar Tarjeta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // Características de seguridad
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildSecurityFeature(
                      Icons.lock_outline,
                      'Encriptación de nivel bancario',
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityFeature(
                      Icons.verified_user_outlined,
                      'Certificado PCI-DSS',
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityFeature(
                      Icons.shield_outlined,
                      'Protección contra fraude',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Texto legal
              const Text(
                'Powered by Stripe\nTus datos nunca se almacenan en nuestros servidores',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
