import 'package:flutter/material.dart';

class PersonalThemeData {

  static  ButtonStyle btnStyle(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
     return ElevatedButton.styleFrom(
      backgroundColor: isDark?Colors.white:Colors.black87,
      foregroundColor: isDark?Colors.black87: Colors.white,);
                           }
}
