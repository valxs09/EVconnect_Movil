import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomInputField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? customPrefix; // Para el input de teléfono
  final TextEditingController? controller;
  final VoidCallback? onSuffixTap;

  const CustomInputField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.customPrefix,
    this.controller,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          // Icono Prefix (o Widget personalizado)
          if (customPrefix == null)
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(prefixIcon, color: kTextDark, size: 20),
            )
          else
            customPrefix!,

          // Campo de texto principal
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: keyboardType,
              style: const TextStyle(color: kTextDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: kTextDark.withOpacity(0.5)),
                border: InputBorder.none, // Elimina el borde del TextField
                prefixIcon: customPrefix != null ? const SizedBox() : null,
                suffixIcon:
                    suffixIcon != null
                        ? GestureDetector(
                          onTap: onSuffixTap,
                          child: Icon(
                            suffixIcon,
                            color: kTextDark.withOpacity(0.5),
                            size: 20,
                          ),
                        )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
