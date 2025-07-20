import 'dart:math';
import 'dart:ui';

import 'package:chatapp/data/personal_theme_data.dart';
import 'package:chatapp/pages/login_signup/email_login_page.dart';
import 'package:chatapp/pages/login_signup/email_sing_up_page.dart';
import 'package:chatapp/pages/login_signup/ph_auth_page.dart';
import 'package:chatapp/widgets/theme_button.dart';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true; // 🔥 Moved to class-level

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        
        actions: const [ThemeButton()],
      ),
      body:
      
       Stack(
        fit: StackFit.expand,
        children: [
          // Dark background
          Container(),
        
          

          // Blurred, semi-transparent white card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: width,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          }
                        },
                        icon: Icon(
                          isLogin ? Icons.login : Icons.person_add,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 20),
                       isLogin ? 
                      Hero(
                        tag: 'sign',
                        child: Text('Login' ,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ):Hero(
                        tag: 'sign',
                        child: Text('SignUp' ,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  isLogin? EmailLoginPage():EmailSignUpPage() //EmailSignUpPage(),
                            ),
                          );
                        },
                        style: PersonalThemeData.btnStyle(context),
                        child: SizedBox(
                          width: min(width, 300),
                          child: Center(
                            child: Text(
                              isLogin
                                  ? 'Login using Email'
                                  : 'Signup with Email',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  PhAuthPage(),
                            ),
                          );
                        },
                        style: PersonalThemeData.btnStyle(context),
                        
                        child: SizedBox(
                          width: min(width, 300),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 Text(
                              isLogin
                                  ? 'Login using Phone'
                                  : 'Signup with Phone',
                            ),
                                SizedBox(width: 10), // 🔥 spacing between text and icon
                                Icon(Icons.phone),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
