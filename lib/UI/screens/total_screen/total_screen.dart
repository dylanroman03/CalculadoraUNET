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
  List<Map<String, dynamic>> _gradesNeeded = [];
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

      if (_inputRows.isEmpty) {
        _clearView();
      }

      _validateInputs();
    });
  }

  void _validateInputs() {
    double totalPercentage = 0;
    bool allValid = true;
    bool allPercentagesZero = true;

    for (var row in _inputRows) {
      final percentage = parseRowValue(row, "percentage");
      final calification = parseRowValue(row, "calification");

      row["percentageError"] = !isValidRange(percentage);
      row["calificationError"] = !isValidRange(calification);

      if (row["percentageError"] || row["calificationError"]) {
        allValid = false;
      }

      if (percentage > 0) {
        allPercentagesZero = false;
      }

      if (!row["percentageError"]) {
        totalPercentage += percentage;
      }
    }

    if (totalPercentage > 100) {
      allValid = false;
    }

    _isPercentageExceeded = totalPercentage > 100;

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
        .map((row) => parseRowValue(row, "calification", def: 0))
        .toList();
    List<double> weights = _inputRows
        .map((row) => parseRowValue(row, "percentage", def: 0))
        .toList();

    final result = calcularNotaFinal(grades, weights);

    setState(() {
      _convertedGrades = result["convertedGrades"];
      _finalGrade = result["finalGrade"];
    });

    bool allInputsFilled = _inputRows.length == 4 &&
        _inputRows.every((row) => parseRowValue(row, "percentage", def: 0) > 0);

    final totalWeight = weights.reduce((a, b) => a + b);
    bool percentagesSumTo100 = totalWeight == 100;

    if (_finalGrade != null && !allInputsFilled && !percentagesSumTo100) {
      List<double> thresholds = [1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5];

      List<Map<String, dynamic>> gradesNeeded = thresholds
          .where((threshold) => threshold > _finalGrade!)
          .map((threshold) {
        return {
          "targetGrade": threshold,
          "pointsNeeded": howLeftTo(
            _finalGrade!,
            threshold,
            100 - totalWeight,
          ),
        };
      }).toList();

      setState(() {
        _gradesNeeded = gradesNeeded;
      });
    }
  }

  void _clearView() {
    for (var row in _inputRows) {
      row["percentage"]?.text = "0";
      row["calification"]?.text = "0";
    }
    _convertedGrades = [];
    _gradesNeeded = [];
    _finalGrade = null;
  }

  double parseRowValue(
    Map<String, dynamic> row,
    String key, {
    double def = -1,
  }) {
    final text = row[key]?.text ?? "0";
    return double.tryParse(text) ?? def;
  }

  bool isValidRange(double value) => value >= 0 && value <= 100;

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
        children: [
          Container(
            color: AppTheme.nearlyBlue,
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.04),
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
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
                    SizedBox(height: size.height * 0.02),
                    if (_isPercentageExceeded)
                      const PercentageExceededWarning(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: size.width * 0.9,
                            child: RoundedButtonOutline(
                              onPressed: () {
                                setState(() {
                                  _clearView();
                                  _validateInputs();
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: Text(
                                  "Limpiar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: size.width * 0.9,
                            child: RoundedButton(
                              onPressed: _isCalculateButtonEnabled
                                  ? _calculateFinalGrade
                                  : null,
                              backgroundColor: _isCalculateButtonEnabled
                                  ? AppTheme.nearlyBlue
                                  : Colors.grey,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
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
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    if (_gradesNeeded.isNotEmpty || _finalGrade != null)
                      GradesNeededDisplay(
                        gradesNeeded: _gradesNeeded,
                        finalGrade: _finalGrade,
                        size: size,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
