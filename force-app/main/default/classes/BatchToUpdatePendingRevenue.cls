global class BatchToUpdatePendingRevenue implements Database.Batchable<sObject> {
    global final String query;
  
    global Set<String> TYPE = new Set<String>{'Authorisation fee'};
    private static final String PAYMENT_DUE = GlobalConstants.PAYMENT_DUE_STATUS;
    private static final String PENDING_REVENUE = 'Pending Revenue';
    global BatchToUpdatePendingRevenue() {
        
        query = 'SELECT Id,Type,Payment_Method__c,Direct_Debit_Date__c,Received_Date__c,Receipt_Number__c,Payment_Cleared_Date__c FROM Order '+'WHERE Type IN : TYPE' + ' AND Status = :PAYMENT_DUE';
        system.debug(query);
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        
        
        List<Order> orderList = new List<Order>();
        
      for(Order ord : scope) {
           
            	ord.Status = PENDING_REVENUE;
                orderList.add(ord);
            
        }
        try{
            if(orderList.Size() > 0 )
             update orderList;   
           	//Database.update(orderList, false);
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage('Error','BatchToUpdatePendingRevenue','execute',ex.getMessage(),ex);
        }
        
        
    }
   
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
    }
}