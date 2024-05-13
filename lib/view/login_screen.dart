import 'dart:developer';
import 'dart:io';
import 'package:chattingapp/components/widgets/custom_dialogs.dart';
import 'package:chattingapp/services/api.dart';
import 'package:chattingapp/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  handleSignIn(){
    //show progress bar
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
     //hide progress bar
      Navigator.pop(context);
      if (user != null) {
        if(await API.userExists()){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const HomeScreen()));

        }
        else{
          await API.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const HomeScreen()));

          });
        }
       }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
  try{
    await InternetAddress.lookup('google.com');
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);

  }
      catch(e){log(e.toString());}
        Dialogs.showSnackbar(context, "Please check internet");
    }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
              child: Image.asset("assets/images/icon.png")),
          Positioned(
              bottom: size.height * .15,
              width: size.width * .9,
              left: size.width * .05,
              height: size.height * .06,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,shape: const StadiumBorder(),elevation: 1),
                onPressed: (){
                  handleSignIn();
                },
                icon:Image.asset('assets/images/google.png', height: size.height * .03),
                label: RichText(
                  text: const TextSpan(
                      style: TextStyle(color: Colors.white,fontSize: 16.0),
                      children: [
                        TextSpan(text: "Login with ",),
                        TextSpan(text: "Google",style: TextStyle(fontWeight: FontWeight.w500))
                      ]
                  ),
                ),
                // child: RichText(
                //   text: const TextSpan(
                //     style: TextStyle(color: Colors.black,fontSize: 16.0),
                //     children: [
                //       TextSpan(text: "Login with ",),
                //       TextSpan(text: "Google",style: TextStyle(fontWeight: FontWeight.w500))
                //     ]
                //   ),
                // ),
              )),
        ],
      ),
    );
  }
}
