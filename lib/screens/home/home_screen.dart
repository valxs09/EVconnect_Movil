import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _userName;
  final Color _backgroundColor = const Color(0xFFF2F2F2);
  final Color _quickChargeColor = const Color(0xFFEF503D);
  final Color _standardChargeColor = const Color(0xFF3FABAB);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (mounted) {
        setState(() {
          _userName = user?.nombre;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildChargingCard({
    required String title,
    required String description,
    required String time,
    required Color primaryColor,
    required String buttonText,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primaryColor, Color.lerp(primaryColor, Colors.black, 0.2)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(child: Icon(icon, size: 60, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 80),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 80),
                    Expanded(
                      child: Text(
                        '$description\n$time',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingIndicator(loadingText: "Cargando..."));
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _backgroundColor,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 40),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: _standardChargeColor,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Permite el scroll incluso cuando el contenido es pequeño
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                Text(
                  '¡Hola, ${_userName ?? ""}!',
                  textAlign:
                      TextAlign.center, // Alinea el texto dentro de su caja
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  '¿Listo para cargar tu día?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 0),
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
                _buildChargingCard(
                  title: '¡Carga Rápida!',
                  description: 'Ideal para cuando tienes prisa.',
                  time: '~30-60 minutos',
                  primaryColor: _quickChargeColor,
                  buttonText: 'Empezar Carga',
                  icon: Icons.rocket_launch_outlined,
                ),
                _buildChargingCard(
                  title: 'Carga Estándar',
                  description: 'Perfecta para estancias largas.',
                  time: '~2-4 horas',
                  primaryColor: _standardChargeColor,
                  buttonText: 'Empezar Carga',
                  icon: Icons.flash_on,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
