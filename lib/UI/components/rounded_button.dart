import 'package:calculadora_unet/UI/app_theme.dart';
import 'package:flutter/material.dart';

class RoundedButton extends TextButton {
  final Color? backgroundColor;

  const RoundedButton({
    super.key,
    required super.onPressed,
    required super.child,
    this.backgroundColor,
  });

  @override
  ButtonStyle? get style => TextButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.nearlyBlue,
        textStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.25),
      );
}
