/*
JSON Formatter: https://jsonformatter.curiousconcept.com/
JSON Object generator: http://www.objgen.com/json
REST request response testing: https://putsreq.com/ogBHM04BFS6PVvNfUSax/inspect

GET: In salesforce context, if we are intitaiting the request, it means we are expecting some response to get from ext system
POST: if external system is calling our service it means in salesforce we have to perform some operation

*/
global with sharing class AA_REST_GET_Cls{

    global static void sendAccountIdANDparseResponse(){
 /*************************************************************************************/               
        //1rd approach
        list<Account> lstAct = [select id,Name from Account where id ='0017F00000Twrgx'];
        system.debug('--lstAct--'+lstAct);
        //convert from list to JSON structure by seralize the list
        // This will generate a request with addional attribute added by salesforce
        String jsonStr = JSON.serialize(lstAct);
        // Prepare Http callouts
 /*************************************************************************************/               
        //2rd approach        
        // direct serialization send data with addional info like URL
        //If you want to modify the request, create wrapper class and iterate the data which you received from list and 
        //assign the the same in wrapper class variable then serialize the wrapper class and send
        
        
        requestWrapper reqWrp = new requestWrapper();
        for (account lst : lstAct){
            reqWrp.id = lst.id;
            reqWrp.name = lst.name;                
        }
        
        jsonStr = JSON.serialize(reqWrp);
        
        //3rd approach
        list<Account> lstActCont = [select id,Name,(select lastname from contacts) from Account where id ='0017F00000Twrgx'];
        system.debug('--lstActCont--'+lstActCont);
        jsonStr = JSON.serialize(lstActCont);
        //Above generate default JSON with addional attribute; sample request is pasted in 3rd approach at last
 /*************************************************************************************/               
        requestHierWrapper reqhiewrap = new requesthierwrapper();
    
        list<reqContactwrapper> lstConWrap = new list<reqContactwrapper>();
        for(Account each: lstActCont){
            reqhiewrap.accountId = each.id;
            reqhiewrap.name = each.name;
            //reqhiewrap.lstCont = each.contacts;
            //By doing direct assinment, addional attribut of contact is coming in JSON
            for(contact c : each.Contacts){
                reqContactwrapper conOb1 = new reqContactwrapper();
                conOb1.lname=c.lastname;
                lstConWrap.add(conOb1); 
            }
            reqhiewrap.lstCont = lstConWrap;        
        }
        
        jsonStr = JSON.serialize(reqhiewrap);
 /*************************************************************************************/   
 // How to add unrelated object in JSON
 
 list<opportunity> lstOpty = [select id,name from opportunity where id='0067F000009P94K'];
 reqOptywrapper optObj = new reqOptywrapper();
 optObj.Optyid= lstOpty[0].id;
 optObj.name= lstOpty[0].name; 
 reqhiewrap.optywrap = optObj;
  jsonStr = JSON.serialize(reqhiewrap);
  /*************************************************************************************/           
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setendpoint('https://putsreq.com/ogBHM04BFS6PVvNfUSax');
        request.setEndpoint('callout:AA_REST_TEST');
        request.setmethod('GET');
        request.setbody(jsonStr);
        
        HttpResponse response = http.send(request);
        //If response is success then [Status=OK, StatusCode=200]               
        system.debug('==response=='+response);
        system.debug('==response Status=='+response.getStatus());
        system.debug('==response code=='+response.getStatusCode());
                        
        // To check the response body response.getBody() 
        system.debug('==response=='+response.getbody());    
        //09:19:59:767 USER_DEBUG [25]|DEBUG|==response=={ "retry":"1","ErrCode":"01","accountId":"112"}
        
        //if there is simple JSON with no hierarchy, you can directly assign JSON into class with below
        // No need to do parser.nexttoken()
        //ResponseWrapper resObj = (ResponseWrapper)vParse.readValueAs(ResponseWrapper.class);
        
        //1. create a wrapper class with the exact same field name and with same hierarchy which is coming from response and use below
        // by passing the wrapper class which will map the response field with wrapper class field
        //doing this it will be easy to navigate or get the field value
        //ResWrapper obj = (ResWrapper)parser.readValueAs(ResWrapper.class);
        
        JSONParser vParse = JSON.createParser(response.getBody()); 
        
        // optional if the response structure if different from class
        // if the response strucure is like
        //{"person":{ "retry":"1","ErrCode":"01","accountId":"112"}}
        // Here field are inside the "person" tag and to assign this to our responsewrapper class you have to 
        //parse until you reach to 3 level, { : { here is the matching class structure

        vParse.nextToken(); 
        vParse.nextToken();
        vParse.nextToken();
        
        ResponseWrapper resObj = (ResponseWrapper)vParse.readValueAs(ResponseWrapper.class);
        system.debug('==resWrap Obj=='+resObj);
        system.debug('==resWrap Obj field value=='+resObj.AccountId);                
        system.debug('==resWrap Obj field value=='+resObj.retry);
        system.debug('==resWrap Obj field value=='+resObj.ErrCode);
        
        // if there is complex hier structure its good to keep it in map
        map<String,object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

        system.debug('--JSONMAP--'+jsonMap);
        map<string,object> person1Map = (map<string,object>)jsonMap.get('person1');
        system.debug('--AccountId--'+person1map.get('accountid'));
        
        list<map<string,object>> person2lst = new list<map<string,object>>();
        for(object obj2 : (list<object>)jsonMap.get('person2')){
            person2lst.add((map<string,object>)obj2);
        }
        System.debug('--LIST--'+person2lst);
        
        for(map<string,object> ss : person2lst)
        {
            system.debug('--errorCode--'+ss.get('errorcode'));
        
        }
        

        system.debug('--Map--'+jsonMap);
        //DEBUG|--Map--{person1={accountid=12222, errorcode=123, retry=0}, person2=({accountid=12222, errorcode=123, retry=0}, {accountid=12222, errorcode=123, retry=0})}

        system.debug('--Map Key set --'+jsonMap.Keyset());
        //DEBUG|--Map Key set --{person1, person2}

         list<object> ob2 = ( list<object>) jsonmap.get('person2');   
            system.debug('=='+ob2.get(1));
            //responsewrapper r3 = (responsewrapper) ob2.get(0); 
 
        for (string s : jsonMap.Keyset()){
            if(s == 'person1'){
                system.debug('--reached to 1st node--'+s);
                // assign this keyset value to wrapper class which is in same structure
                SYSTEM.DEBUG('--1st value--'+jsonMap.get(s));
            }
            if(s == 'person2'){
                system.debug('--reached to 2st node--'+s);
                // assign this keyset value to wrapper class which is in same structure
                SYSTEM.DEBUG('--2nd value--'+jsonMap.get(s));
                }
                
            }
        
             
    //return 'A';
    }   
    
    
    class requestWrapper{
        String id;
        String name;    
    }
    
    class ResponseWrapper{
        String ErrCode;
        String retry;
        String accountId;
    } 
    
    class requestHierWrapper{
        String accountId;
        String Name;
        list<reqContactwrapper> lstCont;
        reqOptywrapper optywrap;
    }
    
    class reqContactwrapper{
        string lname;    
    }    

    class reqOptywrapper{
        string Optyid;
        String name;    
    } 
    
/***** Errors n debug****
Line: 20, Column: 1
System.CalloutException: Unauthorized endpoint, please check Setup->Security->Remote site settings. endpoint = https://putsreq.com/ogBHM04BFS6PVvNfUSax

Request received by ext system by default serilaizing
[  
   {  
      "attributes":{  
         "type":"Account",
         "url":"/services/data/v41.0/sobjects/Account/0017F00000TwrgxQAB"
      },
      "Id":"0017F00000TwrgxQAB",
      "Name":"Burlington Textiles Corp of America"
   }
]

After assigning wrapper class

{  
   "name":"Burlington Textiles Corp of America",
   "id":"0017F00000TwrgxQAB"
}

09:17:09:859 USER_DEBUG [24]|DEBUG|==response==System.HttpResponse[Status=OK, StatusCode=200]

09:51:08:933 USER_DEBUG [51]|DEBUG|==resWrap Obj==ResponseWrapper:[ErrCode=01, accountId=112, retry=1, status=null, statusCode=null]
09:51:08:933 USER_DEBUG [52]|DEBUG|==resWrap Obj field value==112
09:51:08:933 USER_DEBUG [53]|DEBUG|==resWrap Obj field value==1
09:51:08:933 USER_DEBUG [54]|DEBUG|==resWrap Obj field value==01
09:51:08:933 USER_DEBUG [55]|DEBUG|==resWrap Obj field value==null
09:51:08:933 USER_DEBUG [56]|DEBUG|==resWrap Obj field value==null

1. sample response set: This does not require parse.nextToken()
{ "retry":"1","ErrCode":"01","accountId":"112"}

2. Response set: require to use nextToken()
{"person":{ "retry":"1","ErrCode":"01","accountId":"112"}}

$$ with 3rd approach with account and list of  contact request will be generated below after serialize
[  
   {  
      "attributes":{  
         "type":"Account",
         "url":"/services/data/v42.0/sobjects/Account/0017F00000TwrgxQAB"
      },
      "Id":"0017F00000TwrgxQAB",
      "Name":"Burlington Textiles Corp of America",
      "Contacts":{  
         "totalSize":1,
         "done":true,
         "records":[  
            {  
               "attributes":{  
                  "type":"Contact",
                  "url":"/services/data/v42.0/sobjects/Contact/0037F00000NdZG5QAN"
               },
               "AccountId":"0017F00000TwrgxQAB",
               "Id":"0037F00000NdZG5QAN",
               "LastName":"Rogers"
            }
         ]
      }
   }
]

RESULT: After createing an wrapper object with list of contact variable it still generate the message with additional attr in contact.
to remove the attr, needs to create addional contact wrapper and assing value in it.

$$ after iterating contact and assing in list of wrapper, the request is generated without addional attr
{  
   "Name":"Burlington Textiles Corp of America",
   "lstCont":[  
      {  
         "lname":"Rogers"
      },
      {  
         "lname":"Agrawal"
      }
   ],
   "accountId":"0017F00000TwrgxQAB"
}


$$ Added unrelated object in single JSON
{  
   "optywrap":{  
      "Optyid":"0067F000009P94KQAS",
      "name":"Edge SLA"
   },
   "Name":"Burlington Textiles Corp of America",
   "lstCont":[  
      {  
         "lname":"Rogers"
      },
      {  
         "lname":"Agrawal"
      }
   ],
   "accountId":"0017F00000TwrgxQAB"
}
*****/
}