import 'package:flutter/material.dart';
import '../config/theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? loadingText;

  const LoadingIndicator({super.key, this.loadingText});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              strokeWidth: 3.0,
              backgroundColor: kPrimaryColor.withOpacity(0.3),
            ),

            if (loadingText != null) ...[
              const SizedBox(height: 16),
              Text(
                loadingText!,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
