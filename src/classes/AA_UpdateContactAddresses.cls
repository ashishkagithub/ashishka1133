/*
The start method provides the collection of all records that the execute method will process in individual batches. It returns the list of records to be processed by calling Database.getQueryLocator with a SOQL query. In this case we are simply querying for all Account records with a Billing Country of ‘USA’.
Each batch of 200 records is passed in the second parameter of the execute method. The execute method sets each contact’s mailing address to the accounts’ billing address and increments recordsProcessed to track the number of records processed.
When the job is complete, the finish method performs a query on the AsyncApexJob object (a table that lists information about batch jobs) to get the status of the job, the submitter’s email address, and some other information. It then sends a notification email to the job submitter that includes the job info and number of contacts updated.

17:48:41:015 EXCEPTION_THROWN [15]|System.LimitException: Too many callouts: 1
Sol: Needs to implement => Database.AllowsCallouts

LIMIT per BATCH CALL:
It's per each call of execute() in the batch, so for each "batch", you can call up to 10 HTTP callouts.  
If the callout can handle multiple records at a time, do so, and batch up to 10 callouts per batch, 
otherwise, set the batch scope to 1, so each apex batch handles one record at a time.

FINAL:
In batch size = 1 (1 record at a time) => 100 callout possible
In batch size = 2 (2 record at a time) => 50 callout possible

*/
global class AA_UpdateContactAddresses implements 
    Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, BillingStreet, BillingCity, BillingState, ' +
            'BillingPostalCode, (SELECT ID, MailingStreet, MailingCity, ' +
            'MailingState, MailingPostalCode FROM Contacts) FROM Account ' + 
            'Where BillingCountry = \'USA\''
        );
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        // process each batch of records
        
        SYSTEM.DEBUG('--Scope--'+scope);
        List<Contact> contacts = new List<Contact>();
        for (Account account : scope) {
            for (Contact contact : account.contacts) {
                contact.MailingStreet = account.BillingStreet;
                contact.MailingCity = account.BillingCity;
                contact.MailingState = account.BillingState;
                contact.MailingPostalCode = account.BillingPostalCode;
                // add contact to list to be updated
                contacts.add(contact);
                // increment the instance member counter
                recordsProcessed = recordsProcessed + 1;
            }


        }
            System.debug('--AA--');
            for (integer i=0; i<100;i++){
            AA_SimpleRESTGETCls.sendAccountIdANDparseResponse();
            }
        
                //update contacts;
    }    

    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        //EmailUtils.sendMessage(a, recordsProcessed);
    }    

}