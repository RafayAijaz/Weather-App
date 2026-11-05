import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/widgets/additional_item.dart';
import 'package:weather_app/widgets/heading.dart';
import 'package:weather_app/widgets/hourly_update.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentCity = "Islamabad";
  late Future<Map<String, dynamic>> weather;
  final String apiKey = const String.fromEnvironment('WEATHER_API_KEY');
  final TextEditingController _controller = TextEditingController();

  Future<Map<String, dynamic>> getCurrentWeather({String? city}) async {
    if (apiKey.isEmpty) {
      throw 'API key is missing. Run the app with --dart-define-from-file=.env';
    }

    try {
      String cityName = city ?? currentCity;
      final params = {'q': cityName, 'APPID': apiKey, 'units': 'metric'};

      final responses = await Future.wait([
        http.get(
          Uri.https('api.openweathermap.org', 'data/2.5/weather', params),
        ),
        http.get(
          Uri.https('api.openweathermap.org', 'data/2.5/forecast', params),
        ),
      ]).timeout(const Duration(seconds: 15));

      final current = jsonDecode(responses[0].body);
      final forecast = jsonDecode(responses[1].body);

      if (current['cod'].toString() != '200') {
        throw current['message'] ?? 'An Unexpected error occurred';
      }
      if (forecast['cod'].toString() != '200') {
        throw forecast['message'] ?? 'An Unexpected error occurred';
      }

      currentCity = cityName;
      return {'current': current, 'forecast': forecast};
    } on TimeoutException {
      throw 'The request timed out. Please try again.';
    } on http.ClientException {
      throw 'No internet connection. Please check your network and try again.';
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
      weather = getCurrentWeather(city: cityName);
    });
  }

  String getWeatherIcon(String mainCondition, String iconCode) {
    bool isNight = iconCode.endsWith('n');

    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return isNight ? 'assets/images/moon.png' : 'assets/images/sun.png';

      case 'clouds':
        return isNight
            ? 'assets/images/cloudy-night.png'
            : 'assets/images/cloudy-day.png';

      case 'rain':
      case 'drizzle':
        return 'assets/images/rain.png';

      case 'thunderstorm':
        return 'assets/images/thunderstorm.png';

      case 'snow':
        return 'assets/images/snow.png';

      default:
        return 'assets/images/cloud.png';
    }
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
                final currentWeatherData = data['current'];
                final forecastData = data['forecast'];
                final currentTemp = (currentWeatherData['main']['temp'] as num)
                    .round();

                final currentWeather = currentWeatherData['weather'][0]['main'];
                final currentPressure = currentWeatherData['main']['pressure'];
                final currentWindSpeed = currentWeatherData['wind']['speed'];
                final currentHumidity = currentWeatherData['main']['humidity'];
                final selectedCity = currentWeatherData['name'];
                final String iconCode =
                    currentWeatherData['weather'][0]['icon'];
                final int timezone = forecastData['city']['timezone'];

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
                                      Image.asset(
                                        getWeatherIcon(
                                          currentWeather,
                                          iconCode,
                                        ),
                                        height: 60,
                                        width: 60,
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
                              height: 160,
                              width: double.infinity,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  final hourlydata =
                                      forecastData['list'][index];
                                  final time =
                                      DateTime.fromMillisecondsSinceEpoch(
                                        (hourlydata['dt'] + timezone) * 1000,
                                        isUtc: true,
                                      );
                                  final hourlyweather =
                                      hourlydata['weather'][0]['main'];
                                  final String hourlyIconCode =
                                      hourlydata['weather'][0]['icon'];
                                  final hourlytemp =
                                      (hourlydata['main']['temp'] as num)
                                          .round();
                                  return HourlyUpdate(
                                    hour: DateFormat.j().format(time),
                                    value: getWeatherIcon(
                                      hourlyweather,
                                      hourlyIconCode,
                                    ),
                                    weatherValue: "$hourlytemp °C",
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
                                imageValue: "assets/images/humidity.png",
                                property: "Humidity",
                                value: "$currentHumidity %",
                              ),
                              AdditionalItem(
                                imageValue: "assets/images/wind.png",
                                property: "Wind",
                                value: "$currentWindSpeed m/s",
                              ),
                              AdditionalItem(
                                imageValue: "assets/images/pressure.png",
                                property: "Pressure",
                                value: "$currentPressure hPa",
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
