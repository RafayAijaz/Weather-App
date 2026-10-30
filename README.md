# Weather App

A Flutter weather app that shows the current weather and a short forecast for any city, using the [OpenWeatherMap](https://openweathermap.org/) API.

## Features

- Search weather by city name
- Current temperature, condition, humidity, wind speed and pressure
- Forecast for the next 15 hours in 3-hour steps
- Light and dark mode
- Splash screen and custom launcher icon

## Tech

Flutter · Dart · `http` · `intl` · `flutter_dotenv` · OpenWeatherMap 5-day forecast API

## Getting started

1. Get a free API key from [openweathermap.org](https://home.openweathermap.org/api_keys).
2. Copy the example env file and add your key:
   ```sh
   cp .env.example .env
   ```
   ```
   WEATHER_API_KEY=your_openweathermap_api_key
   ```
3. Install packages and run:
   ```sh
   flutter pub get
   flutter run
   ```

The `.env` file is gitignored, so your key stays out of version control.

## Tests

```sh
flutter test
```
