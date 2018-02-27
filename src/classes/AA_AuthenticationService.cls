/**
Replace all labels mentioned in url encode with actual values

**/

global without sharing class AA_AuthenticationService{

    global static void getSessionDP(){
        
        http h = new Http();
        httprequest req = new httprequest();
        httpresponse res = new httpresponse();
        DPResWrapper DPresWrapInst  = new DPResWrapper(); 
        String clientId     = EncodingUtil.urlEncode('Label.E2E_DP_ClientId', 'UTF-8');
        String clientSecret = EncodingUtil.urlEncode('Label.E2E_DP_ClientSecret','UTF-8');
        String username     = EncodingUtil.urlEncode('Label.E2E_DP_UserName','UTF-8');
        String password     = EncodingUtil.urlEncode('Label.E2E_DP_Password','UTF-8');
        String scope = EncodingUtil.urlEncode('Label.E2E_DP_Scope','UTF-8');
        String bodyToken =   'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=' + username + '&password=' + password + '&scope=' + scope; 
        req.setendpoint('Label.E2E_DP_Endpoint');

        req.setbody(bodyToken);
        req.setmethod('POST');
        res = h.send(req);    
        string resBody = res.getbody();
        DPresWrapInst  =  (DPResWrapper) System.JSON.deserialize(resBody, DPResWrapper.class);
        
        SYSTEM.DEBUG('--token_type--'+DPresWrapInst.token_type); 
        SYSTEM.DEBUG('--access_token--'+DPresWrapInst.access_token);         
    }
    
    public class DPReqWrapper{    
        String grant_type;
        String username;
        String password;
        String scope;
        String clientid;
        String client_secret;    
    }

    public class DPResWrapper{    
        String token_type;
        String access_token;
    }
}