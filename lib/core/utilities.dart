double calculateGrade(double grade, double weight) {
  return grade * weight / 100;
}

double convertGrade(int valor) {
  if (valor == 0) return 0;

  List<int> columnas = [7, 18, 29, 40, 51, 63, 74, 85, 95];

  List<List<int>> filas = [
    [0, 16],
    [17, 27],
    [28, 38],
    [39, 50],
    [51, 61],
    [62, 72],
    [73, 83],
    [84, 94],
    [95, 100]
  ];

  int columna =
      filas.indexWhere((rango) => valor >= rango[0] && valor <= rango[1]);

  if (valor < columnas[columna] || columna == filas.length - 1) {
    return (columna + 1).toDouble();
  }

  int decimal = valor - columnas[columna];

  if (columna == 3 && decimal > 8 || columna == 4 && decimal > 3) {
    decimal = decimal - 1;
  }

  return (columna + 1) + decimal / 10;
}

int convertGradeInverse(double valor) {
  if (valor == 0) return 0;

  List<int> columnas = [7, 18, 29, 40, 51, 63, 74, 85, 95];

  List<List<int>> filas = [
    [0, 16],
    [17, 27],
    [28, 38],
    [39, 50],
    [51, 61],
    [62, 72],
    [73, 83],
    [84, 94],
    [95, 100]
  ];

  int baseIndex = valor.floor() - 1;
  if (baseIndex < 0) return 1;
  if (baseIndex >= columnas.length) return 0;

  int baseValue = columnas[baseIndex];
  double decimalPart = valor - valor.floor();

  int convertedValue = baseValue + (decimalPart * 10).round();

  if (convertedValue < filas[baseIndex][0]) {
    convertedValue = filas[baseIndex][0];
  } else if (convertedValue > filas[baseIndex][1]) {
    convertedValue = filas[baseIndex][1];
  }

  return convertedValue;
}

Map<String, dynamic> calcularNotaFinal(
  List<double> grades,
  List<double> weights,
) {
  double totalWeighted = 0;
  List<double> convertedGrades = [];

  for (int i = 0; i < grades.length; i++) {
    double convertedGrade = convertGrade(grades[i].toInt());
    convertedGrades.add(convertedGrade);
    totalWeighted += calculateGrade(convertedGrade, weights[i]);
  }

  return {
    "finalGrade": totalWeighted,
    "convertedGrades": convertedGrades,
  };
}

int howLeftTo(double grade, double gradeWanted, double weight) {
  double left = gradeWanted - grade;
  double leftWeighted = left * 100 / weight;

  return convertGradeInverse(leftWeighted);
}
