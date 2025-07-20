import 'dart:convert';
import 'package:chatapp/data/models/user_data.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseServiceProvider = Provider((ref) {
  return SupabaseService();
},);

class SupabaseService {
  
Future<String> emailSignUp(String email, String password) async {
  final supabase = Supabase.instance.client;

  try {
    final AuthResponse data = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final Session? session = data.session;

    if (session != null) {
      
      print("Signed up user: ${session.user.id}");
     
      return 'success';
    }
  } on AuthApiException catch (e) {
    return e.message;
  } catch (e) {
    return e.toString();
  }

  return 'undefined error';
}

/// Signin using email and password
Future<String> signIn(String email, String password) async {
  try {
    final supabase = Supabase.instance.client;

    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return 'success';
  } on AuthApiException catch (e) {
    return e.message;
  } catch (e) {
    return e.toString().replaceFirst('Exception:', '').trim();
  }
}




/// Save user profile to Supabase and local storage
Future<void> saveUserProfile(UserProfileData data ) async {
  try {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user == null) {
      print("No authenticated user found.");
      return;
    }

    final jsonMap = {
      'id': data.id,
      'username': data.username,
      'tag_name': data.tagName,
      'bio': data.bio,
      'phone_number': data.phoneNumber,
      'status_message': data.statusMessage,
      'is_online': data.isOnline,
      'created': data.created.toIso8601String(),
      'last_seen': data.lastSeen?.toIso8601String(),
      'email': data.email,
      'contacts': data.contacts,
      'blocked_users': data.blockedUsers,
    };

    if (data.imageBytes != null && data.imageBytes!.isNotEmpty) {
      jsonMap['image_bytes'] = base64Encode(data.imageBytes!);
    }
     print('${jsonMap['image_bytes']} end ');
    await client.from('user_profiles').upsert(jsonMap);

    final jsonString = jsonEncode(jsonMap);
    await prefs.setString('user_profile', jsonString);

    
    print("User profile saved to Supabase and locally.");
   
  } catch (e) {
    print("Failed to save user profile: $e");
  }
}



Future<UserProfileData?> fetchChateeData({
  required String id,
  bool isGroup = false,
}) async {
  try {
    final response = await Supabase.instance.client
        .from('user_profiles')
        .select()
        .eq('id', id)
        .single(); // Returns a single Map<String, dynamic>
        

    return UserProfileData.fromJson(response);
  } catch (e) {
    print('Error fetching chatee data: $e');
    return null;
  }
}
}