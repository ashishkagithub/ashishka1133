@restresource(urlmapping='/GetFile/*')

global without sharing class FileShare{

    @httppost
    global static void sendFile(){
    
    restrequest req = restcontext.request;
    restresponse res = restcontext.response;
    
    /*
    string strInput = req.requestbody.tostring();
    reqObj1 reqInst1 = (reqObj1) JSON.deserialize(strInput,reqObj1.class);
    
    attachment sBody = [select body from attachment where id=:reqInst1.attId][0];
    resObj1 resInst1 = new resObj1();
    resInst1.sBody = sBody.body;
    
    String finalRes = JSON.serialize(resInst1);
    res.responsebody = blob.valueof(finalRes);    
    */
    
    string strInput = req.requestbody.tostring();
    resObj2 resInst2 = (resObj2) JSON.deserialize(strInput,resObj2.class);    
    attachment attInst = new Attachment(parentId = '0017F00000Twrgz', name = 'Ashish1',ContentType = 'application/msword',Body = EncodingUtil.base64Decode(resInst2.sBody));
    insert attInst;
    
    }
    
    public class reqObj1{
        public string attId;        
    }
    
    public class resObj1{
        public BLOB sBody;    
    }
    
    public class resObj2{
        public string sBody;    
    }

}