String formatNumber(num number) {
  // Округляем до 1 знака после запятой
  final formatted = number.toStringAsFixed(1);
  final parts = formatted.split('.');

  // Форматируем целую часть пробелами
  parts[0] = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]} ',
  );

  // Если дробная часть '.0', убираем её
  if (parts.length > 1 && parts[1] == '0') {
    return parts[0];
  }

  return parts.join('.');
}

String formatCountNumber(num number) {
  // Конвертируем целое число в строку и форматируем пробелами
  return number.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
      );
}

String formatWeightNumber(num number) {
  // Округляем до 2 знаков после запятой
  final formatted = number.toStringAsFixed(2);
  final parts = formatted.split('.');

  // Форматируем целую часть пробелами через каждые 3 цифры
  parts[0] = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]} ',
  );

  return parts.join('.');
}
