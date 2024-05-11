import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading:const Icon(Icons.home),
         title: const Text("My Chat")  , actions: [
           IconButton(onPressed: (){}, icon: const Icon(Icons.search)),
           IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert)),
      ],),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          onPressed: (){},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
