import 'dotenv/config';
import { msg_type, UserProfileData } from './constants';
export declare const supabase: import("@supabase/supabase-js").SupabaseClient<any, "public", any>;
export declare function createUser(data: UserProfileData): Promise<boolean>;
export declare function fetchMessages(userId: string): Promise<any[] | null>;
export declare function updateDatabase(payload: any, type: msg_type): Promise<void>;
export declare function fetchActiveUsers(Contacts: String[]): Promise<{
    contact: String;
    payload: UserProfileData;
}[]>;
//# sourceMappingURL=database.d.ts.map