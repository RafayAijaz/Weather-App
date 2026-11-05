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
          value: 'assets/images/sun.png',
          weatherValue: '25 °C',
        ),
      ),
    );

    expect(find.text('3 PM'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('25 °C'), findsOneWidget);
  });

  testWidgets('AdditionalItem shows icon, label and value', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AdditionalItem(
          imageValue: 'assets/images/humidity.png',
          property: 'Humidity',
          value: '60',
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
  });
}
