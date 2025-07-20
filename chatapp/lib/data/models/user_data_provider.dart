

import 'package:chatapp/data/models/user_data.dart';
import 'package:chatapp/services/supabase_service.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';


final userDataProvider = NotifierProvider<UserDataController,Map<String,UserProfileData>>(() {
  return UserDataController();
},);
class UserDataController extends Notifier<Map<String,UserProfileData>>{
  Set<String> userContactMap={};
  


  @override
  Map<String,UserProfileData> build(){
    
    return {};
    
  
    
    
  }
  Future<void> fetchUserProfileData(String userId )async{
    UserProfileData? userdata  =await ref.read(supabaseServiceProvider).fetchChateeData(id: userId);
    if(userdata!=null){
     Map<String, UserProfileData>  newState = state;
     
     newState[userId] =userdata;
     if(userdata.phoneNumber!=null){
     userContactMap.add(userdata.phoneNumber.toString());
     }
     state =newState;
    }
    
  }
  
}