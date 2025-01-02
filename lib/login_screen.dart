import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                  fillColor: Colors.blue,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  label: Text("Username")),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
                onPressed: () {},
                child: Text("Login"))
          ],
        ),
      ),
    );
  }
}
