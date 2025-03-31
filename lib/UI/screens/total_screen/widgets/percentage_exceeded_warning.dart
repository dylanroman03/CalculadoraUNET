import 'package:flutter/material.dart';

class PercentageExceededWarning extends StatelessWidget {
  const PercentageExceededWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          weight: 10,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        const Text(
          "La suma de los porcentajes excede 100%",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
