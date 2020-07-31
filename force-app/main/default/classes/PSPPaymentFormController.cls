/*
   Class to handle ASP form payment processing and payment gateway redirection
*/
public with sharing class PSPPaymentFormController {
    
	 @AuraEnabled
    public static Boolean isInternalUser(){
        return GlobalUtility.isInternalUser();
    }
    
    //method to fetch details of logged in user
    @AuraEnabled
    public static String getLoggedInUserProfile() {
    
      return [SELECT Profile.Name FROM USER WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
    
    //method to fetch new/renewal application fee 
    @AuraEnabled
    public static Decimal getApplicationFee(String appId, String appType) {
       
        System.debug('AppId: '+appId);
        
        Case caseRec = [Select Service_Type__c FROM Case WHere Id =: appId];
        String appServiceType = caseRec.Service_Type__c;
        
        Pricebook2 priceBook = [SELECT Name, Id, IsActive FROM Pricebook2 where Name =: Label.ASP_Pricebook AND IsActive = true];
        
        if(appServiceType == GlobalConstants.SERVICE_TYPE_TAXI){
            
            String productNameToOperate = appType == GlobalConstants.NEW_APPLICATION_TYPE ? Label.ASP_Application_New_TSP_Product_Name : Label.ASP_Application_Renewal_TSP_Product_Name;
            
            Product2 product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name =: productNameToOperate AND IsActive = true];
            
            PricebookEntry pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
            return pricebookEntry.UnitPrice;
        }
        else if(appServiceType == GlobalConstants.SERVICE_TYPE_BOOKING) {
            
            String productNameToOperate = appType == GlobalConstants.NEW_APPLICATION_TYPE ? Label.ASP_Application_New_BSP_Product_Name : Label.ASP_Application_Renewal_BSP_Product_Name;
           system.debug('productNameToOperate: '+productNameToOperate);   
            
            Product2 product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name =: productNameToOperate AND IsActive = true];
            
            PricebookEntry pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
            return pricebookEntry.UnitPrice;
        }
        else if(appServiceType == GlobalConstants.SERVICE_TYPE_TAXI_BOOKING){
            
            Product2 product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name =: Label.ASP_Application_New_BSP_TSP_Product_Name AND IsActive = true];
            
            PricebookEntry pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
            return pricebookEntry.UnitPrice;
        }
        return null;
    }
    
    //method to submit payment details for the application
    //This method is used for ASP Application and ASP Renewal Application also
    @AuraEnabled
    public static String submitAspApplication(String applicationData, String paymentMethod, String appType){
        
        Case application;
        
        try {
        
            System.debug(LoggingLevel.INFO, 'Application Data: ' + applicationData);
        
            application = (Case)JSON.deserialize(applicationData, Case.class);
        
            if(appType == GlobalConstants.NEW_APPLICATION_TYPE) {
            
             application.Date_Submitted__c = DateTime.parse(DateTime.now().format());
             application.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
             update application;
            
             Case caseRecord = [SELECT Id, AccountId, CaseNumber, Service_Type__c,
                                    (SELECT Id, Family_Name__c, First_Given_Name__c, Date_of_Birth__c FROM Related_Contacts__r)
                               FROM Case
                               WHERE Id =:application.Id];
            
             application.Service_Type__c = caseRecord.Service_Type__c;
             
             Map<String, Related_Contact__c> identifierVsRelatedContact = new Map<String, Related_Contact__c>();
             if(caseRecord.Related_Contacts__r != null){
                for(Related_Contact__c relCon :caseRecord.Related_Contacts__r){
                    String identifier = getIdentifier(relCon.First_Given_Name__c, relCon.Family_Name__c,relCon.Date_of_Birth__c);
                    identifierVsRelatedContact.put(identifier , relCon);
                }
             }            
            
             //retrieve existing contacts on related account
             Map<String, Contact> identifierVsContact = new Map<String, Contact>();
             for(Contact con: [SELECT FirstName, LastName, BirthDate FROM Contact WHERE AccountId = :caseRecord.AccountId]){
                String identifier = getIdentifier(con.FirstName, con.LastName, con.BirthDate); 
                identifierVsContact.put(identifier, con);
             }
            
             for(String identifier : identifierVsRelatedContact.keySet()){
                if(identifierVsContact.containsKey(identifier)){
                    identifierVsRelatedContact.get(identifier).Related_Contact__c = identifierVsContact.get(identifier).Id;
                }
             }
            
             update identifierVsRelatedContact.values();
                
            }  else {
                
                Case caseRecord = [SELECT Id, AccountId, CaseNumber, Service_Type__c
                                   FROM Case
                                   WHERE Id =:application.Id];
                
                application.Service_Type__c = caseRecord.Service_Type__c;
            }
            
            Pricebook2 priceBook = [SELECT Name, Id, IsActive FROM Pricebook2 where Name =: Label.ASP_Pricebook AND IsActive = true];
            
            List<Authorisation__c> applicationAuthList = [SELECT Status__c, Service_Provider__c, Application__c
                                                          FROM Authorisation__c
                                                          WHERE Application__c = :application.Id
                                                          ORDER BY Name DESC LIMIT 1];
            
            Authorisation__c applicationAuth = applicationAuthList[0];
                                        
            Order paymentRecord;
            List<Order> existingDraftPayments = [SELECT AccountId, Payment_Reference__c
                                                  FROM Order 
                                                  WHERE Authorisation__c = :applicationAuth.Id
                                                  ORDER BY CreatedDate DESC LIMIT 1];
                                           
            if(existingDraftPayments.size() == 0)
              paymentRecord = new Order();
            else
              paymentRecord = existingDraftPayments[0];
            
            paymentRecord.AccountId = applicationAuth.Service_Provider__c;
            paymentRecord.Application__c = application.Id;
            paymentRecord.Authorisation__c = applicationAuth.Id;
            paymentRecord.Payment_Method__c = paymentMethod;
            paymentRecord.EffectiveDate = System.Today();
            paymentRecord.PriceBook2Id = priceBook.Id;
            
            if(paymentMethod == GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD)
               paymentRecord.Received_Date__c = System.Today();
               
            if(paymentMethod == GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT) {
               
               BusinessHours bh = new BusinessHours();
               bh = [SELECT Id FROM BusinessHours WHERE isDefault = TRUE];
               
               DateTime nextValidDateTime = DateTime.Now(); 
               Integer offset = UserInfo.getTimezone().getOffset(nextValidDateTime);
                   
               //is within business hours
               if(GlobalUtility.isInBusinessHours(bh, nextValidDateTime.addSeconds(offset/1000))) {
                
                 //check is before 3pm
                 Time timeLimit = Time.newInstance(15, 0, 0, 0);
                 //Time currentTime = DateTime.Now().Time();
                 Time currentTime = DateTime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'Australia/Sydney')).time();
                 
                 System.debug('Time Limit: '+timeLimit);
                 System.debug('Current Time: '+currentTime);
                 
                 //time has passed 3pm
                 if(currentTime > timeLimit) {
                   
                   //nextValidDateTime = DateTime.Now().addDays(1);
                   //nextValidDateTime = DateTime.newInstance(nextValidDateTime.year(), nextValidDateTime.month(), nextValidDateTime.day(), 10, 0, 0); 
                   nextValidDateTime = BusinessHours.nextStartDate(bh.Id, nextValidDateTime);
                   
                   System.debug('Next Time: '+nextValidDateTime);
                   
                   paymentRecord.Processing_Date__c = nextValidDateTime.Date();
                 }
                 else
                   paymentRecord.Processing_Date__c = nextValidDateTime.Date();
               }
               else {
               
                 //nextValidDateTime = DateTime.Now().addDays(1); 
                 //nextValidDateTime = DateTime.newInstance(nextValidDateTime.year(), nextValidDateTime.month(), nextValidDateTime.day(), 10, 0, 0); 
                 nextValidDateTime = BusinessHours.nextStartDate(bh.Id, nextValidDateTime);
                 
                 System.debug('Next Time: '+nextValidDateTime);
                 
                 paymentRecord.Processing_Date__c = nextValidDateTime.Date();
               }
            }
            
            System.debug('Time Validation Done');
            
            if(appType == GlobalConstants.NEW_APPLICATION_TYPE) {
              
              paymentRecord.Description = GlobalConstants.NEW_ASP_APPLICATION_FEE_DESCRIPTION;
            }
            else {
              
              paymentRecord.Description = GlobalConstants.RENEWAL_ASP_APPLICATION_FEE_DESCRIPTION;
            }
            
            paymentRecord.Status = GlobalConstants.NEW_ASP_APPLICATION_FEE_PAYMENT_STATUS;
              
            upsert paymentRecord;
            
            System.debug('Upsert Done');
            
            OrderItem paymentItem;
            
            List<OrderItem> existingOrderItem = [SELECT Quantity, Description 
                                                 FROM OrderItem
                                                 WHERE OrderId = :paymentRecord.Id
                                                 ORDER BY CreatedDate DESC LIMIT 1];
                                                 
            if(existingOrderItem.size() > 0)
             paymentItem = existingOrderItem[0];
            else {
            
             paymentItem = new OrderItem();
             paymentItem.OrderId = paymentRecord.Id;
            } 
            paymentItem.Quantity = 1;
            
            
            if(appType == GlobalConstants.NEW_APPLICATION_TYPE) {
            
             paymentItem.Transaction_Type__c = GlobalConstants.NEW_ASP_APPLICATION_TRANSACTION_TYPE;
             paymentItem.Description = GlobalConstants.NEW_ASP_APPLICATION_FEE_DESCRIPTION;
            }
            else {
             
             paymentItem.Transaction_Type__c = GlobalConstants.RENEWAL_ASP_APPLICATION_TRANSACTION_TYPE;
             paymentItem.Description = GlobalConstants.RENEWAL_ASP_APPLICATION_FEE_DESCRIPTION;             
            }
            
            String appServiceType = application.Service_Type__c;
            
            PricebookEntry pricebookEntry;
            Product2 product;
            
            if(existingOrderItem.size() == 0) {
            
             //selecting appropriate product based on service type like Taxi, Booking or both
             if(appServiceType == GlobalConstants.SERVICE_TYPE_TAXI){
             
              String productNameToOperate = appType == GlobalConstants.NEW_APPLICATION_TYPE ? Label.ASP_Application_New_TSP_Product_Name : Label.ASP_Application_Renewal_TSP_Product_Name;
             
              product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name =: Label.ASP_Application_New_TSP_Product_Name AND IsActive = true];
             
              pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
             }
             else if(appServiceType == GlobalConstants.SERVICE_TYPE_BOOKING){
            
              String productNameToOperate = appType == GlobalConstants.NEW_APPLICATION_TYPE ? Label.ASP_Application_New_BSP_Product_Name : Label.ASP_Application_Renewal_BSP_Product_Name;
              product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name =: Label.ASP_Application_New_BSP_Product_Name AND IsActive = true];
             
              pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
             }
             else if(appServiceType == GlobalConstants.SERVICE_TYPE_TAXI_BOOKING){
            
              product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name =: Label.ASP_Application_New_BSP_TSP_Product_Name AND IsActive = true];
             
              pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
             }
            
             paymentItem.PriceBookEntryId = pricebookEntry.Id;
             paymentItem.Product2Id = product.Id;
             paymentItem.UnitPrice = pricebookEntry.UnitPrice;
            }
            
            upsert paymentItem;
            
            Case tempApp = [SELECT Is_Complex_Application__c FROM Case WHERE Id = :application.Id];
            
            Case applicationToUpdate = new Case();
            applicationToUpdate.Id = application.Id;
            
            if(paymentMethod != GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD){
             
             //applicationToUpdate.Status = GlobalConstants.CASE_DRAFT;
             applicationToUpdate.Sub_Status__c = GlobalConstants.PENDING_PAYMENT_SUB_STATUS;
            }
            else
             applicationToUpdate.Sub_Status__c = tempApp.Is_Complex_Application__c ? GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING : GlobalConstants.CASE_STATUS_REVIEW_PENDING;
             
            update applicationToUpdate;
            
            Case caseRecord = [SELECT Id, AccountId, CaseNumber, Service_Type__c,
                                    (SELECT Id, Family_Name__c, First_Given_Name__c, Date_of_Birth__c FROM Related_Contacts__r)
                               FROM Case
                               WHERE Id =:application.Id];
                               
            caseRecord.Payment__c = paymentRecord.Id;
            //caseRecord.Status = GlobalConstants.CASE_DRAFT;
            //caseRecord.Sub_Status__c = GlobalConstants.PENDING_PAYMENT_SUB_STATUS;
            
            update caseRecord;
            
            paymentRecord = [SELECT Payment_Reference__c, BPay_Reference__c FROM Order WHERE Id = :paymentRecord.Id];
            
            return paymentRecord.Payment_Reference__c+','+caseRecord.CaseNumber+','+caseRecord.Id+', '+paymentRecord.BPay_Reference__c;
            
        } 
        catch(Exception e) {
        
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'PSPPaymentFormController', 'submitAspApplication', e.getMessage(), e);
            
            Case caseRecord = [SELECT Id, AccountId, CaseNumber, Service_Type__c,
                                    (SELECT Id, Family_Name__c, First_Given_Name__c, Date_of_Birth__c FROM Related_Contacts__r)
                               FROM Case
                               WHERE Id =:application.Id];
                               
            return JSON.serialize(caseRecord);
        }        
    }
    
    @AuraEnabled
    public static String processPayment(String appType, String orderRef, Boolean isInitiatedFromManageAccount, String sfRecordId) {
    
      try {
      
       String paymentMethod;
       Decimal amount;
       
         Order tempPayment = [SELECT Payment_Method__c, TotalAmount,Amount_Due__c 
                            FROM Order 
                            WHERE Payment_Reference__c = :orderRef];
                            
      paymentMethod = tempPayment.Payment_Method__c;
      //amount = tempPayment.TotalAmount;
      amount = tempPayment.Amount_Due__c;
       //Amount_Due__c
          
          
       System.debug('Payment Method: '+paymentMethod);
       System.debug('App Type: '+appType);
       System.debug('Amount: '+amount);
       System.debug('Order Ref. Number: '+orderRef);
       System.debug('Salesforce Record Id: '+sfRecordId);
      
       P2PWIBSPaymentFacade paymentFacade = new P2PWIBSPaymentFacade();
       
       //field to store if invokation is via a community user or by internal staff
       String invokationContext;
       
       if(GlobalUtility.isInternalUser())
          invokationContext = GlobalConstants.INVOCATION_CONTEXT_INTERNAL_STAFF;
       else
          invokationContext = GlobalConstants.INVOCATION_CONTEXT_ASP;
       
       Map<String, String> processedPaymentDetails = paymentFacade.securityToken(invokationContext, amount, orderRef, GlobalConstants.PAYMENT_METHOD_FACADE_MAPPING.get(paymentMethod), isInitiatedFromManageAccount, sfRecordId);
       
       return processedPaymentDetails.get('redirectURL');
      }
      catch(Exception e) {
      
       System.debug(LoggingLevel.ERROR, e);
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'PSPPaymentFormController', 'processPayment', e.getMessage(), e);
       return NULL;
      } 
    }
    
    private static String getIdentifier(String fName, String lName, Date dob) {
        
        return (fName + lName + (dob != null ? dob.format() : '')).toLowerCase();
    }
    
    // Method to update payment method on Order in case of Offline Payment
    @AuraEnabled
    public static String updateOrderPaymentMethod(String paymentMethod, String orderId) {
        
        try{
            
            System.debug('Payment Method: ' + paymentMethod);
            System.debug('Order Id: ' + orderId);
            
            Order paymentRecord = [SELECT Id, Payment_Method__c, BPay_Reference__c FROM Order
                                   WHERE Id =: orderId];
            
            paymentRecord.Payment_Method__c = paymentMethod;
            
            upsert paymentRecord;
            
            Order ordObjUpdated = [SELECT BPay_Reference__c FROM Order WHERE Id =: orderId];

            return 'SUCCESS'+','+ordObjUpdated.BPay_Reference__c;
        }
        catch(Exception e) {
            
            System.debug(LoggingLevel.ERROR, e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'PSPPaymentFormController', 'updateOrderPaymentMethod', e.getMessage(), e);
            return NULL;
        } 
    }
    
    //Method to update payment receipt number on Order
    @AuraEnabled
    public static String updateOrderReceiptNumber(String orderRefNumber, String receiptNumber) {
    
      try {
       
          Order tempOrder = [SELECT Receipt_Number__c, Payment_Reference__c 
                             FROM Order 
                             WHERE Payment_Reference__c = :orderRefNumber];
         tempOrder.Receipt_Number__c = receiptNumber;
                            
         update tempOrder;
         
         return tempOrder.Payment_Reference__c;
      }
      catch(Exception e) {
            
        System.debug(LoggingLevel.ERROR, e);
        ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'PSPPaymentFormController', 'updateOrderReceiptNumber', e.getMessage(), e);
        return NULL;
      } 
    } 
    
    @AuraEnabled
    public static String orderStatus(String caseId) {
        system.debug('caseID '+ caseId);
        Order orderst = [SELECT status FROM Order WHERE Application__c =: caseId LIMIT 1];
        system.debug('order status '+ orderst.status);
        return orderst.status;
        
    }
    
    @AuraEnabled
    public static String orderReceiptNumber(String caseId) {
        system.debug('caseID '+ caseId);
        Order orderReceiptNum = [SELECT Receipt_Number__c FROM Order WHERE Application__c =: caseId LIMIT 1];
        system.debug('Order Receipt Number '+ orderReceiptNum.Receipt_Number__c);
        return orderReceiptNum.Receipt_Number__c;
        
    }
}