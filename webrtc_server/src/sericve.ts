import jwt from "jsonwebtoken";
import { HttpResponse} from "uWebSockets.js";




export const decode=(res:HttpResponse): Promise<any> =>{
    return new Promise((resolve,reject)=>{
         var data ="";
    res.onData((chunk,isLast)=>{
         data+=Buffer.from(chunk).toString();
        
       
        if(isLast){
            try{
            resolve( JSON.parse(data));
        }
        catch(e){
            reject(e);
        }
    
    }

    
    })
    res.onAborted(()=>{
        reject(new Error("Request was aborted before complete data was received."));
    })

   
        
    }
  

)
  
    

}

export const authenticate=(token:string):String|null=>{
try{

    const secret_key:jwt.Secret='z3fFP2Wdq1To9+G5TvaGVRe0eN/dXms74uClhfuwyX5fi3vFcz3Q9R+eTHZe6GDI+jCJ/nvHuQhK45ZvQCoY8g==';
        const decoded  = jwt.verify(token,secret_key);
        return decoded?.user_metadata?.sub;

}
    catch(e){
        console.error(e);
        return null;
        
    }
}
