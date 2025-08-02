import * as uWS from "uWebSockets.js";
import { CallStatus, ChatMessage, SignalMessage, userString } from "./constants.js";
import {  SupabaseService } from "./database.js";


export default class ConnectionManager {
  private clients = new Map<string, uWS.WebSocket<userString>>();
  private  supabase_service:SupabaseService= new SupabaseService();

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
        this.supabase_service.updateDatabase(payload,'chat');
     
       
      
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
    this.supabase_service.updateDatabase(payload, 'seen');
    }
    catch(e){
      console.error(e);
    }



    

  
}
private handleCall(payload:any, from:String){
  
  console.log(`handling  paylod `,payload);
  

  const recipientWS: uWS.WebSocket<userString>|undefined =this.clients.get(payload.to);
  if(recipientWS ==undefined ){
    if(payload.type =='offer'){
      console.log('call handling');
    this.supabase_service.registerCall({...payload,
      from:from,
      call_type:'video'
    },CallStatus.MISSED);
    }
    

  }

  

   
  else{

    recipientWS.send(JSON.stringify({
      'type':'call',
      'payload': {
      ...payload,
      'from':from,
        

      }

    }));
    if(!['candidate','offer'].includes(payload.type)){
       if(['missed','ended','cancelled','rejected'].includes(payload.type)){
        this.supabase_service.updateCall(payload.id, payload.type);
       }
       else if( payload.type =='offer'){

      this.supabase_service.registerCall({...payload, from:from,
        
      });}
     }
    
    
  }
  
  

}
 

}
