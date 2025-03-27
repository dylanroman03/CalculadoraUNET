import 'package:calculadora_unet/UI/app_theme.dart';
import 'package:calculadora_unet/UI/components/rounded_button.dart';
import 'package:calculadora_unet/UI/components/rounded_input_decoration.dart';
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

      totalPercentage += isPercentageValid ? percentage : 0;
    }

    if (totalPercentage > 100) {
      allValid = false;
      _isPercentageExceeded = true;
    } else {
      _isPercentageExceeded = false;
    }

    setState(() {
      _isCalculateButtonEnabled = allValid;
    });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 13),
              const Text(
                "Calcula Tu Nota Final",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 18),
              _buildHeaderRow(),
              ..._inputRows
                  .asMap()
                  .entries
                  .map((entry) => _buildInputRow(entry.value, entry.key)),
              const SizedBox(height: 10),
              _buildActionButtons(),
              const SizedBox(height: 40),
              if (_isPercentageExceeded)
                const Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      weight: 10,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "La suma de los porcentajes excede 100%",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              _buildCalculateButton(size),
              const SizedBox(height: 10),
              _buildClearButton(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return const Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            "Porcentaje",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Text(
            "Calificación",
            style: TextStyle(fontWeight: FontWeight.bold),
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
            flex: 1,
            child: TextFormField(
              controller: controllers["percentage"],
              decoration: RoundedInputDecoration(
                isError: controllers["percentageError"],
              ).copyWith(
                labelText: "% Parcial ${index + 1}",
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _validateInputs(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: controllers["calification"],
              decoration: RoundedInputDecoration(
                isError: controllers["calificationError"],
              ).copyWith(
                labelText: "Parcial ${index + 1}",
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _validateInputs(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_inputRows.length < 4)
          _buildOutlinedButton(
            onPressed: _addInputRow,
            color: Colors.green,
            icon: Icons.add,
            label: "Agregar",
          ),
        if (_inputRows.length > 1 && _inputRows.length < 4)
          const SizedBox(width: 8),
        if (_inputRows.length > 1)
          _buildOutlinedButton(
            onPressed: _removeInputRow,
            color: Colors.red,
            icon: Icons.remove,
            label: "Eliminar",
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
    return Expanded(
      flex: 1,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                label,
                style: TextStyle(fontSize: 16, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculateButton(Size size) {
    return SizedBox(
      width: size.width * 0.9,
      child: RoundedButton(
        onPressed: _isCalculateButtonEnabled ? () {} : null,
        backgroundColor:
            _isCalculateButtonEnabled ? AppTheme.nearlyBlue : Colors.grey,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            "Calcular Nota Final",
            style: TextStyle(fontSize: 16, color: Colors.white),
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
            "Limpiar Todo",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
