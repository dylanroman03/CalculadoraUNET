import 'package:calculadora_unet/UI/app_theme.dart';
import 'package:calculadora_unet/UI/components/rounded_input_decoration.dart';
import 'package:calculadora_unet/core/utilities.dart';
import 'package:flutter/material.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  final TextEditingController _grade1To9Controller = TextEditingController();
  final TextEditingController _grade1To100Controller = TextEditingController();
  bool _isGrade1To9Valid = true;
  bool _isGrade1To100Valid = true;

  void _validateGrade1To9(String value) {
    final grade = double.tryParse(value);
    setState(() {
      _isGrade1To9Valid = grade != null && grade >= 1 && grade <= 9;
      if (_isGrade1To9Valid) {
        final converted = convertGradeInverse(grade!);
        _grade1To100Controller.text = converted.toString();
      }
    });
  }

  void _validateGrade1To100(String value) {
    final grade = int.tryParse(value);
    setState(() {
      _isGrade1To100Valid = grade != null && grade >= 0 && grade <= 100;
      if (_isGrade1To100Valid) {
        final converted = convertGrade(grade!);
        _grade1To9Controller.text = converted.toStringAsFixed(1);
      }
    });
  }

  @override
  void dispose() {
    _grade1To9Controller.dispose();
    _grade1To100Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: size.height * 0.12,
            color: AppTheme.nearlyBlue,
            padding: EdgeInsets.only(top: size.width * 0.025),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Convertir Nota",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              children: [
                TextField(
                  controller: _grade1To9Controller,
                  decoration: const RoundedInputDecoration().copyWith(
                    labelText: "Nota (1-9)",
                    errorText: _isGrade1To9Valid
                        ? null
                        : "Ingrese un valor entre 1 y 9",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _validateGrade1To9,
                ),
                SizedBox(height: size.height * 0.02),
                TextField(
                  controller: _grade1To100Controller,
                  decoration: const RoundedInputDecoration().copyWith(
                    labelText: "Nota (1-100)",
                    errorText: _isGrade1To100Valid
                        ? null
                        : "Ingrese un valor entre 0 y 100",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _validateGrade1To100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
