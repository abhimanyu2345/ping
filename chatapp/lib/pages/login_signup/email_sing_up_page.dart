import 'dart:math';
import 'dart:ui';

import 'package:chatapp/data/personal_theme_data.dart';
import 'package:chatapp/pages/user_creation_page.dart';
import 'package:chatapp/services/supabase_service.dart';
import 'package:chatapp/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

TextEditingController tControl = TextEditingController();
TextEditingController tControl2 = TextEditingController();

enum RegistrationStatus {
  registered,
  notRegistered,
  waiting,
  registering,
  failed
}

class EmailSignUpPage extends ConsumerStatefulWidget {
  const EmailSignUpPage({super.key});

  @override
  ConsumerState<EmailSignUpPage> createState() => _EmailSignUpPageState();
}

class _EmailSignUpPageState extends ConsumerState<EmailSignUpPage> {
  RegistrationStatus status = RegistrationStatus.notRegistered;
  late String response;
  bool hasNavigated = false; // ✅ Local state flag

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;

    // Safe navigation after registration
    if (status == RegistrationStatus.registered && !hasNavigated) {
      hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserCreationPage()),(route) => false,
        );
      });
    }

    Widget content;

    if (status == RegistrationStatus.notRegistered) {
      content = _buildSignUpForm(width);
    } else if (status == RegistrationStatus.waiting || status == RegistrationStatus.registering) {
      content = _buildWaitingScreen();
    } else if (status==RegistrationStatus.failed){
      content = _buildErrorScreen();
    }
    else {
  content = const SizedBox.shrink(); // 👈🏽 render nothing (or use a loader)
}

    return Scaffold(
      appBar: AppBar(
        actions: const [ThemeButton()],
      ),
      body: content,
    );
  }

  Widget _buildSignUpForm(double width) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background layer
        Container(),

        // Blurred card form
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: width,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tControl,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tControl2,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          status = RegistrationStatus.waiting;
                        });

                        try {
                          response = await ref.read(supabaseServiceProvider).emailSignUp(tControl.text, tControl2.text);
                          setState(() {
                            status = (response=='success')
                                ? RegistrationStatus.registered
                                : RegistrationStatus.failed;
                          });
                        } catch (e) {
                          setState(() {
                            status = RegistrationStatus.failed;
                  
                          });
                        }
                      },
                      style: PersonalThemeData.btnStyle(context),
                      child: SizedBox(
                        width: min(width, 300),
                        child: const Center(child: Text('Sign Up')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text(
            'Look for confirmation in your Email.\nDidn\'t get it?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                status = RegistrationStatus.waiting;
              });

              try {
                response = await ref.read(supabaseServiceProvider).emailSignUp(tControl.text, tControl2.text);
                setState(() {
                  status = (response=='success')
                      ? RegistrationStatus.registered
                      : RegistrationStatus.failed;
                });
              } catch (e) {
                setState(() {
                  status = RegistrationStatus.failed;
                });
              }
            },
            style: PersonalThemeData.btnStyle(context),
            child: const Text('Resend Confirmation Email'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Text(
            'Registration Failed.\n $response  .\nPlease try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                status = RegistrationStatus.notRegistered;
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
