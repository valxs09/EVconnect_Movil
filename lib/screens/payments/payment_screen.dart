import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_app_bar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Colores
  final Color _primaryColor = const Color(0xFF37A686);
  final Color _buttonColor = const Color(0xFF2C403A);
  final Color _backgroundColor = const Color(0xFFF2F2F2);

  // Controladores de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  // Valor seleccionado para el Dropdown
  String? _selectedCountry = 'United States';
  final List<String> _countries = [
    'United States',
    'Mexico',
    'Canada',
    'Other',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  // Estilo general para los campos de texto del formulario
  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        borderSide: BorderSide(color: _primaryColor, width: 2.0),
      ),
    );
  }

  // Widget para el Label del grupo de campos
  Widget _buildFieldGroupLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
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
            children: <Widget>[
              // --- Sección de Email ---
              _buildFieldGroupLabel('Email'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(hint: 'email@example.com'),
              ),

              // --- Sección de Información de la Tarjeta ---
              _buildFieldGroupLabel('Información de la tarjeta'),

              // Número de tarjeta
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(hint: '1234 1234 1234 1234'),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              const SizedBox(height: 12),

              // Expiry y CVC en la misma fila
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(hint: 'MM/YY'),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvcController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(hint: 'CVC'),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                ],
              ),

              // --- Sección de Nombre del Titular ---
              _buildFieldGroupLabel('Nombre del titular'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(hint: 'Nombre completo'),
              ),

              // --- Sección de País y ZIP ---
              _buildFieldGroupLabel('País o región'),

              // Dropdown de País
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountry,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    items:
                        _countries.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCountry = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Campo ZIP
              TextFormField(
                controller: _zipController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(hint: 'Código Postal'),
              ),

              const SizedBox(height: 40),

              // --- Botón de Agregar ---
              ElevatedButton(
                onPressed: () {
                  // Solo mostrar mensaje de confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarjeta agregada exitosamente'),
                      backgroundColor: Color(0xFF37A686),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Agregar Tarjeta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Texto Legal
              Center(
                child: Text(
                  'Al agregar esta tarjeta, aceptas los Términos\ny Condiciones de Stripe.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
