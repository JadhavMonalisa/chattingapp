import 'package:chattingapp/services/api.dart';
import 'package:chattingapp/view/home_screen.dart';
import 'package:chattingapp/view/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2),(){
      //exit full screen
      //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,
              statusBarColor: Colors.white));

      if(API.auth.currentUser!=null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LoginScreen()));
      }
      });
  }

  @override
  Widget build(BuildContext context) {
   Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: size.height * .15,
              width: size.width * .5,
              right: size.width * .25,
              child: Image.asset("assets/images/icon.png")),
          Positioned(
              bottom: size.height * .15,
              width: size.width,
              child: const Center(child: Text("Chatting App"))),
        ],
      ),
    );
  }
}
