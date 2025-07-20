import * as uWS from "uWebSockets.js";
import { ChatMessage, SignalMessage, userString } from "./constants";
import { updateDatabase } from "./database.js";


export default class ConnectionManager {
  private clients = new Map<string, uWS.WebSocket<userString>>();

  addUser(userId: string, user: uWS.WebSocket<userString>) {
    this.clients.set(userId, user);
    user.getUserData().userId = userId;

    try {
      const successMsg = JSON.stringify({
        type: "register",
        status: "success",
        userId: userId,
      });
      user.send(successMsg);
    } catch (error) {
      console.error("Error sending registration success message:", error);
    }
  }

  removeUser(userId: String) {
    this.clients.delete(userId.toString());
  }

  HandleMessage(userId: string, msg: SignalMessage) {
    console.log(`Handling message from ${userId}:`, msg);

    if ( !msg.payload.to ) {
      console.error("Invalid message payload");
      return;
    }

    try {
      

      

      switch (msg.type) {
        case "chat":
            if ( !msg.payload.from || !msg.payload.type) {
      console.error("Invalid message payload");
      return;
    }
          this.handleChat(msg.payload);
          break;
        case "seen":
          this.handleSeen(msg.payload);
          break;

        case "call":
          this.handleCall(msg.payload, userId);
        
          break;

        default:
          console.error(`Unknown message type: ${msg.type}`);
      }
    } catch (error: any) {
      console.error("Error handling message:", error);
    }
  }

  private async handleChat(payload: ChatMessage) {
    try {
      const recipientWS = this.clients.get(payload.to);
     
      if (!recipientWS) {
        console.warn(`Recipient ${payload.to} not connected`);
    
      }
      else{
        recipientWS.send(JSON.stringify({
          'type':'message',
          'payload': payload
        }));
      }
        updateDatabase(payload,'chat');
     
       
      
    } catch (e) {
      console.error("Error in handleChat:", e);
    }
  }
  private async  handleSeen(payload:{chatId:String,time:String, to:String}){
    try {
      const recipientWS = this.clients.get(payload.to.toString());
     
      
     
      if (recipientWS) {
        
        
        recipientWS.send(JSON.stringify({
          'type':'seen',
          'payload': payload
        }));
      }
    updateDatabase(payload, 'seen');
    }
    catch(e){
      console.error(e);
    }



    

  
}
private handleCall(payload:any, from:String){
  console.log(`handling  paylod `,payload);
  const recipientWS: uWS.WebSocket<userString>|undefined =this.clients.get(payload.to);
   const {to, newJson} = payload;
  if(recipientWS !=undefined){
    recipientWS.send(JSON.stringify({
      'type':'call',
      'payload': {
      ...newJson,
      'from':from,
        

      }
    }));
    
  }
  console.log({
      'type':'call',
      'payload': {
      ...newJson,
      'from':from,
        

      }
    });
  

}
 

}
