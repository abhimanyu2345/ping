import { createClient } from '@supabase/supabase-js'
import 'dotenv/config'
import {  msg_type, UserProfileData } from './constants'


const SUPABASE_URL = process.env.SUPABASE_URL!
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!

export const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

export async function createUser(data: UserProfileData):Promise<boolean> {
   const mappedData = {
    ...data,
    blocked_users: data.blockedUsers,
    image_bytes: data.imageBytes,
    tag_name: data.tagName,
    phone_number: data.phoneNumber,
    last_seen: data.lastSeen,
    status_message: data.statusMessage,
    is_online: data.isOnline,
  };

  // Optionally remove camelCase keys to avoid leaking them
  delete mappedData.blockedUsers;
  delete mappedData.imageBytes;
  delete mappedData.tagName;
  delete mappedData.phoneNumber;
  delete mappedData.lastSeen;
  delete mappedData.statusMessage;
  delete mappedData.isOnline;

  const { error } = await supabase
    .from('user_profiles')
    .insert([mappedData]);

  if (error) {
    console.error('Insert error:', error.message);
    return false;
  }

  return true;
}
export async function fetchMessages(userId: string): Promise<any[] | null> {
  // 1. Get chat IDs the user is part of
  const { data: participantChats, error: chatErr } = await supabase
    .from('chat_participants')
    .select('chat_id')
    .eq('user_id', userId);

  if (chatErr) {
    console.error('Error fetching chat list:', chatErr.message);
    return null;
  }

  const chatIds = participantChats.map(chat => chat.chat_id);

  if (chatIds.length === 0) return [];

  // 2. Fetch messages from those chats
  const { data: messages, error: msgErr } = await supabase
    .from('messages')
    .select('*')
    .in('chat_id', chatIds)
    .order('time_sent', { ascending: false }); // Or ascending if needed

  if (msgErr) {
    console.error('Error fetching messages:', msgErr.message);
    return null;
  }

  return messages;
}


export async function updateDatabase(payload: any, type:msg_type) {
  if(type=='chat'){
  try {
    // 1️⃣ Does the chat exist?
    const { data: chatExists, error: chatErr } = await supabase
      .from("chats")
      .select("chat_id")
      .eq("chat_id", payload.chatId)
      .maybeSingle();

    if (chatErr) {
      console.error("Error checking chat:", chatErr.message);
      return;
    }

    let chatId = payload.chatId;

    // 2️⃣ If it doesn't exist, create it
    if (!chatExists) {
      const { data: newChat, error: createErr } = await supabase
        .from("chats")
        .insert({
          chat_id: chatId,
          is_group: false, // or true if it’s a group
        })
        .select()
        .single();

      if (createErr) {
        console.error("Error creating new chat:", createErr.message);
        return;
      }

      // Optionally, insert both participants too:
      const { error: participantsErr } = await supabase
        .from("chat_participants")
        .insert([
          { chat_id: chatId, user_id: payload.from },
          { chat_id: chatId, user_id: payload.to },
        ]);

      if (participantsErr) {
        console.error("Error adding participants:", participantsErr.message);
        return;
      }
    }

    // 3️⃣ Insert the message
    const { error: msgErr } = await supabase.from("messages").insert({
      id: crypto.randomUUID(), // <- your PK must be unique!
      chat_id: chatId,
      from_id: payload.from,
      to_id: payload.to,
      message: payload.message,
      type: payload.type,
      time_sent: payload.time,
    });

    if (msgErr) {
      console.error("Error inserting message:", msgErr.message);
    }

  } catch (e) {
    console.error("Unexpected error in updateDatabase:", e);
  }

}

else if (type == 'seen') {
  try {
    const { data, error } = await supabase
      .from("messages")
      .update({ marked: true })
      .eq('chat_id', payload.chatId)
      .eq('time_sent', payload.time);

    if (error) {
      console.error("Error marking message as seen:", error.message);
    } else {
      console.log("Seen update OK:", data);
    }
  } catch (e) {
    console.error(e);
  }
}


}

export async function fetchActiveUsers(Contacts:String[]):Promise<{contact:String , payload:UserProfileData}[]>{
  
  
  try{
   
    

      const {data,error} = await supabase.from('user_profiles').select('*').in('phone_number',Contacts);
      if(error!=null){
        console.error(error);
        return [];
      }
      else{
        return data.map((e)=>({contact: e.phone_number, 
          payload: e,
       } ));
        
      }
      
    
    

  }
  catch(e){
    console.error(e);
     return [];
  }


}
