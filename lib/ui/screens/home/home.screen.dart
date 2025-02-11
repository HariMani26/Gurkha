import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ghurka/ui/screens/home/widgets/flotting.screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Container(
          margin: const EdgeInsets.only(bottom: 0.0), // Set bottom margin
          child: PopupMenu(),
        ),
      ),
    );
  }
}
