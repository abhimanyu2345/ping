import * as uWS from "uWebSockets.js";
import { SignalMessage, userString } from "./constants.js";
export default class ConnectionManager {
    private clients;
    private supabase_service;
    addUser(userId: string, user: uWS.WebSocket<userString>): void;
    removeUser(userId: String): void;
    HandleMessage(userId: string, msg: SignalMessage): void;
    private handleChat;
    private handleSeen;
    private handleCall;
}
//# sourceMappingURL=ConnectionManager.d.ts.map