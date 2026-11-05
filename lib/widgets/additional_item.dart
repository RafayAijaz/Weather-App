import "package:flutter/material.dart";

class AdditionalItem extends StatelessWidget {
  final String imageValue;
  final String property;
  final String value;
  
   const AdditionalItem({required this.imageValue, required this.property, required this.value ,super.key});

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
            Image.asset(imageValue, height: 40, width: 40,),
            Text(property),
            Text(value),
          ],
        ),
      ),
    );
  }
}