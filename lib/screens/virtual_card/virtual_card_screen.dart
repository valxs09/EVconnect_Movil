import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class PaymentCard {
  final String id;
  final String brand;
  final String last4;
  final String expiry;

  PaymentCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
  });
}

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

  final List<PaymentCard> _cards = [
    PaymentCard(id: '1', brand: 'Visa', last4: '4567', expiry: '12/26'),
    PaymentCard(id: '2', brand: 'Mastercard', last4: '1234', expiry: '05/24'),
    PaymentCard(id: '3', brand: 'Amex', last4: '9876', expiry: '01/25'),
  ];

  String _principalCardId = '1';

  void _setPrincipal(String id) {
    setState(() {
      _principalCardId = id;
    });
  }

  Widget _buildCardLogo(String brand) {
    Color color;
    Widget logoWidget;

    if (brand == 'Visa') {
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
    } else if (brand == 'Mastercard') {
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
        brand,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      );
    }

    return SizedBox(width: 60, child: logoWidget);
  }

  Widget _buildCardItem(PaymentCard card) {
    final bool isPrincipal = card.id == _principalCardId;

    return GestureDetector(
      onTap: () => _setPrincipal(card.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border:
              isPrincipal
                  ? Border(
                    top: BorderSide(color: _primaryBorderColor, width: 4.0),
                  )
                  : null,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ..._cards.map((card) => _buildCardItem(card)).toList(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/payment');
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
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
    );
  }
}
