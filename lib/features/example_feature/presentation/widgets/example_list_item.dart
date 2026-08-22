import 'package:flutter/material.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';
import 'package:qde_eco_bahor/features/example_feature/domain/entities/example_entity.dart';

class ExampleListItem extends StatelessWidget {
  final ExampleEntity entity;

  const ExampleListItem({
    super.key,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: ThemeDimensions.spacingM * 0.75),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${entity.id}'),
        ),
        title: Text(
          entity.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          entity.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
