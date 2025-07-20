import 'dart:math';
import 'dart:ui';

import 'package:chatapp/data/constants.dart';
import 'package:chatapp/data/personal_theme_data.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/services/supabase_service.dart';
import 'package:chatapp/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

TextEditingController tControl = TextEditingController();
TextEditingController tControl2 = TextEditingController();

class EmailLoginPage extends ConsumerStatefulWidget {
  const EmailLoginPage({super.key});

  @override
  ConsumerState<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends ConsumerState<EmailLoginPage> {
  Status status = Status.notStarted;
  String result='';
  bool hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;

    // Safe navigation
    if (status == Status.success && !hasNavigated) {

      hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
         ref.read(userIdProvider.notifier).setId();
         ref.read(HttpServiceProvider).setAuthToken();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      });
    }

    return Scaffold(
      appBar: AppBar(actions: [ThemeButton()]),
      body: switch (status) {
        Status.notStarted => _buildLoginForm(width),
        Status.loading => _buildLoadingScreen(),
        Status.failed => _buildErrorScreen(width),
        Status.success => const SizedBox.shrink(), // Prevents UI flash on navigation
      },
    );
  }

  Widget _buildLoginForm(double width) {
    return Center(
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
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  onPressed: _handleLogin,
                  style: PersonalThemeData.btnStyle(context),
                  child: SizedBox(
                    width: min(width, 300),
                    child: const Center(child: Text('Login using Email')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorScreen(double width) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Login Failed.\n$result',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() => status = Status.notStarted);
            },
            style: PersonalThemeData.btnStyle(context),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      status = Status.loading;
      
    });

    try {
      result = await ref.read(supabaseServiceProvider).signIn(tControl.text, tControl2.text);
      // You may validate result here if needed
      setState(() { status=  result=='success'? Status.success:Status.failed;
      
  
      });
    } catch (e) {
      setState(() {
        status = Status.failed;
        result = e.toString().replaceFirst('Exception:', '').trim();
      });
    }
  }
}
