import 'dart:math';
import 'dart:ui';
import 'package:chatapp/data/personal_theme_data.dart';
import 'package:chatapp/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhAuthPage extends StatelessWidget {
  const PhAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;
    PhoneNumber number = PhoneNumber(isoCode: 'IN'); // initial country code

    return Scaffold(
      appBar: AppBar(
        actions: [ThemeButton()],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dark background
          Container(
            

          ),

          // Blurred, semi-transparent white card
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
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                      const SizedBox(height: 20),
                      InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          print(number.phoneNumber);
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.DIALOG,
                          trailingSpace: false,
                        ),
                        initialValue: number,
                        inputDecoration: const InputDecoration(
                          labelText: 'Phone Number',

                         
                          border: OutlineInputBorder(),
                        ),
                       
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Handle next button tap
                        },
                        style: PersonalThemeData.btnStyle(context),
                        
                        child: SizedBox(
                          width: min(width, 300),
                          child: const Center(child: Text('Next')),
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
