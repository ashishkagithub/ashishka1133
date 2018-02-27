global without sharing class sharingAttachment{


    global static void sendAttfile(){
    
        list<attachment> lstAtt = [select id,body from attachment where id='00P7F000002f7Ic'];
        
        Attwrap att = new Attwrap();
        att.sBody = EncodingUtil.base64Encode(lstAtt[0].body);
        //String base64PDF = EncodingUtil.base64Encode(pdfBody);
        
        String jsonStr = JSON.serialize(att);
        system.debug('--jsonstr--'+jsonStr);
        
        Http h = new http();
        HttpRequest req = new httprequest();
        httpresponse res = new httpresponse();
        
        req.setendpoint('https://putsreq.com/dOKBjEGmGVhL3BeZHQmK');
        //req.setEndpoint('callout:AA_REST_TEST');
        req.setmethod('GET');
        req.setbody(jsonStr);

        
        res = h.send(req);
        
        SYSTEM.DEBUG('--res--'+res);
    
    } 

    public class Attwrap{
        public string sBody;
    
    }


}