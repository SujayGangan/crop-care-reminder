import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key, required this.cropName});

  final String cropName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$cropName Tasks')),
      body: Center(
          child: Text('List of tasks for $cropName',
              style: TextStyle(fontSize: 18))),
    );
  }
}
