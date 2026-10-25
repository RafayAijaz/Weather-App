import "package:flutter/material.dart";
import "package:weather_app/home_screen.dart";
import "package:weather_app/splash_screen.dart";


final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(valueListenable: themeNotifier, builder: (_,currentMode,_){
      return MaterialApp(
      title: "Weather App",


      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
         
      ),
      themeMode: currentMode,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
    });
  }
}


