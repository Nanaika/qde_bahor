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
