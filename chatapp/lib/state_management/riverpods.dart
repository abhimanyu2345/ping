import 'dart:convert';

import 'package:chatapp/data/models/chat_controller_class.dart';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/data/models/signaling_notifier.dart';
import 'package:chatapp/data/models/user_data.dart';
import 'package:chatapp/services/http_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final chatProvider = NotifierProvider<ChatController, Map<String, List<ChatMessage>>>(
  () => ChatController(),
);


final userIdProvider = StateNotifierProvider<UserIdController,String?>((ref) {
  return UserIdController("",ref);
},);

class UserIdController extends StateNotifier<String?>{
  final Ref ref;
  UserIdController(super._state,  this.ref){
    setId();
  }

  void signout()async{
    await Supabase.instance.client.auth.signOut();
    state=null;
    ref.invalidate(userProfileProvider);
    
  }
  void setId(){
     final client= Supabase.instance.client.auth.currentUser;
   state =(client!=null)?client.id :null;
  
  }
}


final userProfileProvider = FutureProvider<UserProfileData?>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return null;

  

  final response = await Supabase.instance.client
      .from('user_profiles')
      .select()
      .eq('id', userId)
      .single();

  final profile = UserProfileData(
    id: response['id'],
    username: response['username'],
    tagName: response['tag_name'],
    bio: response['bio'],
    phoneNumber: response['phone_number'],
    statusMessage: response['status_message'],
    isOnline: response['is_online'],
    created: DateTime.parse(response['created']),
    lastSeen: response['last_seen'] != null
        ? DateTime.tryParse(response['last_seen'])
        : null,
    email: response['email'],
    imageBytes: response['image_bytes'] != null
        ? base64Decode(response['image_bytes'])
        : null,
    contacts: List<String>.from(response['contacts'] ?? []),
    blockedUsers: List<String>.from(response['blocked_users'] ?? []),
  );
  return profile;
}



);



final HttpServiceProvider = Provider<HttpServices>((ref) {
  return HttpServices(ref);
},);
  
final signalingProvider = NotifierProvider<SignalingNotifier,void>(
  () {
    return SignalingNotifier();
  },

 
);

