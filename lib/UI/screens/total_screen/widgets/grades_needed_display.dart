import 'package:flutter/material.dart';

class GradesNeededDisplay extends StatelessWidget {
  final List<double> gradesNeeded;
  final double? finalGrade;
  final Size size;

  const GradesNeededDisplay({
    super.key,
    required this.gradesNeeded,
    required this.finalGrade,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: size.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "¿Cuánto falta?",
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ...gradesNeeded.asMap().entries.map(
                (entry) {
                  final threshold = [2, 3, 4, 5, 6, 7, 8, 9]
                      .where((threshold) => threshold > finalGrade!)
                      .toList()[entry.key];
                  final value = entry.value.toInt();
                  return Text(
                    "Para $threshold ${value == 0 ? "Fuera de la escala" : "necesitas $value"}",
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      color: value == 0 ? Colors.red : Colors.black,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(width: size.width * 0.04),
        Image.asset(
          "assets/image-removebg-preview.png",
          width: size.width * 0.38,
        )
      ],
    );
  }
}
