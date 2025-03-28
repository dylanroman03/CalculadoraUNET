import 'package:calculadora_unet/UI/app_theme.dart';
import 'package:calculadora_unet/UI/components/rounded_button.dart';
import 'package:calculadora_unet/UI/components/rounded_input_decoration.dart';
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

  void _removeInputRow() {
    if (_inputRows.length > 1) {
      setState(() {
        _inputRows.removeLast();
        _validateInputs();
      });
    }
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
      List<double> thresholds = [1.5, 2.5, 3.5, 4.5, 5.5, 6.7, 7.5, 8.5];
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
                    )
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
                _buildHeaderRow(),
                ..._inputRows
                    .asMap()
                    .entries
                    .map((entry) => _buildInputRow(entry.value, entry.key)),
                SizedBox(height: size.height * 0.01),
                _buildActionButtons(),
                SizedBox(height: size.height * 0.04),
                if (_isPercentageExceeded) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        weight: 10,
                      ),
                      SizedBox(width: size.width * 0.02),
                      const Text(
                        "La suma de los porcentajes excede 100%",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                ],
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Cuánto falta para cada nota:",
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ..._gradesNeeded.asMap().entries.map(
                        (entry) {
                          final threshold = [2, 3, 4, 5, 6, 7, 8, 9]
                              .where((threshold) => threshold > _finalGrade!)
                              .toList()[entry.key];
                          final value = entry.value.toInt();
                          return Text(
                            "Para $threshold necesitas: ${value == 0 ? "Fuera de la escala" : value}",
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              color: value == 0 ? Colors.red : Colors.black,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return const Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            "Porcentaje",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            "Calificación",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Text(
            "1-9",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow(Map<String, dynamic> controllers, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controllers["percentage"],
              decoration: RoundedInputDecoration(
                isError: controllers["percentageError"],
              ).copyWith(
                labelText: "% Parcial ${index + 1}",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _validateInputs(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controllers["calification"],
              decoration: RoundedInputDecoration(
                isError: controllers["calificationError"],
              ).copyWith(
                labelText: "Parcial ${index + 1}",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _validateInputs(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              _convertedGrades.length > index
                  ? _convertedGrades[index].toStringAsFixed(1)
                  : "---",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        const Expanded(
          flex: 5,
          child: SizedBox(),
        ),
        if (_inputRows.length > 1)
          _buildOutlinedButton(
            onPressed: _removeInputRow,
            color: Colors.red,
            icon: Icons.remove,
            label: "Eliminar",
          ),
        if (_inputRows.length < 4)
          _buildOutlinedButton(
            onPressed: _addInputRow,
            color: Colors.green,
            icon: Icons.add,
            label: "Agregar",
          ),
      ],
    );
  }

  Widget _buildOutlinedButton({
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Icon(
          icon,
          color: color,
        ),
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
      child: OutlinedButton(
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
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
