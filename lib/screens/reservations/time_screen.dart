import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/charger_model.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  // Colores
  final Color _backgroundColor = const Color(0xFFF2F2F2);
  final Color _stationTextColor = const Color(0xFF37A686);
  final Color _inputColor = const Color(0xFF52F2B8);
  final Color _quickButtonBgColor = const Color(0xFFEEEEEE);
  final Color _quickButtonBorderColor = const Color(0xFF37A686);
  final Color _changeLinkColor = const Color(0xFF37A686);
  final Color _mainButtonColor = const Color(0xFF2C403A);

  // Estado para los botones de tiempo rápido
  String _selectedQuickTime = '1 hr';

  // Controladores de tiempo manual
  final TextEditingController _hoursController = TextEditingController(
    text: '01',
  );
  final TextEditingController _minutesController = TextEditingController(
    text: '30',
  );

  // Valores simulados
  final String _estimatedCost = '\$100.00';
  final String _paymentMethod = 'Visa \u2022\u2022\u2022\u2022 4567';

  // Lista de opciones de tiempo rápido
  final List<String> _quickOptions = ['30 min', '1 hr', '2 hrs', 'Completo'];

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  // Función para construir los botones de tiempo rápido
  Widget _buildQuickTimeButton(String label) {
    final bool isSelected = _selectedQuickTime == label;
    final Color borderColor =
        isSelected ? _quickButtonBorderColor : Colors.grey.shade300;
    final double borderWidth = isSelected ? 3.0 : 1.0;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _selectedQuickTime = label;
              // Actualizar controladores según la selección
              switch (label) {
                case '30 min':
                  _hoursController.text = '00';
                  _minutesController.text = '30';
                  break;
                case '1 hr':
                  _hoursController.text = '01';
                  _minutesController.text = '00';
                  break;
                case '2 hrs':
                  _hoursController.text = '02';
                  _minutesController.text = '00';
                  break;
                case 'Completo':
                  _hoursController.text = '08';
                  _minutesController.text = '00';
                  break;
              }
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: _quickButtonBgColor,
            foregroundColor: Colors.black54,
            side: BorderSide(color: borderColor, width: borderWidth),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // Helper para construir los inputs de Horas/Minutos
  Widget _buildTimeInput(TextEditingController controller, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: _inputColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: _inputColor.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 2,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: _mainButtonColor,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
              onChanged: (value) {
                // Validar que sea numérico
                if (value.isNotEmpty) {
                  final numValue = int.tryParse(value);
                  if (numValue == null) {
                    controller.text = '00';
                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _mainButtonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el cargador de los argumentos
    final ChargerModel? charger =
        ModalRoute.of(context)?.settings.arguments as ChargerModel?;
    final String chargerNumber =
        charger?.idCargador.toString().padLeft(2, '0') ?? '00';

    // Calcular tiempo total para el botón principal
    final String totalTime =
        '${_hoursController.text}:${_minutesController.text}h';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const CustomAppBar(title: '', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),

            // Estación Asignada
            Text(
              'Estación Asignada: #$chargerNumber',
              style: TextStyle(
                color: _stationTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Pregunta con Icono
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '¿Cuánto tiempo vas a cargar? ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text('⏳', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 30),

            // --- Inputs de Horas y Minutos ---
            Row(
              children: [
                _buildTimeInput(_hoursController, 'Horas'),
                const SizedBox(width: 15),
                _buildTimeInput(_minutesController, 'Minutos'),
              ],
            ),

            const SizedBox(height: 30),

            // --- Botones de Tiempo Rápido ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _quickOptions.map(_buildQuickTimeButton).toList(),
            ),

            const SizedBox(height: 40),

            // --- Costo Estimado ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Costo Estimado:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _estimatedCost,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Método de Pago ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Imagen de la Tarjeta
                    Image.asset('assets/tarjetas.png', height: 25, width: 35),
                    const SizedBox(width: 10),
                    Text(
                      _paymentMethod,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    print('Navegar a Cambiar método de pago');
                    // TODO: Navegar a WalletScreen
                    // Navigator.pushNamed(context, '/wallet');
                  },
                  child: Text(
                    'Cambiar',
                    style: TextStyle(
                      color: _changeLinkColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- Botón Principal de Acción ---
            ElevatedButton(
              onPressed: () {
                // Validar que el tiempo sea válido
                final int hours = int.tryParse(_hoursController.text) ?? 0;
                final int minutes = int.tryParse(_minutesController.text) ?? 0;

                if (hours == 0 && minutes == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, ingresa un tiempo válido'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Crear la duración con el tiempo ingresado
                final Duration selectedDuration = Duration(
                  hours: hours,
                  minutes: minutes,
                );

                print('Iniciando carga por $totalTime');

                // Navegar a SessionProgressScreen con los parámetros
                Navigator.pushNamed(
                  context,
                  '/session-progress',
                  arguments: {
                    'reservationId': charger?.idCargador ?? 0,
                    'chargerName': 'Cargador #$chargerNumber',
                    'initialDuration': selectedDuration,
                    'pricePerMinute': 0.50, // Ajusta según tu tarifa
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _mainButtonColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: Text(
                'Iniciar Carga por [$totalTime]',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
