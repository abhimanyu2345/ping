import { createClient, SupabaseClient } from '@supabase/supabase-js';
import 'dotenv/config';
import { CallStatus, msg_type, UserProfileData } from './constants.js';





export class SupabaseService {
  private static SUPABASE_URL = process.env.SUPABASE_URL!;
  private static SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!;
  private static supabase: SupabaseClient = createClient(
    SupabaseService.SUPABASE_URL,
    SupabaseService.SUPABASE_SERVICE_ROLE_KEY
  );

  static async createUser(data: UserProfileData): Promise<boolean> {
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

    delete mappedData.blockedUsers;
    delete mappedData.imageBytes;
    delete mappedData.tagName;
    delete mappedData.phoneNumber;
    delete mappedData.lastSeen;
    delete mappedData.statusMessage;
    delete mappedData.isOnline;

    const { error } = await this.supabase.from('user_profiles').insert([mappedData]);
    if (error) {
      console.error('Insert error:', error.message);
      return false;
    }

    return true;
  }

  static async fetchMessages(userId: string): Promise<any[] | null> {
    const { data: participantChats, error: chatErr } = await SupabaseService.supabase
      .from('chat_participants')
      .select('chat_id')
      .eq('user_id', userId);

    if (chatErr) {
      console.error('Error fetching chat list:', chatErr.message);
      return null;
    }

    const chatIds = participantChats.map((chat) => chat.chat_id);
    if (chatIds.length === 0) return [];

    const { data: messages, error: msgErr } = await SupabaseService.supabase
      .from('messages')
      .select('*')
      .in('chat_id', chatIds)
      .order('time_sent', { ascending: false });

    if (msgErr) {
      console.error('Error fetching messages:', msgErr.message);
      return null;
    }

    return messages;
  }

  async updateDatabase(payload: any, type: msg_type): Promise<void> {
    if (type === 'chat') {
      await this.insertChatMessage(payload);
    } else if (type === 'seen') {
      await this.markMessageAsSeen(payload );
    }
  }

  private async insertChatMessage(payload: any): Promise<void> {
    try {
      const { data: chatExists, error: chatErr } = await SupabaseService.supabase
        .from('chats')
        .select('chat_id')
        .eq('chat_id', payload.chatId)
        .maybeSingle();

      if (chatErr) {
        console.error('Error checking chat:', chatErr.message);
        return;
      }

      if (!chatExists) {
        const { data: newChat, error: createErr } = await SupabaseService.supabase
          .from('chats')
          .insert({ chat_id: payload.chatId, is_group: false })
          .select()
          .single();

        if (createErr) {
          console.error('Error creating chat:', createErr.message);
          return;
        }

        const { error: participantsErr } = await SupabaseService.supabase
          .from('chat_participants')
          .insert([
            { chat_id: payload.chatId, user_id: payload.from },
            { chat_id: payload.chatId, user_id: payload.to },
          ]);

        if (participantsErr) {
          console.error('Error inserting participants:', participantsErr.message);
          return;
        }
      }

      const { error: msgErr } = await SupabaseService.supabase.from('messages').insert({
        id: crypto.randomUUID(),
        chat_id: payload.chatId,
        from_id: payload.from,
        to_id: payload.to,
        message: payload.message,
        type: payload.type,
        time_sent: payload.time,
      });

      if (msgErr) {
        console.error('Error inserting message:', msgErr.message);
      }
    } catch (e) {
      console.error('Unexpected error inserting chat message:', e);
    }
  }

  private async markMessageAsSeen(payload: any): Promise<void> {
    try {
      const { data, error } = await SupabaseService.supabase
        .from('messages')
        .update({ marked: true })
        .eq('chat_id', payload.chatId)
        .eq('time_sent', payload.time);

      if (error) {
        console.error('Error marking as seen:', error.message);
      } else {
        console.log('Marked as seen:', data);
      }
    } catch (e) {
      console.error('Unexpected error in markMessageAsSeen:', e);
    }
  }

  static async fetchActiveUsers(contacts: string[]): Promise<{ contact: string; payload: UserProfileData }[]> {
    try {
      const { data, error } = await SupabaseService.supabase
        .from('user_profiles')
        .select('*')
        .in('phone_number', contacts);

      if (error) {
        console.error('Error fetching active users:', error.message);
        return [];
      }

      return data.map((e) => ({
        contact: e.phone_number,
        payload: e as UserProfileData,
      }));
    } catch (e) {
      console.error('Unexpected error fetching active users:', e);
      return [];
    }
  }

  async registerCall(payload: any, status?: CallStatus): Promise<void> {
    try {
      const { data, error } = await SupabaseService.supabase.from('calls').insert({
        id: payload.id,
        caller_id: payload.from,
        receiver_id: payload.to,
        call_type: payload.call_type,
        status: status,
      });

      if (error) {
        console.error('Error registering call:', error.message);
        return;
      }

      console.log('Call registered:', data);
    } catch (e) {
      console.error('Unexpected error in registerCall:', e);
    }
  }

 async updateCall(callId: string, status: CallStatus): Promise<void> {
    try {
      const now = new Date().toISOString();
      const { error } = await SupabaseService.supabase
        .from('calls')
        .update({
          ended_at: now,
          status: status,
        })
        .eq('id', callId);

      if (error) {
        console.error('Error updating call:', error.message);
      }
    } catch (e) {
      console.error('Unexpected error in updateCall:', e);
    }
  }
 static async fetchCallHistory(userId:String):Promise<{data:any|null,error:String|null}>{
   const {error,data} =await SupabaseService.supabase.from('calls').select('*').
   or(`caller_id.eq.${userId},receiver_id.eq.${userId}`);
   if(error!=null){
    return {data:null,error:error.message};
   }
   else{
    return {error:null,data:data};

   }
  }
}
