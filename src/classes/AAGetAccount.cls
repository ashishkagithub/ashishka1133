/*
{"ACCOUNT":{"accountId":"1212121",
"CONTACT":[{
"lastname":"Ashish"
},{
"lastname":"agrawal"
}]
}}
}


{"lastname":"Ashish","accountId":"1212121"}
*/

@restresource (urlmapping = '/sendAccount1/*')

global without sharing class AAGetAccount{
    
    @httppost
    global static void accountInfo(){
        
        restrequest req = restcontext.request;
        restresponse res = restcontext.response;
        
        String reqMsg = req.requestbody.tostring();
        accountMain jsonToObject = (accountMain) system.json.deserialize(reqMsg,accountMain.class);
        
        SYSTEM.DEBUG('=='+jsonToObject);

        // Read input

        respObj resInst = new respObj();
        resInst.accountId = jsonToObject.ACCOUNT.accountId;
        resInst.lastname = jsonToObject.ACCOUNT.CONTACT[0].lastname;
        
        String resStr = JSON.serialize(resInst);
        res.responseBody = blob.valueof(resStr);
        SYSTEM.DEBUG('=='+resStr);
        
        // 2nd pattern to create a response by pasing the input value
        // Need to create seprate wrapper if you want to avoid addional attribute added in JSON response
        
        respObj2 resInst2 = new respObj2();
        resInst2.ACTID = jsonToObject.ACCOUNT.accountId;
        list<resObj3> lstCon = new list<resObj3>();
        for (contactwrap c : jsonToObject.ACCOUNT.CONTACT){
            resObj3 c1 = new resObj3();
            c1.lastname = c.lastname;
            c1.firstname = 'Ashish'; 
            lstCon.add(c1);
        }
         resInst2.cont = lstCon;
         resStr = JSON.serialize(resInst2);
         res.responsebody = blob.valueof(resStr);
         
        }

    public class accountMain{
        public accountWrap ACCOUNT;
    }

    public class accountWrap{
        String accountId;
        list<contactwrap> CONTACT;
    }
    
    public class contactwrap{
        string lastname;
    }
    
    public class respObj{
        public string accountId;
        public string lastname;
    }

    public class respObj2{
        public string ACTID;
        public list<resObj3> cont;
    }
    
    public class resObj3{
        public string lastname;
        public string firstname;
    }


}