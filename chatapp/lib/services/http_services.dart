import 'dart:convert';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/data/constants.dart';
import 'package:chatapp/data/models/user_data.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HttpServices{

    Dio? _dio;
    final Ref ref;






    HttpServices(this.ref){
    _dio =
    Dio(
    BaseOptions(
      baseUrl: 'http$backendUrl',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
   }
   

  

  // You can call this after login to inject token
  Future<void> setAuthToken() async {

    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    print('token got $token');
    if (token != null) {
      _dio!.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Register user profile
  Future<bool> userRegister(UserProfileData payload) async {
  try {
     await setAuthToken();

      Response response = await _dio!.post('/register', data: jsonEncode(payload));

      if (response.statusCode!=null && response.statusCode == 200) {
        return true;
      }
    
    return false;
  } on DioException catch (e) {
    print("Dio error during register: ${e.response?.statusCode} - ${e.message}");
    print("Response data: ${e.response?.data}");
    return false;
  } catch (e) {
    print("Unexpected error: $e");
    return false;
  }
}

 Future<void> fetchMessages() async {
  try {
    String id = Supabase.instance.client.auth.currentUser!.id;

    var response = await _dio!.post('/messages/$id');

    if (response.statusCode == 200) {
      // ✅ response.data is already a decoded Map if using Dio and JSON
      // You should not do `jsonDecode(response.data.messages)`
      // Instead access `response.data['messages']` directly
      List<dynamic> rawMessages = response.data['messages'];

      // Convert each map to a ChatMessage object
       for(dynamic i in rawMessages){
        ChatMessage msg=ChatMessage.fromJson(i);
        ref.watch(chatProvider.notifier).addMessage(msg.chatId!, msg,true);

       }
         
          
    }
  } catch (e) {
    print('Error fetching messages: $e');
    
  }
}
Future<void>fetchUserProfile()async{
  try{


  }
  catch(e){
    print(e);
  }
}
Future<Map<String,UserProfileData>> fetchActiveContacts(List<String> contacts) async {
  try {
    Map<String,UserProfileData> result ={};
    Map<String, List<String>> payload = {
      'contacts': contacts,
    };

    Response response = await _dio!.post('/fetch/contacts', data: jsonEncode(payload));

    if (response.statusCode == 200) {
      print('------------------');
      print('TYPE: ${response.data.runtimeType}');
      print('RAW: ${response.data}');

      dynamic decoded;

      if (response.data is String) {
        decoded = jsonDecode(response.data);
      } else {
        decoded = response.data;
      }
     if(decoded['active_contacts'] is List){
      for( final item in decoded['active_contacts']){
         final String? contact = item['contact'];
          final payload = item['payload'];

          if (contact != null && payload != null) {
            final userProfile = UserProfileData.fromJson(payload);
            result[contact] = userProfile;
          }
        

      }

     }
      
  return result;
     
    }
  } catch (e) {
    debugPrint('fetchActiveContacts error: $e');
  }
  return {};
}

  
    
}


