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
          mainAxisAlignment: MainAxisAlignment.center,
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
            SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                  fillColor: Colors.blue,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.password,
                    color: Colors.black,
                  ),
                  label: Text("Password")),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
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
