import 'package:calculadora_unet/UI/app_theme.dart';
import 'package:flutter/material.dart';

class RoundedInputDecoration extends InputDecoration {
  final bool isError;

  const RoundedInputDecoration({this.isError = false});

  @override
  InputBorder? get enabledBorder => OutlineInputBorder(
        borderSide: BorderSide(
          color: isError ? AppTheme.nearlyRed : AppTheme.lightText,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      );

  @override
  InputBorder? get focusedBorder => OutlineInputBorder(
        borderSide: BorderSide(
          color: isError ? AppTheme.nearlyRed : AppTheme.nearlyBlue,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      );

  @override
  TextStyle? get labelStyle => TextStyle(
        color: isError ? AppTheme.nearlyRed : null,
      );

  @override
  TextStyle? get hintStyle => const TextStyle(
        fontSize: 15,
        color: AppTheme.lightText,
        fontWeight: FontWeight.w300,
      );
}
