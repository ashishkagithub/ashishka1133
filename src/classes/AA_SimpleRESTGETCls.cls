global with sharing class AA_SimpleRESTGETCls{

    global static void sendAccountIdANDparseResponse(){

        list<Account> lstAct = [select id,Name from Account where id ='0017F00000Twrgx'];
        String jsonStr = JSON.serialize(lstAct);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setendpoint('https://putsreq.com/ogBHM04BFS6PVvNfUSax');
        request.setEndpoint('callout:AA_REST_TEST');
        request.setmethod('GET');
        request.setbody(jsonStr);
       
        HttpResponse response = http.send(request);
        system.debug('==response Status=='+response.getStatus());
        system.debug('==response code=='+response.getStatusCode());
        }
    }