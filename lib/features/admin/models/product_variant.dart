enum UnitType { kg, pcs, liter } // Кг, Граммы, Штуки, Литры

class ProductVariant {
  final String id;
  final String name; // Например: "Мешок 10 кг", "Коробка (10 шт по 1 л)"
  final double price; // Цена фасовки
  final double value; // Численное значение объема/количества
  final UnitType unit; // Единица измерения
  final int? itemsInPackage; // Кол-во штук в упаковке

  // Новые поля для веса
  final double netWeight; // Вес нетто (в кг)
  final double grossWeight; // Вес брутто (в кг)

  ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.value,
    required this.unit,
    required this.netWeight,
    required this.grossWeight,
    this.itemsInPackage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'value': value,
        'unit': unit.name,
        'itemsInPackage': itemsInPackage,
        'netWeight': netWeight,
        'grossWeight': grossWeight,
      };

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        value: (json['value'] as num).toDouble(),
        unit: UnitType.values.byName(json['unit']),
        itemsInPackage: json['itemsInPackage'],
        netWeight: (json['netWeight'] as num).toDouble(),
        grossWeight: (json['grossWeight'] as num).toDouble(),
      );
}
