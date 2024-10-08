import 'package:flutter/material.dart';

class StudentLiveClasses extends StatefulWidget {
  const StudentLiveClasses({super.key});

  @override
  State<StudentLiveClasses> createState() => _StudentLiveClassesState();
}

class _StudentLiveClassesState extends State<StudentLiveClasses> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:Center(
        child: Text("StudentLiveClasses"),
      )
    );
  }
}