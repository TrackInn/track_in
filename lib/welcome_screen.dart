import 'package:flutter/material.dart';
import 'package:track_in/login_screen.dart'; // Import your LoginScreen
import 'package:track_in/registration.dart'; // Import your RegisterScreen
import 'package:track_in/widgets/custom_scaffold.dart'; // Import CustomScaffold
import 'package:track_in/widgets/welcome_button.dart'; // Import WelcomeButton

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          // Icon and Text Section
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Icon(
                      Icons.track_changes, // Using track_changes icon
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20), // Spacing
                    // Text
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome Back!\n',
                            style: TextStyle(
                              fontSize: 45.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text:
                                '\nEnter personal details to your employee account',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Buttons Section
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  // Sign In Button
                  const Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: LoginScreen(), // Navigate to LoginScreen
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  // Sign Up Button
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: RegisterScreen(), // Navigate to RegisterScreen
                      color: Colors.white,
                      textColor: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
