import 'package:flutter/material.dart';

class EditTenderScreen extends StatelessWidget {
  final Map data;

  const EditTenderScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Tender"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Edit Tender Screen"),
      ),
    );
  }
}
