import 'package:flutter/material.dart';
import 'package:evconnect/widgets/custom_app_bar.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color _backgroundColor = const Color(0xFFF2F2F2);
  final Color _darkCardColor = const Color(0xFF2C403A);
  final Color _primaryColor = const Color(0xFF37A686);

  User? _user;
  bool _isLoading = true;

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
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: const CustomAppBar(title: 'Mi Perfil', showBackButton: true),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF37A686)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const CustomAppBar(title: 'Mi Perfil', showBackButton: true),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 60, // Aumentamos la altura para dar espacio a la card
                  color: const Color(0xFF37A686),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    top: 40.0,
                  ), // Espacio para la card
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildOptionsCard(context),
                    ],
                  ),
                ),
              ],
            ),
            // Posicionamos la card del usuario sobre el contenedor verde
            Positioned(
              top: 20, // Ajusta esta posición según necesites
              left: 24,
              right: 24,
              child: _buildUserCard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkCardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: _darkCardColor),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user?.nombreApellido ?? 'Usuario',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _user?.email ?? 'email@example.com',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          children: [
            _buildProfileOption(
              context,
              icon: Icons.person_outline,
              label: 'Nombre',
              value: _user?.nombre ?? '-',
              isDestructive: false,
            ),
            _buildDivider(),
            _buildProfileOption(
              context,
              icon: Icons.person_outline,
              label: 'Apellidos',
              value:
                  '${_user?.apellidoPaterno ?? ''} ${_user?.apellidoMaterno ?? ''}'
                      .trim(),
              isDestructive: false,
            ),
            _buildDivider(),
            _buildProfileOption(
              context,
              icon: Icons.lock_outline,
              label: 'Email',
              value: _user?.email ?? '-',
              isDestructive: false,
            ),
            _buildDivider(),
            _buildProfileOption(
              context,
              icon: Icons.security,
              label: 'Contraseña',
              value: '*********',
              isDestructive: false,
            ),
            _buildDivider(),
            _buildProfileOption(
              context,
              icon: Icons.logout,
              label: 'Cerrar sesión',
              value: 'cerrar sesión por seguridad',
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDestructive,
  }) {
    Color valueColor = isDestructive ? Colors.red.shade700 : Colors.black87;
    Color iconColor = isDestructive ? Colors.red.shade700 : _primaryColor;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isDestructive ? Colors.red.shade700 : Colors.black54,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: valueColor,
          fontWeight: isDestructive ? FontWeight.normal : FontWeight.w500,
        ),
      ),
      trailing:
          isDestructive
              ? Icon(Icons.arrow_forward_ios, size: 16, color: valueColor)
              : null,
      onTap: () async {
        if (isDestructive) {
          await AuthService.logout();
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      },
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        height: 0,
        color: Color.fromARGB(255, 230, 230, 230),
        thickness: 1.0,
      ),
    );
  }
}
