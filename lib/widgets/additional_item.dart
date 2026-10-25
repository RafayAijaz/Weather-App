import "package:flutter/material.dart";

class AdditionalItem extends StatelessWidget {
  final IconData childicon;
  final String property;
  final String value;
   const AdditionalItem({required this.childicon, required this.property, required this.value ,super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 100,
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(childicon, size: 35),
            Text(property),
            Text(value),
          ],
        ),
      ),
    );
  }
}