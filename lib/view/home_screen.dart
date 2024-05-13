import 'package:chattingapp/components/widgets/custom_dialogs.dart';
import 'package:chattingapp/components/widgets/user_card.dart';
import 'package:chattingapp/models/user_model.dart';
import 'package:chattingapp/services/api.dart';
import 'package:chattingapp/view/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list=[];

  @override
  void initState() {
    API.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {

      if (API.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          API.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          API.updateActiveStatus(false);
        }
      }
      return Future.value();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            leading:const Icon(Icons.home),
           title: const Text("My Chat")  , actions: [
             IconButton(onPressed: (){}, icon: const Icon(Icons.search)),
             IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert)),
        ],),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton(
            onPressed: () async{
              Dialogs.showProgressBar(context);
              await API.updateActiveStatus(false);
              await API.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // //for hiding progress dialog
                  // Navigator.pop(context);
                  //
                  // //for moving to home screen
                  // Navigator.pop(context);

                  //replacing home screen with login screen
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()));
                });
              });
            },
            child: const Icon(Icons.logout),
          ),
        ),
        body: StreamBuilder(
          stream: API.getAllUsers(),
          builder: (context, snapshot) {

            switch(snapshot.connectionState){
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator(),);
              case ConnectionState.active:
              case ConnectionState.done:

                final data = snapshot.data?.docs;

                list = data!.map((e) => ChatUser.fromJson((e.data()))).toList()??[];

                if(list.isNotEmpty){
                  return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top:10.0),
                      itemCount: list.length,
                      itemBuilder: (context,index){
                        return UserCard(userData:list[index]);
                      });
                }
                else{
                  return const Text("No collection found!");
                }
            }
          }
        ),
      ),
    );
  }

  signOut() async{
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
