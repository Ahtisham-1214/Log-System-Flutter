import 'package:flutter/material.dart';

class ViewLogScreen extends StatefulWidget{
  const ViewLogScreen({super.key});

  @override
  ViewLogScreenState createState() => ViewLogScreenState();

}

class ViewLogScreenState extends State<ViewLogScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('View Log'),
        )
    );
  }
}