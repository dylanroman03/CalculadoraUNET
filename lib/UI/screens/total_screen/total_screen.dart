import 'package:calculadora_unet/UI/app_theme.dart';
import 'package:calculadora_unet/UI/components/rounded_button.dart';
import 'package:calculadora_unet/UI/components/rounded_button_outline.dart';
import 'package:calculadora_unet/UI/screens/total_screen/widgets/grades_needed_display.dart';
import 'package:calculadora_unet/UI/screens/total_screen/widgets/header_row.dart';
import 'package:calculadora_unet/UI/screens/total_screen/widgets/input_row.dart';
import 'package:calculadora_unet/UI/screens/total_screen/widgets/percentage_exceeded_warning.dart';
import 'package:calculadora_unet/core/utilities.dart';
import 'package:flutter/material.dart';

class TotalScreen extends StatefulWidget {
  const TotalScreen({super.key});

  @override
  State<TotalScreen> createState() => _TotalScreenState();
}

class _TotalScreenState extends State<TotalScreen> {
  final List<Map<String, dynamic>> _inputRows = [];
  bool _isCalculateButtonEnabled = false;
  bool _isPercentageExceeded = false;
  List<double> _convertedGrades = [];
  List<double> _gradesNeeded = [];
  double? _finalGrade;

  @override
  void initState() {
    super.initState();
    _addInputRow();
  }

  void _addInputRow() {
    if (_inputRows.length < 4) {
      setState(() {
        _inputRows.add({
          "percentage": TextEditingController(text: "0"),
          "calification": TextEditingController(text: "0"),
          "percentageError": false,
          "calificationError": false,
        });
        _validateInputs();
      });
    }
  }

  void _removeSpecificInputRow(int index) {
    setState(() {
      _inputRows.removeAt(index);
      _validateInputs();
    });
  }

  void _validateInputs() {
    double totalPercentage = 0;
    bool allValid = true;
    bool allPercentagesZero = true;

    for (var row in _inputRows) {
      final percentageText = row["percentage"]?.text ?? "";
      final calificationText = row["calification"]?.text ?? "";

      final percentage = double.tryParse(percentageText) ?? -1;
      final calification = double.tryParse(calificationText) ?? -1;

      final isPercentageValid = percentage >= 0 && percentage <= 100;
      final isCalificationValid = calification >= 0 && calification <= 100;

      row["percentageError"] = !isPercentageValid;
      row["calificationError"] = !isCalificationValid;

      if (!isPercentageValid || !isCalificationValid) {
        allValid = false;
      }

      if (percentage > 0) {
        allPercentagesZero = false;
      }

      totalPercentage += isPercentageValid ? percentage : 0;
    }

    if (totalPercentage > 100) {
      allValid = false;
      _isPercentageExceeded = true;
    } else {
      _isPercentageExceeded = false;
    }

    setState(() {
      _isCalculateButtonEnabled = allValid && !allPercentagesZero;
    });
  }

  void _calculateFinalGrade() {
    FocusScope.of(context).unfocus();
    _finalGrade = 0;
    _convertedGrades = [];
    _gradesNeeded = [];

    List<double> grades = _inputRows
        .map((row) => double.tryParse(row["calification"]?.text ?? "0") ?? 0)
        .toList();
    List<double> weights = _inputRows
        .map((row) => double.tryParse(row["percentage"]?.text ?? "0") ?? 0)
        .toList();

    final result = calcularNotaFinal(grades, weights);

    setState(() {
      _convertedGrades = result["convertedGrades"];
      _finalGrade = result["finalGrade"];
    });

    bool allInputsFilled = _inputRows.length == 4 &&
        _inputRows.every((row) =>
            (double.tryParse(row["percentage"]?.text ?? "0") ?? 0) > 0);
    bool percentagesSumTo100 = weights.reduce((a, b) => a + b) == 100;

    if (_finalGrade != null && !allInputsFilled && !percentagesSumTo100) {
      List<double> thresholds = [1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5];
      List<int> gradesNeeded = thresholds
          .where((threshold) => threshold > _finalGrade!)
          .map((threshold) {
        return howLeftTo(
          _finalGrade!,
          threshold,
          100 - weights.reduce((a, b) => a + b),
        );
      }).toList();

      setState(() {
        _gradesNeeded = gradesNeeded.map((e) => e.toDouble()).toList();
      });
    }
  }

  @override
  void dispose() {
    for (var row in _inputRows) {
      row["percentage"]?.dispose();
      row["calification"]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: AppTheme.nearlyBlue,
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Nota Acumulada:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.025,
                        vertical: size.height * 0.005,
                      ),
                      child: Text(
                        _finalGrade != null
                            ? _finalGrade!.toStringAsFixed(2)
                            : "  -  ",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.02,
            ),
            child: Column(
              children: [
                const HeaderRow(),
                ..._inputRows.asMap().entries.map((entry) => InputRow(
                      controllers: entry.value,
                      index: entry.key,
                      convertedGrades: _convertedGrades,
                      onRemove: () => _removeSpecificInputRow(entry.key),
                      onValidate: _validateInputs,
                    )),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    if (_inputRows.length < 4)
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: GestureDetector(
                          onTap: _addInputRow,
                          child: const Text(
                            "+ Añadir Parcial",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
                if (_isPercentageExceeded) const PercentageExceededWarning(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildClearButton(size),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      flex: 1,
                      child: _buildCalculateButton(size),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                if (_gradesNeeded.isNotEmpty)
                  GradesNeededDisplay(
                    gradesNeeded: _gradesNeeded,
                    finalGrade: _finalGrade,
                    size: size,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalculateButton(Size size) {
    return SizedBox(
      width: size.width * 0.9,
      child: RoundedButton(
        onPressed: _isCalculateButtonEnabled ? _calculateFinalGrade : null,
        backgroundColor:
            _isCalculateButtonEnabled ? AppTheme.nearlyBlue : Colors.grey,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            "Calcular",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(Size size) {
    return SizedBox(
      width: size.width * 0.9,
      child: RoundedButtonOutline(
        onPressed: () {
          setState(() {
            for (var row in _inputRows) {
              row["percentage"]?.text = "0";
              row["calification"]?.text = "0";
            }
            _convertedGrades = [];
            _gradesNeeded = [];
            _finalGrade = null;
            _validateInputs();
          });
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            "Limpiar",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
