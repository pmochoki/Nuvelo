import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';

class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.price,
    required this.lang,
    required this.priceOnRequestLabel,
  });

  final double? price;
  final String lang;
  final String priceOnRequestLabel;

  @override
  Widget build(BuildContext context) {
    final text = price == null
        ? priceOnRequestLabel
        : formatPrice(price, lang);
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: NuveloColors.primaryOrange,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
