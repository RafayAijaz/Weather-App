import 'package:flutter/material.dart';
import 'package:weather_app/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
 
    super.initState();
    _navigateToHome();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(image: AssetImage("assets/images/icon.png"), height: 300,),
            Text("Weather App", style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),)
          ],
        ),
      ),
    );
  }

  void _navigateToHome() async{
    await Future.delayed(const Duration(seconds: 2));
    if(mounted){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }
}