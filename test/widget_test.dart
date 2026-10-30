import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/widgets/additional_item.dart';
import 'package:weather_app/widgets/heading.dart';
import 'package:weather_app/widgets/hourly_update.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('Heading shows its text', (tester) async {
    await tester.pumpWidget(wrap(const Heading(content: 'Weather Forecast')));

    expect(find.text('Weather Forecast'), findsOneWidget);
  });

  testWidgets('HourlyUpdate shows hour, icon and temperature', (tester) async {
    await tester.pumpWidget(
      wrap(
        const HourlyUpdate(
          hour: '3 PM',
          weatherIcon: Icons.sunny,
          weatherValue: '25 °C',
        ),
      ),
    );

    expect(find.text('3 PM'), findsOneWidget);
    expect(find.byIcon(Icons.sunny), findsOneWidget);
    expect(find.text('25 °C'), findsOneWidget);
  });

  testWidgets('AdditionalItem shows icon, label and value', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AdditionalItem(
          childicon: Icons.water_drop,
          property: 'Humidity',
          value: '60',
        ),
      ),
    );

    expect(find.byIcon(Icons.water_drop), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
  });
}
