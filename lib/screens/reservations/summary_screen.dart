import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class SummaryScreen extends StatelessWidget {
  // Parámetros que recibirá de la sesión
  final String totalCost;
  final String energyConsumed;
  final String duration;
  final String stationId;
  final String paymentCard;

  const SummaryScreen({
    super.key,
    this.totalCost = '\$0.00',
    this.energyConsumed = '0.0kWh',
    this.duration = '00h 00m',
    this.stationId = '#00',
    this.paymentCard = 'No disponible',
  });

  // Colores
  final Color _backgroundColor = const Color(0xFFF2F2F2);
  final Color _primaryColor = const Color(0xFF37A686);
  final Color _accentColor = const Color(0xFF52F2B8);
  final Color _cardBackgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Obtener argumentos de navegación si existen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String finalTotalCost = args?['totalCost'] ?? totalCost;
    final String finalEnergyConsumed =
        args?['energyConsumed'] ?? energyConsumed;
    final String finalDuration = args?['duration'] ?? duration;
    final String finalStationId = args?['stationId'] ?? stationId;
    final String finalPaymentCard = args?['paymentCard'] ?? paymentCard;
    final String? montoRetenido = args?['montoRetenido'];
    final String? ahorro = args?['ahorro'];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const CustomAppBar(
        title: '',
        showBackButton: false, // No permitir volver atrás
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),

              // Icono y Título de Carga Completada
              Image.asset('assets/check.png', height: 50),
              const SizedBox(height: 10),
              const Text(
                '¡Carga Completada!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              // Mensaje de Instrucción
              const Text(
                'Gracias por usar EVConnect. Por favor,\ndesconecta y libera la estación.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // Card de Resumen de Sesión
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: _cardBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _primaryColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de sesión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Costo Total
                    const Text(
                      'Costo Total',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      finalTotalCost,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detalles de la Carga
                    _buildSummaryDetail(
                      'Energía Suministrada:',
                      finalEnergyConsumed,
                    ),
                    _buildSummaryDetail('Duración Total:', finalDuration),
                    _buildSummaryDetail('Estación Utilizada:', finalStationId),
                    
                    // Mostrar ahorro si existe (detención manual)
                    if (ahorro != null && ahorro != '\$0.00')
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF4CAF50),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.savings_outlined,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '¡Ahorro por detención anticipada!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    Text(
                                      'Se liberaron $ahorro de tu retención',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const Divider(height: 30),

                    // Cargo a Tarjeta
                    _buildSummaryDetail('Cargo a:', finalPaymentCard),
                    const SizedBox(height: 5),
                    Text(
                      'Transacción Aprobada',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Botón Volver al inicio
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navegar al inicio y limpiar el stack de navegación
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/main', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(
                      color: Color(0xFF2C403A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para construir las líneas de detalle del resumen
  Widget _buildSummaryDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
