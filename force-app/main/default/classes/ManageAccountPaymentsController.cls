public with sharing class ManageAccountPaymentsController {
    
    //This method retrives account name related to logged in user. 
    @AuraEnabled
    public static String getLoggedInUserAccount() {
        try {
            User loggedInUser = GlobalUtility.getLoggedInUser();
            Account act = loggedInUser.Account;
            return JSON.serialize(act);  
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ManageAccountPaymentsController','getLoggedInUserAccount',ex.getMessage(),ex);
            return null;
        }
    }
  // Updating payment method to null for direct debit where user has cancelled the details to enter for payment. 
    @AuraEnabled
    public static void updateOrderPaymentMethod(String paymentReferenceno) {
        try{
            
            List<Order> orderRecordsToUpdate = new List<Order>();
            for(Order ordRecord :[SELECT Id,Payment_Reference__c,Payment_Method__c FROM Order WHERE Payment_Reference__c =: paymentReferenceno]){
                if(ordRecord.Payment_Method__c=='Direct Debit'){
                    system.debug('order record found');
                    //Order ord = new Order(Id=ordRecord.Id);
                    ordRecord.Payment_Method__c='';
                    orderRecordsToUpdate.add(ordRecord);
                } 
            }
            if(orderRecordsToUpdate.Size() > 0)
            update orderRecordsToUpdate;
        }  
            catch (Exception ex) {
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ManageAccountPaymentsController','updateOrderPaymentMethod',ex.getMessage(),ex);
                
            }
        }
            
    @AuraEnabled
    public static String checkCustomerEnquiryCaseCreated(string paymentID){
        try{
            set<String> caseStatus = new set<String>{GlobalConstants.LODGED_CASE_STATUS, GlobalConstants.CLOSED_CASE_STATUS};
            list<Case> enquiryCases = [SELECT Id FROM Case 
                                       WHERE RecordType.DeveloperName = : GlobalConstants.CASE_RECORDTYPE_CUSTOMER_ENQUIRY_DEVNAME
                                             AND Status IN : caseStatus AND Payment__c = : paymentID
                                      ];
            if(enquiryCases.size() > 0){
                return 'TRUE';
            }
        }catch(Exception e){
            return e.getMessage();
        }
        return 'FALSE';
    }
    
    // This method retrieves all pending payments for logged in user's account of type 'Service Provider'
    @AuraEnabled
    public static String getPendingPaymentsForAccountASP() {
        
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser();
            
            List<Order> payments = [SELECT Id, OrderNumber, Authorisation__c, AUthorisation_Payment_Frequency__c,Authorisation__r.Payment_Frequency__c,  Authorisation__r.Name, Pending_Due_Date__c, Order_Type_From_Application__c,
                                    TotalAmount, Status,Amount_Due__c,EffectiveDate, Payment_Reference__c, Payment_Type__c,Payment_Method__c
                                    FROM Order
                                    WHERE ((Authorisation__c != NULL AND Application__c != NULL AND Application_Type__c =: GlobalConstants.SERVICE_PROVIDER_CASE_TYPE)
                                    OR (Type = 'Authorisation fee' AND PortalVisible__c= TRUE))
                                    AND AccountId =: loggedInUser.AccountId
                                    AND ((Status =: GlobalConstants.PAYMENT_DUE_STATUS ) OR Status =: GlobalConstants.PAYMENT_REJECTED_STATUS)
                                    ORDER BY STATUS DESC, EffectiveDate ASC, Authorisation__c ASC
                                   ];
            //AND Payment_Method__c !=: GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT
            String jsonResult = JSON.serialize(payments);
            return jsonResult;
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ManageAccountPaymentsController','getPendingPaymentsForAccountASP',ex.getMessage(),ex);
            return null;
        }
    }
    
    // This method retrieves all pending payments for logged in user's account of type 'Service Provider'
    @AuraEnabled
    public static String getPaidPaymentsForAccountASP() {
        
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser();
            
            List<Order> payments = [SELECT Id, OrderNumber, Authorisation__c,AUthorisation_Payment_Frequency__c, Authorisation__r.Payment_Frequency__c, Authorisation__r.Name,Pending_Due_Date__c, Order_Type_From_Application__c,
                                    TotalAmount, Status, Received_Date__c, Payment_Reference__c, Payment_Type__c
                                    FROM Order
                                    WHERE ((Application__c != NULL AND Application_Type__c =: GlobalConstants.SERVICE_PROVIDER_CASE_TYPE)
                                           OR Type = 'Authorisation fee')
                                    AND AccountId =: loggedInUser.AccountId
                                    AND Status =: GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS
                                    ORDER BY EffectiveDate ASC, Authorisation__c ASC
                                   ];
            
            String jsonResult = JSON.serialize(payments);
            return jsonResult;
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ManageAccountPaymentsController','getPaidPaymentsForAccountASP',ex.getMessage(),ex);
            return null;
        }
    }   
    
    // This method retrieves all pending payments for logged in user's account of type 'Taxi'
    @AuraEnabled
    public static String getPendingPaymentsForAccountTaxi() {
        
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser();
            
            List<Order> payments = [SELECT Id, OrderNumber, Authorisation__c, AUthorisation_Payment_Frequency__c, Authorisation__r.Name, Authorisation__r.Payment_Frequency__c, Pending_Due_Date__c, Order_Type_From_Application__c,
                                    TotalAmount, Status, EffectiveDate, Payment_Reference__c, Payment_Type__c
                                    FROM Order
                                    WHERE Authorisation__c != NULL
                                    AND Application__c != NULL
                                    AND Application_Type__c =: GlobalConstants.TAXI_CASE_TYPE
                                    AND AccountId =: loggedInUser.AccountId
                                    AND ((Status =: GlobalConstants.PAYMENT_DUE_STATUS AND Payment_Method__c !=: GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT) OR Status =: GlobalConstants.PAYMENT_REJECTED_STATUS)
                                    ORDER BY STATUS DESC, EffectiveDate ASC, Authorisation__c ASC
                                   ];
            
            String jsonResult = JSON.serialize(payments);
            return jsonResult;
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ManageAccountPaymentsController','getPendingPaymentsForAccountTaxi',ex.getMessage(),ex);
            return null;
        }
    }
    
    // This method retrieves all pending payments for logged in user's account of type 'Taxi'
    @AuraEnabled
    public static String getPaidPaymentsForAccountTaxi() {
        
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser();
            
            List<Order> payments = [SELECT Id, OrderNumber, Authorisation__c, Authorisation__r.Name,AUthorisation_Payment_Frequency__c, Authorisation__r.Payment_Frequency__c, Pending_Due_Date__c, Order_Type_From_Application__c,
                                    TotalAmount, Status, Received_Date__c, Payment_Reference__c, Payment_Type__c
                                    FROM Order
                                    WHERE Application__c != NULL
                                    AND Application_Type__c =: GlobalConstants.TAXI_CASE_TYPE
                                    AND AccountId =: loggedInUser.AccountId
                                    AND Status =: GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS
                                    ORDER BY EffectiveDate ASC, Authorisation__c ASC
                                   ];
            
            String jsonResult = JSON.serialize(payments);
            return jsonResult;
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ManageAccountPaymentsController','getPaidPaymentsForAccountTaxi',ex.getMessage(),ex);
            return null;
        }
    }  
    
    //method used for agents to return the account data for specified accountId
    @AuraEnabled
    public static String getAccountDataForAgents(String accId){
        
         if(GlobalUtility.agentHasAccountAccess(accId) == FALSE)
           return GlobalConstants.UNAUTHORISED_ACCESS;
           
         return TaxiAgentDataAccessProvider.getAccountDataForAgents(accId);
    } 
    
    // This method retrieves all pending payments for requested account
    @AuraEnabled
    public static String getPendingPaymentsForAgentsTaxi(String requestedAccId) {
       
       if(GlobalUtility.agentHasAccountAccess(requestedAccId) == FALSE)
           return GlobalConstants.UNAUTHORISED_ACCESS;
           
        List<Authorisation__c> accessibleLicences = GlobalUtility.getAgentAccessibleAuthorisations(requestedAccId);
      
        String jsonResult = JSON.serialize(TaxiAgentDataAccessProvider.getPendingPaymentsDataForAgents(requestedAccId, accessibleLicences));
        return jsonResult; 
    }
    
    // This method retrieves all paid payments for requested account
    @AuraEnabled
    public static String getPaidPaymentsForAgentsTaxi(String requestedAccId) {
        
        if(GlobalUtility.agentHasAccountAccess(requestedAccId) == FALSE)
           return GlobalConstants.UNAUTHORISED_ACCESS;
           
        List<Authorisation__c> accessibleLicences = GlobalUtility.getAgentAccessibleAuthorisations(requestedAccId);
      
        String jsonResult = JSON.serialize(TaxiAgentDataAccessProvider.getPaidPaymentsDataForAgents(requestedAccId, accessibleLicences));
        return jsonResult; 
    }
    
    
    @AuraEnabled
    public static Map<Id, Order> getAgentsPaymentsMap(String requestedAccId) {
    
        return TaxiAgentDataAccessProvider.getAgentsPaymentsMap(requestedAccId);
    }
}