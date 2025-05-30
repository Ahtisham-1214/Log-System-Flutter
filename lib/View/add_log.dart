import 'package:flutter/material.dart';

class AddLogScreen extends StatefulWidget{
  const AddLogScreen({super.key});

  @override
  AddLogScreenState createState() => AddLogScreenState();

}

class AddLogScreenState extends State<AddLogScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Log'),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0),
      child: Form(
          child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Detail of Journey',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a detail of journey';
                }
                return null;
              }
            )


          ],
          )
      ),

      ),
    );
  }
}