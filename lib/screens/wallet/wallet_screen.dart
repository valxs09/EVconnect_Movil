import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/payment_card_model.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';

class VirtualCardScreen extends StatefulWidget {
  const VirtualCardScreen({super.key});

  @override
  State<VirtualCardScreen> createState() => _VirtualCardScreenState();
}

class _VirtualCardScreenState extends State<VirtualCardScreen> {
  final Color _backgroundColor = const Color(0xFFF2F2F2);
  final Color _cardColor = const Color(0xFFFFFFFF);
  final Color _primaryBorderColor = const Color(0xFF52F2B8);
  final Color _buttonColor = const Color(0xFF2C403A);

  List<PaymentCardModel> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    print('🔍 [WalletScreen] Iniciando carga de métodos de pago...');

    // Verificar que el usuario esté autenticado
    final user = await AuthService.getCurrentUser();
    if (user == null) {
      print('❌ [WalletScreen] Usuario no autenticado');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesión expirada. Por favor, inicia sesión nuevamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    print('✅ [WalletScreen] Usuario autenticado: ${user.email}');
    print(
      '🔑 [WalletScreen] Stripe Customer ID: ${user.stripeCustomerId ?? "No disponible"}',
    );

    final cards = await PaymentService.getPaymentMethods();
    print('🔍 [WalletScreen] Tarjetas recibidas: ${cards.length}');

    setState(() {
      _cards = cards;
      _isLoading = false;
    });

    if (cards.isEmpty) {
      print('⚠️ [WalletScreen] No se encontraron tarjetas');
    }
  }

  Future<void> _setPrincipal(String id) async {
    final success = await PaymentService.setPrincipalCard(id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarjeta establecida como principal'),
          backgroundColor: Color(0xFF37A686),
        ),
      );
      _loadPaymentMethods(); // Recargar las tarjetas
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al establecer tarjeta como principal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCardLogo(String brand) {
    Color color;
    Widget logoWidget;

    // Convertir a mayúsculas para comparación
    String brandUpper = brand.toUpperCase();

    if (brandUpper == 'VISA') {
      color = const Color(0xFF1E4598);
      logoWidget = Text(
        'VISA',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: color,
        ),
      );
    } else if (brandUpper == 'MASTERCARD') {
      logoWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFEB001B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5F00),
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    } else {
      logoWidget = Text(
        brandUpper,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      );
    }

    return SizedBox(width: 60, child: logoWidget);
  }

  Widget _buildCardItem(PaymentCardModel card) {
    final bool isPrincipal = card.isPrincipal;

    return GestureDetector(
      onTap: () => _setPrincipal(card.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            top: BorderSide(color: _primaryBorderColor, width: 4.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              _buildCardLogo(card.brand),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${card.brand} \u2022\u2022\u2022\u2022 ${card.last4}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Expira: ${card.expiry}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (isPrincipal)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryBorderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Principal',
                    style: TextStyle(
                      color: Color(0xFF2C403A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CustomAppBar(title: 'Mi cartera', showBackButton: false),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF37A686)),
              )
              : _cards.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card_off,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes tarjetas registradas',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/payment',
                        );
                        if (result == true) {
                          _loadPaymentMethods();
                        }
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Agregar tarjeta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadPaymentMethods,
                color: const Color(0xFF37A686),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ..._cards.map((card) => _buildCardItem(card)).toList(),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/payment',
                          );
                          if (result == true) {
                            _loadPaymentMethods();
                          }
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Agregar nuevo método de pago',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
