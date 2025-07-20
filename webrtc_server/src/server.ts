import uWS from 'uWebSockets.js';
import ConnectionManager from './ConnectionManager.js';
import { userString } from './constants.js';
import { authenticate, decode, } from './sericve.js';
import { createUser, fetchActiveUsers, fetchMessages } from './database.js';
const Manager = new ConnectionManager();

uWS.App()
  .ws<userString>('/*', {
    open: (ws) => {
      console.log('Client connected');
      

      ws.getUserData().userId = 'unknown';
      ws.send('Hello from uWebSockets.js!');
    },
    message: (ws, message, isBinary) => {
      const msgString = Buffer.from(message).toString();
      console.log('Received:', msgString);

      let msgObj;
      try {
        msgObj = JSON.parse(msgString);
        console.log(msgObj);
        
      } catch (e) {
        console.error('Invalid JSON:', msgString);
        ws.send('Invalid JSON');
        return;
      }

      if (msgObj.type === 'register' && msgObj.userId) {
        console.log('user registration');
        ws.getUserData().userId = msgObj.userId;
        Manager.addUser(msgObj.userId, ws);
      } 
      else if( ["call","chat","typing","seen"].includes(msgObj.type)){
        
        Manager.HandleMessage(ws.getUserData().userId.toString(),msgObj);
        

      }
    },
    close: (ws, code, message) => {
      const userId = ws.getUserData().userId;
      console.log(`Client disconnected ${userId}`);
      Manager.removeUser(userId);
    },
  })
   .options('/*', (res, req) => {
    res.writeHeader('Access-Control-Allow-Origin', '*')
       .writeHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
       .writeHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
       .end();
  })
  .post('/register', async(res, req) => {
    res.writeHeader('Access-Control-Allow-Origin', '*');
    const refreshToken =req.getHeader('authorization').split(' ')[1];
    var data;
    try{
    
    
    if(refreshToken){
     const sub = authenticate(refreshToken);
     if(sub!=null){

      data = await decode(res);
      const result = await createUser(data);
      res.cork(()=>{
        res.writeHeader('Access-Control-Allow-Origin', '*');
        res.writeStatus(result?'200':'400').end();

      })
      

     }
    }

  }
  catch(e){
    console.error(e);
  }
  

    
    
  })

  .get('/',(res,req)=>{
    res.onAborted(()=>{
        console.error('aborted');


    });
    res.writeStatus('200').end('Server is running')
 })
 .post('/messages/:id', async (res: uWS.HttpResponse, req: uWS.HttpRequest) => {
  const id: string = req.getParameter(0); // ':id' is at index 0
  let aborted = false;

  // 🔐 Handle aborted connections safely
  res.onAborted(() => {
    aborted = true;
    console.warn('Request aborted by client');
  });

  try {
    const messages = await fetchMessages(id);

    if (aborted) return;

    res.cork(() => {
      res.writeHeader('Content-Type', 'application/json');
      res.writeStatus('200 OK').end(JSON.stringify({ messages }));
    });
  } catch (e) {
    console.error('Error fetching messages:', e);
    if (!aborted) {
      res.cork(() => {
        res.writeStatus('500 Internal Server Error')
           .end(JSON.stringify({ error: 'Failed to fetch messages' }));
      });
    }
  }
})
.post('/fetch/contacts', async (res,req)=>{
   console.log('here');
  res.onAborted(()=>{
    console.warn('aborted');
  })
  try{

    const data = await decode(res);
    
    if(data!=null){
      const result = await fetchActiveUsers(data.contacts);
      console.log(result);
      res.cork(()=>{
      res.writeStatus('200').end(JSON.stringify(
        {
          active_contacts:
        
        result})
    );


    });
  }
}
  catch(e){
    console.error(e);
    res.writeStatus('400').end(String(e));

  }
})




  .listen('0.0.0.0',3000, (token) => {
    if (token) {
      console.log('Listening on port 3000');
    } else {
      console.log('Failed to listen');
    }
  });
