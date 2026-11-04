import 'package:flutter/material.dart';

import '../../core/utils/type_colors.dart';

class TypeChip extends StatelessWidget {
  final String type;
  final bool small;

  const TypeChip({super.key, required this.type, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = TypeColors.get(type);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
