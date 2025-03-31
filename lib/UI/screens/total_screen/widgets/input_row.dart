import 'package:calculadora_unet/UI/app_theme.dart';
import 'package:calculadora_unet/UI/components/rounded_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputRow extends StatelessWidget {
  final Map<String, dynamic> controllers;
  final int index;
  final List<double> convertedGrades;
  final VoidCallback onRemove;
  final VoidCallback onValidate;

  const InputRow({
    super.key,
    required this.controllers,
    required this.index,
    required this.convertedGrades,
    required this.onRemove,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{1,4}$')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final newText = newValue.text;
                  if (newText.length > 1 && newText.startsWith('0')) {
                    return newValue.copyWith(
                      text: newText.substring(1),
                      selection: TextSelection.collapsed(
                        offset: newText.length - 1,
                      ),
                    );
                  }
                  if (int.tryParse(newText) != null &&
                      int.parse(newText) > 100) {
                    return oldValue.copyWith(
                      text: oldValue.text,
                      selection: TextSelection.collapsed(
                        offset: oldValue.text.length,
                      ),
                    );
                  }
                  return newValue;
                }),
              ],
              onChanged: (_) => onValidate(),
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{1,4}$')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final newText = newValue.text;
                  if (newText.length > 1 && newText.startsWith('0')) {
                    return newValue.copyWith(
                      text: newText.substring(1),
                      selection: TextSelection.collapsed(
                        offset: newText.length - 1,
                      ),
                    );
                  }
                  if (int.tryParse(newText) != null &&
                      int.parse(newText) > 100) {
                    return oldValue.copyWith(
                      text: oldValue.text,
                      selection: TextSelection.collapsed(
                        offset: oldValue.text.length,
                      ),
                    );
                  }
                  return newValue;
                }),
              ],
              onChanged: (_) => onValidate(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              convertedGrades.length > index
                  ? convertedGrades[index].toStringAsFixed(1)
                  : "---",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: AppTheme.nearlyRed,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
