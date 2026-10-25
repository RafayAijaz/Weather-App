import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/widgets/additional_item.dart';
import 'package:weather_app/widgets/heading.dart';
import 'package:weather_app/widgets/hourly_update.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late double temp;
  bool isLoading = false;
  late Future<Map<String, dynamic>> weather;
  String apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      isLoading = true;
      String cityName = "Islamabad";
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An Unexpected error occurred';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  void themetoLight() {}

  double kelvinToCelsius(double value) {
    return value - 273.15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: IconButton(
              onPressed: () {
                if (themeNotifier.value == ThemeMode.dark) {
                  themeNotifier.value = ThemeMode.light;
                } else {
                  themeNotifier.value = ThemeMode.dark;
                }
              },
              icon: Icon(
                themeNotifier.value == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather();
                });
              },
              icon: Icon(Icons.restart_alt),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text(asyncSnapshot.error.toString()));
          }

          final data = asyncSnapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = num.parse(
            (kelvinToCelsius(
              currentWeatherData['main']['temp'],
            )).toStringAsFixed(0),
          );
          final currentWeather = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: 200,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Enter City Name",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(onPressed: () {}, 
                      style: ElevatedButton.styleFrom(
                        
                      ),
                      child: Text("Submit")),
                    ],
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Heading(content: "$currentTemp °C"),
                                SizedBox(height: 10),
                                Icon(
                                  currentWeather == "Clouds" ||
                                          currentWeather == "Rain"
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 60,
                                ),
                                SizedBox(height: 10),
                                Text(currentWeather),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Heading(content: "Weather Forecast"),
                  Column(
                    children: [
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final hourlydata = data['list'][index + 1];
                            final time = DateTime.parse(hourlydata['dt_txt']);
                            final hourlyweather =
                                hourlydata['weather'][0]['main'];
                            final hourlytemp = num.parse(
                              kelvinToCelsius(
                                hourlydata['main']['temp'],
                              ).toStringAsFixed(0),
                            );

                            return HourlyUpdate(
                              hour: DateFormat.j().format(time),
                              weatherIcon:
                                  hourlyweather == "Clouds" ||
                                      hourlyweather == "Rain"
                                  ? Icons.cloud
                                  : Icons.sunny,
                              weatherValue: "${hourlytemp.toString()} °C",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Heading(content: "Additional Information"),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalItem(
                          childicon: Icons.water_drop,
                          property: "Humidity",
                          value: currentHumidity.toString(),
                        ),
                        AdditionalItem(
                          childicon: Icons.air,
                          property: "Wind",
                          value: currentWindSpeed.toString(),
                        ),
                        AdditionalItem(
                          childicon: Icons.beach_access,
                          property: "Pressure",
                          value: currentPressure.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
