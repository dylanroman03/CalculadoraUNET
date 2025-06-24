import 'package:flutter/material.dart';

class GradesNeededDisplay extends StatelessWidget {
  final List<Map<String, dynamic>> gradesNeeded;
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (gradesNeeded.isEmpty) ...[
                  Row(
                    children: [
                      Text(
                        "Haz finalizado el curso",
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Tu nota final es ${finalGrade!.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: size.width * 0.044,
                    ),
                  )
                ] else ...[
                  Row(
                    children: [
                      Text(
                        "¿Cuánto Falta?",
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ...gradesNeeded.map(
                    (entry) {
                      final targetGrade = (entry["targetGrade"] + 0.5).toInt();
                      final pointsNeeded = entry["pointsNeeded"].toInt();
                      return Row(
                        children: [
                          Text(
                            "Para $targetGrade ",
                            style: TextStyle(
                              fontSize: size.width * 0.044,
                              color:
                                  pointsNeeded == 0 ? Colors.red : Colors.black,
                            ),
                          ),
                          Text(
                            pointsNeeded == 0
                                ? "fuera de escala"
                                : "necesitas ",
                            style: TextStyle(
                              fontSize: size.width * 0.044,
                              color:
                                  pointsNeeded == 0 ? Colors.red : Colors.black,
                            ),
                          ),
                          if (pointsNeeded != 0)
                            Text(
                              pointsNeeded.toString(),
                              style: TextStyle(
                                fontSize: size.width * 0.044,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 156, 43),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ]
              ],
            ),
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
