import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/pages/login_signup/login_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountLogoutWidget extends ConsumerWidget {
  const AccountLogoutWidget({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return ElevatedButton(onPressed: ()async{
      try{
        ref.read(userIdProvider.notifier).signout();
        ref.invalidate(userProfileProvider);
      
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
        return LoginPage();
      },), (route) => false,);
      }
      catch(e){
        print(e);
      }
      



    }, child: Text('Logout'));
  }
}