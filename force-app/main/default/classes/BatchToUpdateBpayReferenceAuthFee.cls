global class BatchToUpdateBpayReferenceAuthFee implements Database.Batchable<sObject> {
    
    global final String query;
    global Set<String> PAYMENT_METHOD = new Set<String>{'Direct Debit'};
        global Set<String> TYPE = new Set<String>{'Authorisation fee'};
     global  Integer currentYear = System.now().Year();   
 global BatchToUpdateBpayReferenceAuthFee() {
       
        query = 'select TotalAmount,Payment_Reference__c,Bpay_Reference_Authfee__c from order '+
            'WHERE Type IN : TYPE  AND CALENDAR_YEAR(CreatedDate) =:currentYear';
    system.debug(query);
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        
        
        List<Order> AuthorisationfeeupdateorderList = new List<Order>(); 
        for( Order ord : scope)
        {
            if( ord.Bpay_Reference_Authfee__c == null)
                ord.Bpay_Reference_Authfee__c=  BPAYiCRNUtility.generateICRN(ord.TotalAmount,ord.Payment_Reference__c);
            
            system.debug( ord.Bpay_Reference_Authfee__c);
            AuthorisationfeeupdateorderList.add(ord);
            system.debug(AuthorisationfeeupdateorderList);
            system.debug(AuthorisationfeeupdateorderList.Size());
        }
        
        
        
        try{
            if(AuthorisationfeeupdateorderList.Size() > 0 )
                Database.update(AuthorisationfeeupdateorderList, false);
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage('Error','BatchToUpdateBpayReferenceAuthFee','execute',ex.getMessage(),ex);
        }
        
        
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
    }
}