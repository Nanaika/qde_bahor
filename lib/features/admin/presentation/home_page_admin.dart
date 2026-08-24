import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                context.push('/add_product');
              },
              child: Text('add product')),
          SizedBox(
            height: ThemeDimensions.paddingM,
          ),
          ElevatedButton(
              onPressed: () {
                context.push('/add_product_type');
              },
              child: Text('add type')),
        ],
      ),
    );
  }
}
