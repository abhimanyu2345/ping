
import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/pages/login_signup/login_page.dart';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WidgetTree extends ConsumerStatefulWidget {
  const WidgetTree({super.key});

  @override
  ConsumerState<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends ConsumerState<WidgetTree> {
  @override
  void initState() {

    

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   final  value = ref.watch(userIdProvider);
  
      
      return value==null?LoginPage():HomePage();
      



    }
      
    
  }
