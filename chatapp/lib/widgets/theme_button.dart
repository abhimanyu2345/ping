import 'package:chatapp/state_management/value_notifers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: isDark, builder:(context, value, child) {
      return  IconButton(onPressed: ()async{
      isDark.value= !value;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDark', !value);

    }, icon: Icon(value? Icons.dark_mode:Icons.light_mode));
    },);
  }
}