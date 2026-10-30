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
  String currentCity = "Islamabad";
  late Future<Map<String, dynamic>> weather;
  String apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  final TextEditingController _controller = TextEditingController();

  Future<Map<String, dynamic>> getCurrentWeather({String? city}) async {
    try {
      String cityName = city ?? currentCity;
      final res = await http.get(
        Uri.https('api.openweathermap.org', 'data/2.5/forecast', {
          'q': cityName,
          'APPID': apiKey,
          'units': 'metric',
        }),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw data['message'] ?? 'An Unexpected error occurred';
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

  void searchCity() {
    final cityName = _controller.text.trim();
    if (cityName.isEmpty) return;
    setState(() {
      currentCity = cityName;
      weather = getCurrentWeather(city: currentCity);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  weather = getCurrentWeather(city: currentCity);
                });
              },
              icon: Icon(Icons.restart_alt),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => searchCity(),
                    decoration: InputDecoration(
                      hintText: "Enter City Name",
                      prefixIcon: Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: searchCity,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Submit"),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: weather,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }

                if (asyncSnapshot.hasError) {
                  return Center(child: Text(asyncSnapshot.error.toString()));
                }

                final data = asyncSnapshot.data!;
                final currentWeatherData = data['list'][0];
                final currentTemp = (currentWeatherData['main']['temp'] as num)
                    .round();

                final currentWeather = currentWeatherData['weather'][0]['main'];
                final currentPressure = currentWeatherData['main']['pressure'];
                final currentWindSpeed = currentWeatherData['wind']['speed'];
                final currentHumidity = currentWeatherData['main']['humidity'];
                final selectedCity = data['city']['name'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 30,
                                  ),
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
                                      SizedBox(height: 10),
                                      Text(
                                        selectedCity,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
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
                                  final time =
                                      DateTime.fromMillisecondsSinceEpoch(
                                        hourlydata['dt'] * 1000,
                                      );
                                  final hourlyweather =
                                      hourlydata['weather'][0]['main'];
                                  final hourlytemp =
                                      (hourlydata['main']['temp'] as num)
                                          .round();

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
          ),
        ],
      ),
    );
  }
}
