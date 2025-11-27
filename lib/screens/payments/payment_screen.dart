import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../services/payment_service.dart';
import '../../widgets/custom_app_bar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Colores
  final Color _primaryColor = const Color(0xFF37A686);
  final Color _buttonColor = const Color(0xFF2C403A);
  final Color _backgroundColor = const Color(0xFFF2F2F2);

  // Controladores para todos los campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  // País seleccionado (ISO Code de 2 letras)
  // Estado del widget de Stripe
  CardFieldInputDetails? _cardDetails;
  String _selectedCountry =
      'MX'; // Por defecto México (ISO Code de 2 letras para Stripe)

  // Lista de países compatible con Stripe
  final List<Map<String, String>> _countries = [
    {'code': 'MX', 'name': 'México'},
    {'code': 'US', 'name': 'Estados Unidos'},
    {'code': 'CA', 'name': 'Canadá'},
    {'code': 'ES', 'name': 'España'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveCard() async {
    // Validar formulario completo
    if (!_formKey.currentState!.validate()) return;

    // 2. Validar widget de Stripe (Número, Fecha, CVC)
    if (_cardDetails == null || !_cardDetails!.complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa los datos de la tarjeta (Número, Fecha, CVC)',
          ),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      // PASO 1: Obtener client_secret del backend
      print('🔄 Paso 1: Obteniendo client_secret del backend...');
      final clientSecret = await PaymentService.createSetupIntent();
      if (clientSecret == null) {
        throw Exception('Error de conexión con el servidor');
      }
      print('✅ Client secret obtenido: ${clientSecret.substring(0, 20)}...');

      // PASO 2: Confirmar SetupIntent con los datos de la tarjeta
      // Esto creará automáticamente el PaymentMethod en Stripe
      print('🔄 Paso 2: Confirmando SetupIntent con datos de tarjeta...');
      final setupIntentResult = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              address: Address(
                city: null, // Opcional
                country: _selectedCountry,
                line1: null, // Opcional
                line2: null,
                postalCode: _zipController.text.trim(),
                state: null, // Opcional
              ),
            ),
          ),
        ),
      );

      print('✅ SetupIntent confirmado con status: ${setupIntentResult.status}');

      // PASO 3: Verificar éxito y obtener payment_method_id
      if (setupIntentResult.status.toString() == 'succeeded') {
        final paymentMethodId = setupIntentResult.paymentMethodId;

        if (paymentMethodId == null || paymentMethodId.isEmpty) {
          throw Exception('No se obtuvo el payment_method_id de Stripe');
        }

        print('✅ PaymentMethod ID obtenido: $paymentMethodId');

        // PASO 4: Guardar en backend
        print('🔄 Paso 3: Guardando payment_method_id en backend...');
        final success = await PaymentService.savePaymentMethod(paymentMethodId);

        if (success) {
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
          throw Exception('El servidor no pudo guardar la tarjeta');
        }
      } else {
        throw Exception(
          'SetupIntent no completado: ${setupIntentResult.status}',
        );
      }
    } catch (e) {
      print('❌ Error completo: $e');
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');

        // Mejorar mensajes de error comunes
        if (errorMsg.contains('card') || errorMsg.contains('invalid')) {
          errorMsg = 'Datos de tarjeta inválidos. Verifica número, fecha y CVC';
        } else if (errorMsg.contains('network') ||
            errorMsg.contains('connection')) {
          errorMsg = 'Error de conexión. Verifica tu internet';
        }

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

  // Estilo consistente para los campos de texto
  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const CustomAppBar(
        title: 'Agregar Tarjeta',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN: Datos del Titular ---
              const Text(
                'Datos del Titular',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // CAMPO: Nombre en la tarjeta
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  'Nombre en la tarjeta',
                  hint: 'Ej. Juan Pérez',
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              // CAMPO: Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  'Correo electrónico',
                  hint: 'ejemplo@email.com',
                ),
                validator:
                    (v) =>
                        (v?.isEmpty ?? true) || !v!.contains('@')
                            ? 'Email inválido'
                            : null,
              ),
              const SizedBox(height: 25),

              // --- SECCIÓN: Dirección de Facturación ---
              const Text(
                'Dirección de Facturación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  // CAMPO: País (Dropdown)
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountry,
                          isExpanded: true,
                          items:
                              _countries
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c['code'],
                                      child: Text(c['name']!),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setState(() => _selectedCountry = v!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // CAMPO: Código Postal
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _zipController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('CP', hint: '97000'),
                      validator:
                          (v) => (v?.length ?? 0) < 4 ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- SECCIÓN: Datos de la Tarjeta ---
              const Text(
                'Datos de la Tarjeta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa número, fecha y CVC',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // WIDGET: Número de tarjeta
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  'Número de tarjeta',
                  hint: '4242 4242 4242 4242',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                validator: (v) {
                  final digits = v?.replaceAll(' ', '') ?? '';
                  return digits.length < 13 ? 'Número inválido' : null;
                },
              ),
              const SizedBox(height: 12),

              // WIDGET: Fecha y CVC en la misma fila
              Row(
                children: [
                  // Fecha de expiración
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Expira', hint: 'MM/YY'),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.length < 5) return 'Inválido';
                        final parts = v.split('/');
                        if (parts.length != 2) return 'Formato: MM/YY';
                        final month = int.tryParse(parts[0]);
                        if (month == null || month < 1 || month > 12) {
                          return 'Mes inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // CVC
                  Expanded(
                    child: TextFormField(
                      controller: _cvcController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('CVC', hint: '123'),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator:
                          (v) => (v?.length ?? 0) < 3 ? 'CVC inválido' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSaveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Guardar Tarjeta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 20),

              // Texto legal
              const Center(
                child: Text(
                  'Información protegida por Stripe.\nTu CVV nunca se almacena en nuestros servidores.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Formateador para número de tarjeta (agrega espacios cada 4 dígitos)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Formateador para fecha de expiración (agrega / después de mes)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');

    if (text.length >= 3) {
      final formatted = '${text.substring(0, 2)}/${text.substring(2)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return newValue;
  }
}
