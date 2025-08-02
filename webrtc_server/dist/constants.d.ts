export interface userString {
    userId: String;
}
export type msg_type = "call" | "chat" | "typing" | "seen";
export type SignalMessage = {
    type: "call" | "chat" | "typing" | "seen";
    call_type?: 'offer' | 'answer' | 'candidate';
    from: string;
    to: string;
    payload: any;
};
export interface UserData {
    id: string;
    tagName: string;
    username: string;
    imageBytes?: string;
}
export interface UserProfileData extends UserData {
    created: string;
    bio?: string;
    email?: string;
    phoneNumber?: string;
    lastSeen?: string;
    statusMessage?: string;
    isOnline: boolean;
    contacts?: UserData[];
    blockedUsers?: UserData[];
}
export type MessageType = 'text' | 'image' | 'file' | 'video' | 'audio';
export interface ChatMessage {
    chatId: String;
    from: string;
    to: string;
    message: string;
    time: string;
    type: MessageType;
}
export declare function createChatMessage(data: ChatMessage): ChatMessage;
export type Contacts = {
    contact_id: String;
    phones: String[];
};
export declare enum CallStatus {
    MISSED = "missed",
    REJECTED = "rejected",
    ENDED = "ended",
    CANCELLED = "cancelled"
}
//# sourceMappingURL=constants.d.ts.map