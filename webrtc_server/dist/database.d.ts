import 'dotenv/config';
import { CallStatus, msg_type, UserProfileData } from './constants.js';
export declare class SupabaseService {
    private static SUPABASE_URL;
    private static SUPABASE_SERVICE_ROLE_KEY;
    private static supabase;
    static createUser(data: UserProfileData): Promise<boolean>;
    static fetchMessages(userId: string): Promise<any[] | null>;
    updateDatabase(payload: any, type: msg_type): Promise<void>;
    private insertChatMessage;
    private markMessageAsSeen;
    static fetchActiveUsers(contacts: string[]): Promise<{
        contact: string;
        payload: UserProfileData;
    }[]>;
    registerCall(payload: any, status?: CallStatus): Promise<void>;
    updateCall(callId: string, status: CallStatus): Promise<void>;
    static fetchCallHistory(userId: String): Promise<{
        data: any | null;
        error: String | null;
    }>;
}
//# sourceMappingURL=database.d.ts.map