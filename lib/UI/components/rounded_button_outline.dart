import 'package:flutter/material.dart';

class RoundedButtonOutline extends OutlinedButton {
  const RoundedButtonOutline({
    super.key,
    required super.onPressed,
    required super.child,
  });

  @override
  ButtonStyle? get style => OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );
}
