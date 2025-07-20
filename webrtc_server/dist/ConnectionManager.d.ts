import * as uWS from "uWebSockets.js";
import { SignalMessage, userString } from "./constants";
export default class ConnectionManager {
    private clients;
    addUser(userId: string, user: uWS.WebSocket<userString>): void;
    removeUser(userId: String): void;
    HandleMessage(userId: string, msg: SignalMessage): void;
    private handleChat;
    private handleSeen;
    private handleCall;
}
//# sourceMappingURL=ConnectionManager.d.ts.map