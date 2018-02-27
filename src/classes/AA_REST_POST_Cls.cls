/***
Workbench: /services/apexrest/sendAccount/sendAccountDetails

REQUEST: POST
{
  "person1": {
    "acctId": "0017F00000Twrgx"
  }
}

HOW TO USE CURL
curl -H "Content-Type: application/json" -X POST -d '{"username":"xyz","password":"xyz"}' http://localhost:3000/api/login
(-H is short for --header, -d for --data)

By using https://putsreq.com/
curl -i -X POST -d 'name=Pablo' https://putsreq.com/ogBHM04BFS6PVvNfUSax

curl -i -X POST -d '{"person1": {"acctId": "0017F00000Twrgx"}}' https://ap5.salesforce.com/services/apexrest/sendAccount/sendAccountDetails

curl -v https://login.salesforce.com/services/oauth2/token -d "grant_type=password" -d "client_id=3MVG9d8..z.hDcPJoZmsMooX20l4HomyxHZtsq9.YCbA0Sgix0ROq5By4E_Oilo4IBNsQezHw8TKS_D9VAHX7" -d "client_secret=1583395536280791610" -d "username=ashishka1133@gmail.com" -d "password=ashish$04U41pHMOfUfJk0as3MKzillLP" -H 'X-PrettyPrint:1'

curl -H "Content-Type: application/json" -H "Authorization: Bearer 00D7F000005Ah7t!AQQAQBSl58.IS6tfcRh5bdeRkh44PJbBAnNBCIKdFK0.mgOGuQDU9MGgOa1YrUZBSB5wwE5NYzbIrrIcNpUOG6CneXZQ4jNK" -H "X-PrettyPrint:1" -X POST -d '{"person1":{"acctId":"0017F00000Twrgx"}}' https://ap5.salesforce.com/services/apexrest/sendAccount/sendAccountDetails

***/

@RestResource(urlMapping='/sendAccount/*')

global without sharing class AA_REST_POST_Cls{
    
    @HttpPost
    global static string sendAccountDetails(){
        
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;

        String jsonBody = req.requestBody.toString();
        
        JSONParser parser = JSON.createParser(jsonBody);        
        parser.nextToken();
        parser.nextToken();
        parser.nextToken();

        system.debug('---'+parser);
        requestWrap wrapObj = (requestWrap) parser.readvalueas(requestWrap.class);
                system.debug('---'+wrapObj);
        ID accountId = wrapObj.acctId;
        
        list<Account> lstAct = [select name from account where id = :accountId];
        system.debug('--lstAct--'+lstAct);
        responseWrap objRes = new responseWrap();
        objRes.name = lstAct[0].name;        
        String finalRes = JSON.serialize(objRes);
        
        finalWrap x = new finalWrap();
        JSONParser parser1 = JSON.createParser(jsonBody);        
        parser1.nextToken();
        parser1.nextToken();
x = (finalWrap) system.JSON.deserialize(jsonBody,finalWrap.class);
        
        SYSTEM.DEBUG('==jsonBody==='+jsonBody);
         SYSTEM.DEBUG('===x=='+x);
        SYSTEM.DEBUG('===1x=='+x.obj.acctId);

                        
        return finalRes;
    }
    
    global class requestWrap{
        public String acctId;
    }

    global class responseWrap{
        public String name;
    }
    
    global class finalWrap{
        public string name;
        public requestWrap obj;
    }
    
}