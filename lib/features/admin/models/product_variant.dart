enum UnitType { kg, pcs, liter } // Кг, Граммы, Штуки, Литры

class ProductVariant {
  final String id;
  final String name; // Например: "Мешок 10 кг", "Коробка (10 шт по 1 л)"
  final double price; // Цена фасовки
  final double value; // Численное значение объема/количества
  final UnitType unit; // Единица измерения
  final int? itemsInPackage; // Кол-во штук в упаковке

  final int buyQuantity;
  final int freeQuantity;

  final double netWeight;
  final double grossWeight;

  ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.value,
    required this.unit,
    required this.netWeight,
    required this.grossWeight,
    this.itemsInPackage,
    this.buyQuantity = 0,
    this.freeQuantity = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'value': value,
        'unit': unit.name,
        'itemsInPackage': itemsInPackage,
        'buyQuantity': buyQuantity,
        'freeQuantity': freeQuantity,
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
        buyQuantity: json['buyQuantity'] as int? ?? 0,
        freeQuantity: json['freeQuantity'] as int? ?? 0,
        netWeight: (json['netWeight'] as num).toDouble(),
        grossWeight: (json['grossWeight'] as num).toDouble(),
      );

  ProductVariant copyWith({
    String? id,
    String? name,
    double? price,
    double? value,
    UnitType? unit,
    int? itemsInPackage,
    int? buyQuantity,
    int? freeQuantity,
    double? netWeight,
    double? grossWeight,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      itemsInPackage: itemsInPackage ?? this.itemsInPackage,
      buyQuantity: buyQuantity ?? this.buyQuantity,
      freeQuantity: freeQuantity ?? this.freeQuantity,
      netWeight: netWeight ?? this.netWeight,
      grossWeight: grossWeight ?? this.grossWeight,
    );
  }
}
