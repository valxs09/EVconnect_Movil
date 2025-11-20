import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/charger_model.dart';

class NFCScreen extends StatelessWidget {
  // Colores
  final Color _backgroundColor = const Color(0xFFF2F2F2);
  final Color _chargerCardColor = const Color(0xFF52F2B8);
  final Color _chargerNumberColor = const Color(0xFF0D0D0D);
  final Color _nfcCardColor = const Color(0xFF2C403A);

  const NFCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el cargador de los argumentos
    final ChargerModel? charger =
        ModalRoute.of(context)?.settings.arguments as ChargerModel?;
    final String chargerNumber =
        charger?.idCargador.toString().padLeft(2, '0') ?? '00';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const CustomAppBar(title: '', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Título Principal
            const Text(
              '¡Estación asignada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Subtítulo
            const Text(
              '¡Dirígete a cargar tu coche!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 0),

            // Icono del enchufe
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/enchufe.png',
                  height: 69,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // --- Card Principal: Cargador #07 ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                color: _chargerCardColor, // Color 52F2B8
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _chargerCardColor.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Cargador\n# $chargerNumber',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: _chargerNumberColor, // Color 0D0D0D
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Card Secundaria: Acerca tu móvil (NFC) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                color: _nfcCardColor, // Color 2C403A
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de NFC
                  Image.asset(
                    'assets/nfc.png',
                    height: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 20),

                  const Flexible(
                    child: Text(
                      '¡Acerca tu móvil a la\nestación para empezar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- Botón/Link: Cancelar Carga ---
            TextButton(
              onPressed: () {
                print('Cancelar Carga');
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar Carga',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
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
