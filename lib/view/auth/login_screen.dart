import 'package:chattingapp/main.dart';
import 'package:chattingapp/view/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500),(){
      setState(() {
        isAnimate=true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome")),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            top: size.height * .15,
              width: size.width * .5,
              right: isAnimate?size.width * .25:-size.width * .5,
              child: const Icon(Icons.message)),
          Positioned(
              bottom: size.height * .15,
              width: size.width * .9,
              left: size.width * .05,
              height: size.height * .06,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green,shape: const StadiumBorder(),elevation: 1),
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black,fontSize: 16.0),
                    children: [
                      TextSpan(text: "Login with ",),
                      TextSpan(text: "Google",style: TextStyle(fontWeight: FontWeight.w500))
                    ]
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
