import 'package:flutter/material.dart';

class HourlyUpdate extends StatelessWidget {
  final String hour;
  final IconData weatherIcon;
  final String weatherValue;
  const HourlyUpdate({required this.hour, required this.weatherIcon, required this.weatherValue, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
               hour,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10),
              Icon(weatherIcon, size: 30),
              SizedBox(height: 10),
              Text(weatherValue),
            ],
          ),
        ),
      ),
    );
  }
}
