export interface userString{
    userId:String;
};
export type msg_type= "call"|"chat"|"typing"|"seen";
export type SignalMessage = {
  type: "call"|"chat"|"typing"|"seen";
  call_type?: 'offer' | 'answer' | 'candidate';
  from: string;  // sender userId
  to: string;    // receiver userId
  payload: any;  // SDP or ICE candidate info
};

export interface UserData {
  id:string;
  tagName: string;
  username: string;
  imageBytes?: string; // base64 string
}

export interface UserProfileData extends UserData {
  created: string; // ISO date string, or use Date if you parse it
  bio?: string;
  email?: string;
  phoneNumber?: string;
  lastSeen?: string; // ISO date string
  statusMessage?: string;
  isOnline: boolean;
  contacts?: UserData[];
  blockedUsers?: UserData[];
}
// chatMessage.ts

export type MessageType = 'text' | 'image' | 'file' | 'video' | 'audio';

export interface ChatMessage {
  chatId: String;
  from: string;
  to: string;
  message: string;       // text or URL for media
  time: string;          // ISO timestamp
  type: MessageType;
}

export function createChatMessage(data: ChatMessage): ChatMessage {
  return data;
}
 
export type Contacts={
  contact_id :String,
  phones:String[]
}