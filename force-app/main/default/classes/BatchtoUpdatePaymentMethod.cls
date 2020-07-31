global class BatchtoUpdatePaymentMethod implements Database.Batchable<sObject> {
    global final String query;
    global Set<String> PAYMENT_METHOD = new Set<String>{'Direct Debit'};
    global Set<String> TYPE = new Set<String>{'Authorisation fee'};
    private static final String PAYMENT_DUE = GlobalConstants.PAYMENT_DUE_STATUS;
   
    global BatchtoUpdatePaymentMethod() {
        
        query = 'SELECT Id,Type,Payment_Method__c,Direct_Debit_Date__c,Received_Date__c,Receipt_Number__c,Payment_Cleared_Date__c FROM Order '+'WHERE Payment_Method__c in : PAYMENT_METHOD  AND Type IN : TYPE' + ' AND Status = :PAYMENT_DUE';
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        
        
        List<Order> orderList = new List<Order>();
        
      for(Order ord : scope) {
            if(ord.Direct_Debit_Date__c < System.today() && ord.Received_Date__c==null && ord.Receipt_Number__c==null && ord.Payment_Cleared_Date__c==null
               ){
            	ord.Payment_Method__c = '';
                orderList.add(ord);
            } 
        }
        try{
           	Database.update(orderList, false);
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage('Error','BatchtoUpdatePaymentMethod','execute',ex.getMessage(),ex);
        }
        
        
    }
   
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
    }
}