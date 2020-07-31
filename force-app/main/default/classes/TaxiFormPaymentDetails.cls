/*
  Payment handler for taxi payment screens 
*/
public without sharing class TaxiFormPaymentDetails {
    
    
    //method to fetch details of logged in user
    @AuraEnabled
    public static String getLoggedInUserProfile() {
        
        return [SELECT Profile.Name FROM USER WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
    
    //method to fetch new/renewal application fee 
    @AuraEnabled
    public static Decimal getApplicationFee(String appId, String appType) {
        
        System.debug('AppId: '+appId);
        
        Authorisation__c licenceAuth = [SELECT Licence_Class__c, Licence_Type__c, Licence_Fee__c FROM Authorisation__c WHERE Application__c = :appId ORDER BY CreatedDate DESC LIMIT 1];
        
        Pricebook2 priceBook = [SELECT Name, Id, IsActive 
                                FROM Pricebook2 
                                WHERE Name =: Label.ASP_Pricebook AND IsActive = true];
        
        if(appType == GlobalConstants.NEW_APPLICATION_TYPE)
            return licenceAuth.Licence_Fee__c;
        else if(!String.isBlank(licenceAuth.Licence_Type__c)) {
            
            String productNameToOperate = Label.Taxi_Licence_Fee_Product_Name;
            String renewalProductName = productNameToOperate+' '+licenceAuth.Licence_Type__c; 
            
            Product2 product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name = :renewalProductName AND IsActive = true];
            
            PricebookEntry pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
            return pricebookEntry.UnitPrice;
        }
        
        return 200;
    }    
    
    //method to submit payment details for the application
    @AuraEnabled
    public static String submitTaxiApplication(String applicationData, String paymentMethod, String appType, Decimal licenceFee) {
        
        Case application;
        String applicationId, applicationLicenceId;
        Order referencePayment;
        
        try {
            
            System.debug(LoggingLevel.INFO, 'Application Data: ' + applicationData);
            
            application = (Case)JSON.deserialize(applicationData, Case.class);
            
            Authorisation__c applicationAuth = [SELECT Status__c, Licence_Fee__c, Licence_Type__c, Licence_Class__c, 
                                                Service_Provider__c, Payment_Frequency__c, Start_Date__c, End_Date__c
                                                FROM Authorisation__c
                                                WHERE Application__c = :application.Id];
            
            applicationId = application.Id;
            applicationLicenceId = applicationAuth.Id;
            
            if(appType == GlobalConstants.NEW_APPLICATION_TYPE) {
                
                application.Date_Submitted__c = DateTime.parse(DateTime.now().format());
                
                User loggedInUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
                
                application.ContactId = loggedInUser.ContactId;
                application.Date_Submitted__c = System.now();
                application.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
                application.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING;
                
                //set dml options to trigger case assignment
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                application.setOptions(dmo);
                update application;
                
                Case caseRecord = [SELECT Id, AccountId, Licence_Fee_Due__c, Notice_Email__c,
                                   (SELECT Id, Family_Name__c, First_Given_Name__c, Date_of_Birth__c FROM Related_Contacts__r)
                                   FROM Case
                                   WHERE Id =:application.Id];
                
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
                
                applicationAuth.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
                applicationAuth.Licence_Fee__c = caseRecord.Licence_Fee_Due__c;
                applicationAuth.Service_Provider_Notice_Email__c = caseRecord.Notice_Email__c;
                update applicationAuth;
                
            } else if(appType == GlobalConstants.RENEWAL_APPLICATION_TYPE) {
                
                User loggedInUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
                
                Group taxiLevel2 = [SELECT Id, Name FROM Group WHERE Type='Queue' AND DeveloperName = :GlobalConstants.TAXI_LEVEL_2_QUEUE_DEV_NAME];
                
                //check if any due payments associated with account
                /*
                List<Order> duePayments = [SELECT Id, Status, AccountId, EffectiveDate
                FROM Order WHERE Status = :GlobalConstants.PAYMENT_REJECTED_STATUS
                AND AccountId = :applicationAuth.Service_Provider__c
                AND EffectiveDate < :System.Today()];
                */
                
                Id taxiAdminRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
                            GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
                
                Case renewalLicenceApplication = new Case(); 
                renewalLicenceApplication.AccountId = applicationAuth.Service_Provider__c;
                renewalLicenceApplication.ContactId = loggedInUser.ContactId;
                renewalLicenceApplication.RecordTypeId = taxiAdminRecordType;
                renewalLicenceApplication.Subject = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;
                renewalLicenceApplication.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;               
                renewalLicenceApplication.Type = GlobalConstants.TAXI_CASE_TYPE;                 
                renewalLicenceApplication.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION;
                renewalLicenceApplication.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
                //renewalLicenceApplication.Sub_Status__c =  GlobalConstants.PENDING_PAYMENT_SUB_STATUS;
                renewalLicenceApplication.Information_Declaration__c = application.Information_Declaration__c;
                renewalLicenceApplication.Is_Privacy_Statement_Declared__c = application.Is_Privacy_Statement_Declared__c;
                renewalLicenceApplication.OwnerId = taxiLevel2.Id;
                renewalLicenceApplication.Authorisation__c = applicationAuth.Id;
                
                insert renewalLicenceApplication;
                
                applicationId = renewalLicenceApplication.Id;
                
                String soql = GlobalUtility.getCreatableFieldsSOQL('Related_Contact__c','Related_Application__c=\''+application.Id+'\'');  
                List<Related_Contact__c> targetContacts = (List<Related_Contact__c>)Database.query(soql);
                List<Related_Contact__c> clonedContacts = new List<Related_Contact__c>();
                for(Related_Contact__c tempContact : targetContacts) {
                    
                    Related_Contact__c clonedRelatedContact = tempContact.clone(false, true);
                    clonedRelatedContact.Name = tempContact.Name;
                    clonedRelatedContact.RecordTypeId = tempContact.RecordTypeId;
                    clonedRelatedContact.Related_Application__c = renewalLicenceApplication.Id;
                    clonedContacts.add(clonedRelatedContact);
                }
                
                if(clonedContacts.size() > 0)
                    insert clonedContacts;
                
                List<Authorisation__c> authToUpsert = new List<Authorisation__c>();
                soql = GlobalUtility.getCreatableFieldsSOQL('Authorisation__c','id=\''+applicationAuth.Id+'\'');
                Authorisation__c oldLicenceAuth = (Authorisation__c)Database.query(soql);
                Authorisation__c renewalLicenceAuth = oldLicenceAuth.clone(false, true, false, false);
                
                renewalLicenceAuth.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;  
                renewalLicenceAuth.Application__c = renewalLicenceApplication.Id;
                renewalLicenceAuth.Support_Process_Approval_Status__c = '';
                renewalLicenceAuth.Decision_Date__c = NULL;
                renewalLicenceAuth.Decision_Made_By__c = NULL;
                renewalLicenceAuth.Decision_Reason__c = '';
                renewalLicenceAuth.Start_Date__c = oldLicenceAuth.End_Date__c.addDays(1);
                renewalLicenceAuth.End_Date__c = renewalLicenceAuth.Start_Date__c.addYears(Integer.valueOf(Label.Default_Taxi_Term_period));
                renewalLicenceAuth.End_Date__c = renewalLicenceAuth.End_Date__c.addDays(-1);
                renewalLicenceAuth.Is_Renewal_Licence__c = TRUE;
                renewalLicenceAuth.Related_Authorisation__c = oldLicenceAuth.Id;
                renewalLicenceAuth.Licence_Fee__c = licenceFee;
                
                renewalLicenceAuth.OwnerId = taxiLevel2.Id;
                authToUpsert.add(renewalLicenceAuth);
                
                upsert authToUpsert;
                
                applicationLicenceId = renewalLicenceAuth.Id;
                
                soql = GlobalUtility.getCreatableFieldsSOQL('Condition__c','Authority__c=\''+applicationAuth.Id+'\'');  
                List<Condition__c> targetConditions = (List<Condition__c>)Database.query(soql);
                List<Condition__c> clonedConditions = new List<Condition__c>();
                for(Condition__c tempCondition : targetConditions) {
                    
                    Condition__c clonedCondition = tempCondition.clone(false, true);
                    clonedCondition.Authority__c = renewalLicenceAuth.Id;
                    clonedConditions.add(clonedCondition);
                }
                
                if(clonedConditions.size() > 0)
                    insert clonedConditions;
                
            }
            
            system.debug('applicationAuth.Payment_Frequency__c: '+applicationAuth.Payment_Frequency__c);
            if(applicationAuth.Payment_Frequency__c == GlobalConstants.MONTHLY_PAYMENT_FREQUENCY) {
                
                Date renewalLicenceStartDate = applicationAuth.End_Date__c;
                Date renewalLicenceEndDate = renewalLicenceStartDate.addYears(Integer.valueOf(Label.Default_Taxi_Term_period));
                
                List<Order> monthlyPayments = new List<Order>();
                List<OrderItem> monthlyPaymentItems = new List<OrderItem>();
                
                Pricebook2 priceBook = [SELECT Name, Id, IsActive FROM Pricebook2 
                                        WHERE Name =: Label.ASP_Pricebook AND IsActive = true];
                
                //first payment order record corresponding to application fee
                Order applicationFeePaymentRecord;
                
                List<Order> existingDraftPayments = [SELECT AccountId, Payment_Reference__c
                                                     FROM Order 
                                                     WHERE Authorisation__c = :applicationAuth.Id
                                                     ORDER BY CreatedDate DESC LIMIT 1];
                
                if(existingDraftPayments.isEmpty())
                    applicationFeePaymentRecord = new Order();
                else
                    applicationFeePaymentRecord = existingDraftPayments[0];
                    
                applicationFeePaymentRecord.AccountId = applicationAuth.Service_Provider__c;
                applicationFeePaymentRecord.Authorisation__c = applicationLicenceId;
                applicationFeePaymentRecord.Application__c = applicationId;
                applicationFeePaymentRecord.Payment_Method__c = paymentMethod;
                applicationFeePaymentRecord.PriceBook2Id = priceBook.Id;
                applicationFeePaymentRecord.EffectiveDate = System.Today();
                applicationFeePaymentRecord.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_FEE_DESCRIPTION;
                applicationFeePaymentRecord.Status = GlobalConstants.PAYMENT_DUE_STATUS;
                
                if(paymentMethod == GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD)
                  applicationFeePaymentRecord.Received_Date__c = System.Today();
                      
                if(paymentMethod == GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT) {
                  
                  BusinessHours bh = new BusinessHours();
                  bh = [SELECT Id FROM BusinessHours WHERE isDefault = TRUE];
                  
                  DateTime nextValidDateTime = DateTime.Now(); 
                  Integer offset = UserInfo.getTimezone().getOffset(nextValidDateTime);
                  Datetime local = nextValidDateTime.addSeconds(offset/1000);
                    
                  //is within business hours
                  if(GlobalUtility.isInBusinessHours(bh, nextValidDateTime.addSeconds(offset/1000))) {
                
                   //check is before 3pm
                   Time timeLimit = Time.newInstance(15, 0, 0, 0);
                   //Time currentTime = System.Now().Time();
                   Time currentTime = DateTime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'Australia/Sydney')).time();
                   
                   System.debug('Current DateTime: '+nextValidDateTime);
                   System.debug('Time Limit: '+timeLimit);
                   System.debug('Current Time: '+currentTime);
                 
                   //time has passed 3pm
                   if(currentTime > timeLimit) {
                  
                    //nextValidDateTime = nextValidDateTime.addDays(1); 
                    System.debug('One Day Added: '+nextValidDateTime);
                    //nextValidDateTime = DateTime.newInstance(Date.newInstance(nextValidDateTime.year(), nextValidDateTime.month(), nextValidDateTime.day()), Time.newInstance(10, 0, 0, 0)); 
                    nextValidDateTime = BusinessHours.nextStartDate(bh.Id, nextValidDateTime);
                    
                    System.debug('Next Business Start Date: '+nextValidDateTime);
                    
                    applicationFeePaymentRecord.Processing_Date__c = nextValidDateTime.Date();
                   }
                   else
                    applicationFeePaymentRecord.Processing_Date__c = nextValidDateTime.Date();
                  }
                  else {
               
                   nextValidDateTime = BusinessHours.nextStartDate(bh.Id, nextValidDateTime);
                    
                   System.debug('Next Valid DateTime: '+nextValidDateTime);
                   
                   applicationFeePaymentRecord.Processing_Date__c = nextValidDateTime.Date();
                  }
                }
                
                
                monthlyPayments.add(applicationFeePaymentRecord);
                
                
                if(existingDraftPayments.size() == 0) {
                 
                 System.debug('Start Date: '+renewalLicenceStartDate);
                 System.debug('End Date: '+renewalLicenceEndDate);
                 
                 for(Date tempDate=renewalLicenceStartDate;tempDate<renewalLicenceEndDate;tempDate = tempDate.addMonths(1)) {                    
                    
                    System.debug('Temp Date: '+tempDate);
                    
                    Order paymentRecord = new Order();
                    paymentRecord.AccountId = applicationAuth.Service_Provider__c;
                    paymentRecord.Authorisation__c = applicationLicenceId;
                    paymentRecord.Application__c = applicationId;
                    paymentRecord.Payment_Method__c = GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT;
                    paymentRecord.EffectiveDate = tempDate;
                    paymentRecord.Processing_Date__c = tempDate;                    
                    paymentRecord.PriceBook2Id = priceBook.Id;
                    paymentRecord.Description = GlobalConstants.RECURRING_RENEWAL_FEE_DESCRIPTION;
                    paymentRecord.Status = GlobalConstants.PAYMENT_DUE_STATUS;
                    
                    monthlyPayments.add(paymentRecord);                    
                 }
                }
                
                Integer index = 0;
                if(!monthlyPayments.isEmpty()) {
                    
                    upsert monthlyPayments;
                    referencePayment = monthlyPayments[0];
                    
                    Map<String, Taxi_Class__mdt> taxiConfigMap = new Map<String, Taxi_Class__mdt>();
                    List<Taxi_Class__mdt> taxiConfig = [SELECT Description__c, Is_Legacy_Only__c,
                                                        Is_Renewable__c, Is_Transferable__c, Is_WAT__c, Licence_Class__c,
                                                        Licence_Type__c, Max_Years__c, Operating_Area__c, Renew_Formula__c,
                                                        Renew_Months__c
                                                        FROM Taxi_Class__mdt];
                    
                    for(Taxi_Class__mdt tempTaxiConfig : taxiConfig)
                        taxiConfigMap.put(tempTaxiConfig.Licence_Class__c, tempTaxiConfig);
                    
                    //first payment order line item record corresponding to licence application fee
                    OrderItem applicationFeePaymentItem;
                    
                    List<OrderItem> existingOrderItem = [SELECT Quantity, Description 
                                                         FROM OrderItem
                                                         WHERE OrderId = :monthlyPayments[index].Id
                                                         ORDER BY CreatedDate DESC LIMIT 1];
                                                 
                    if(existingOrderItem.size() > 0)
                     applicationFeePaymentItem = existingOrderItem[0];
                    else {
                     
                     applicationFeePaymentItem = new OrderItem();
                     applicationFeePaymentItem.OrderId = monthlyPayments[index].Id;
                    }
                    
                    applicationFeePaymentItem.Quantity = 1;
                    
                    //if monthly payment is not for renewal
                    if(appType == GlobalConstants.NEW_APPLICATION_TYPE) {
                        
                        applicationFeePaymentItem.Transaction_Type__c = GlobalConstants.NEW_TAXI_APPLICATION_TRANSACTION_TYPE;
                        applicationFeePaymentItem.Description = GlobalConstants.NEW_TAXI_APPLICATION_FEE_DESCRIPTION;
                    }
                    else {
                        
                        applicationFeePaymentItem.Transaction_Type__c = GlobalConstants.RENEWAL_TAXI_APPLICATION_TRANSACTION_TYPE;
                        applicationFeePaymentItem.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_FEE_DESCRIPTION;
                    }
                    
                    PricebookEntry pricebookEntry;
                    Product2 product;
                    
                    if(existingOrderItem.size() == 0) {
                    
                     if(!String.isBlank(applicationAuth.Licence_Type__c)) {
                        
                        //String productNameToOperate = Label.Taxi_New_Application_Product_Name;
                        String productNameToOperate = Label.Taxi_Licence_Fee_Product_Name;
                        String renewalProductName = productNameToOperate+' '+applicationAuth.Licence_Type__c; 
                        
                        product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name = :renewalProductName AND IsActive = true];
                        
                        pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
                     }
                    
                     applicationFeePaymentItem.PriceBookEntryId = pricebookEntry.Id;
                     applicationFeePaymentItem.Product2Id = product.Id;
                    
                     if(appType == GlobalConstants.RENEWAL_APPLICATION_TYPE)
                        applicationFeePaymentItem.UnitPrice = pricebookEntry.UnitPrice;
                     else
                        applicationFeePaymentItem.UnitPrice = applicationAuth.Licence_Fee__c;
                    }
                    
                    monthlyPaymentItems.add(applicationFeePaymentItem);
                    
                    if(existingOrderItem.size() == 0 && !String.isBlank(applicationAuth.Licence_Class__c)) {
                            
                            String productNameToOperate = appType == GlobalConstants.NEW_APPLICATION_TYPE ? Label.Taxi_Licence_Fee_Product_Name: Label.Taxi_Renewal_Application_Product_Name;
                            String renewalProductName = appType == GlobalConstants.NEW_APPLICATION_TYPE ? productNameToOperate+' '+applicationAuth.Licence_Type__c : productNameToOperate+' '+applicationAuth.Licence_Class__c; 
                            
                            product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name = :renewalProductName AND IsActive = true];
                            
                            pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
                    }
                        
                    index = 1;
                    
                    if(existingOrderItem.size() == 0) {
                    
                     for(Date tempDate=renewalLicenceStartDate;tempDate<renewalLicenceEndDate;tempDate = tempDate.addMonths(1)) {
                        
                        OrderItem licenceFeePaymentItem = new OrderItem();
                        licenceFeePaymentItem.OrderId = monthlyPayments[index].Id;
                        licenceFeePaymentItem.Quantity = 1;
                        
                        if(appType == GlobalConstants.RENEWAL_APPLICATION_TYPE) {
                            
                            licenceFeePaymentItem.Transaction_Type__c = GlobalConstants.RENEWAL_TAXI_APPLICATION_TRANSACTION_TYPE;
                            licenceFeePaymentItem.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_FEE_DESCRIPTION;
                        }
                        else {
                            
                            licenceFeePaymentItem.Transaction_Type__c = GlobalConstants.NEW_TAXI_APPLICATION_TRANSACTION_TYPE;
                            licenceFeePaymentItem.Description = GlobalConstants.NEW_TAXI_APPLICATION_FEE_DESCRIPTION;
                        }
                        
                        
                        licenceFeePaymentItem.PriceBookEntryId = pricebookEntry.Id;
                        licenceFeePaymentItem.Product2Id = product.Id;
                        
                        //calculating monthly payment based on renewal configuration
                        if(appType == GlobalConstants.RENEWAL_APPLICATION_TYPE && taxiConfigMap.containsKey(applicationAuth.Licence_Class__c)) {
                            
                            Decimal monthlyPayment = licenceFee/taxiConfigMap.get(applicationAuth.Licence_Class__c).Renew_Months__c;
                            Decimal roundedMonthlyPayment = monthlyPayment.setScale(2, RoundingMode.DOWN);
                            
                            if(tempDate.monthsBetween(renewalLicenceEndDate) != 1)
                                licenceFeePaymentItem.UnitPrice = roundedMonthlyPayment;
                            else
                                licenceFeePaymentItem.UnitPrice = (licenceFee - (roundedMonthlyPayment * (taxiConfigMap.get(applicationAuth.Licence_Class__c).Renew_Months__c - 1))).setScale(2, RoundingMode.DOWN);
                        }
                        else 
                            licenceFeePaymentItem.UnitPrice = applicationAuth.Licence_Fee__c;
                        
                        monthlyPaymentItems.add(licenceFeePaymentItem);
                        
                        index++;
                     }
                    }
                    
                    if(monthlyPaymentItems.size() > 0)
                        upsert monthlyPaymentItems;
                        
                    //generate Bpay iCRN number generation if payment method was Bpay    
                    if(paymentMethod == GlobalConstants.PAYMENT_METHOD_BPAY) {
                      
                      List<Order> orderWithBpayReference = new List<Order>();
                      
                      for(Order tempOrder : [SELECT TotalAmount, Payment_Reference__c 
                                             FROM ORDER
                                             WHERE Id IN :monthlyPayments]) {
                                  
                            tempOrder.BPay_Reference__c = BPAYiCRNUtility.generateICRN(tempOrder.TotalAmount, tempOrder.Payment_Reference__c);
                            orderWithBpayReference.add(tempOrder);       
                      }
                      
                      if(orderWithBpayReference.size() > 0)
                         update orderWithBpayReference;
                    }
                }
            }
            else {
                
                Pricebook2 priceBook = [SELECT Name, Id, IsActive FROM Pricebook2 where Name =: Label.ASP_Pricebook AND IsActive = true];
                
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
                paymentRecord.Authorisation__c = applicationLicenceId;
                paymentRecord.Application__c = applicationId;
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
                 Datetime local = nextValidDateTime.addSeconds(offset/1000);
                   
                 //is within business hours
                 if(GlobalUtility.isInBusinessHours(bh, nextValidDateTime.addSeconds(offset/1000))) {
                
                  //check is before 3pm
                  Time timeLimit = Time.newInstance(15, 0, 0, 0);
                  //Time currentTime = System.Now().Time();
                  Time currentTime = DateTime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'Australia/Sydney')).time();
                  
                  //time has passed 3pm
                  if(currentTime > timeLimit) {
                  
                   //nextValidDateTime = DateTime.Now().addDays(1); 
                   nextValidDateTime = BusinessHours.nextStartDate(bh.Id, nextValidDateTime);
                   
                   paymentRecord.Processing_Date__c = nextValidDateTime.Date();
                  }
                  else
                   paymentRecord.Processing_Date__c = nextValidDateTime.Date();
                 }
                 else {
               
                  //nextValidDateTime = DateTime.Now().addDays(1); 
                  nextValidDateTime = BusinessHours.nextStartDate(bh.Id, nextValidDateTime);
                  
                  paymentRecord.Processing_Date__c = nextValidDateTime.Date();
                 }
                }
                
                if(appType == GlobalConstants.NEW_APPLICATION_TYPE) {
                    
                    paymentRecord.Description = GlobalConstants.NEW_TAXI_APPLICATION_FEE_DESCRIPTION;
                }
                else {
                    
                    paymentRecord.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_FEE_DESCRIPTION;
                }
                
                paymentRecord.Status = GlobalConstants.NEW_TAXI_APPLICATION_FEE_PAYMENT_STATUS;
                  
                upsert paymentRecord;
                referencePayment = paymentRecord;
                
                List<OrderItem> paymentItems = new List<OrderItem>();
                
                OrderItem applicationFeePaymentItem;
                
                List<OrderItem> existingOrderItem = [SELECT Quantity, Description 
                                                     FROM OrderItem
                                                     WHERE OrderId = :paymentRecord.Id
                                                     ORDER BY CreatedDate DESC LIMIT 1];
                                                 
                if(existingOrderItem.size() > 0)
                 applicationFeePaymentItem = existingOrderItem[0];
                else {
                
                 applicationFeePaymentItem = new OrderItem();
                 applicationFeePaymentItem.OrderId = paymentRecord.Id;
                } 
                
                applicationFeePaymentItem.Quantity = 1;
                
                applicationFeePaymentItem.Transaction_Type__c = GlobalConstants.NEW_TAXI_APPLICATION_TRANSACTION_TYPE;
                applicationFeePaymentItem.Description = GlobalConstants.NEW_TAXI_APPLICATION_FEE_DESCRIPTION;
                
                
                PricebookEntry pricebookEntry;
                Product2 product;
                
                if(existingOrderItem.size() == 0) {
                
                 if(!String.isBlank(applicationAuth.Licence_Type__c)) {
                    
                    //String productNameToOperate = Label.Taxi_New_Application_Product_Name;
                    String productNameToOperate = Label.Taxi_Licence_Fee_Product_Name;
                    String renewalProductName = productNameToOperate+' '+applicationAuth.Licence_Type__c; 
                    
                    System.debug('Product Name: '+renewalProductName);
                    
                    product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name = :renewalProductName AND IsActive = true];
                    
                    pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
                 }
                
                 applicationFeePaymentItem.PriceBookEntryId = pricebookEntry.Id;
                 applicationFeePaymentItem.Product2Id = product.Id;
                
                
                 if(appType == GlobalConstants.RENEWAL_APPLICATION_TYPE)
                    applicationFeePaymentItem.UnitPrice = pricebookEntry.UnitPrice;
                 else
                    applicationFeePaymentItem.UnitPrice = applicationAuth.Licence_Fee__c;
                }
                
                paymentItems.add(applicationFeePaymentItem);
                
                //if payment is for renewal
                if(existingOrderItem.size() == 0 && appType == GlobalConstants.RENEWAL_APPLICATION_TYPE) {
                    
                    OrderItem licenceFeePaymentItem = new OrderItem();
                    licenceFeePaymentItem.OrderId = paymentRecord.Id;
                    licenceFeePaymentItem.Quantity = 1;
                    licenceFeePaymentItem.Transaction_Type__c = GlobalConstants.RENEWAL_TAXI_APPLICATION_TRANSACTION_TYPE;
                    licenceFeePaymentItem.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_FEE_DESCRIPTION;
                    
                    if(!String.isBlank(applicationAuth.Licence_Class__c)) {
                        
                        String productNameToOperate = Label.Taxi_Renewal_Application_Product_Name;
                        String renewalProductName = productNameToOperate+' '+applicationAuth.Licence_Class__c; 
                        System.debug('renewalProductName: '+renewalProductName);
                        product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name = :renewalProductName AND IsActive = true];
                        
                        pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
                    }
                    
                    licenceFeePaymentItem.PriceBookEntryId = pricebookEntry.Id;
                    licenceFeePaymentItem.Product2Id = product.Id;
                    licenceFeePaymentItem.UnitPrice = licenceFee;
                    
                    paymentItems.add(licenceFeePaymentItem);
                }
                
                upsert paymentItems;
                
                //generate Bpay iCRN number generation if payment method was Bpay    
                if(paymentMethod == GlobalConstants.PAYMENT_METHOD_BPAY) {
                  
                  paymentRecord = [SELECT TotalAmount, Payment_Reference__c 
                                   FROM Order WHERE Id = :paymentRecord.Id];
                                   
                  System.debug('Bpay Payment Method');
                  System.debug('Total Amount: '+paymentRecord.TotalAmount);
                                   
                  paymentRecord.BPay_Reference__c = BPAYiCRNUtility.generateICRN(paymentRecord.TotalAmount, paymentRecord.Payment_Reference__c);   
                  
                  update paymentRecord; 
                }
            }
            
            
            Case applicationToUpdate = new Case();
            applicationToUpdate.Id = applicationId;
            applicationToUpdate.Payment__c = referencePayment.Id;
            
            if(paymentMethod != GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD){
             
             //applicationToUpdate.Status = GlobalConstants.CASE_DRAFT;
             applicationToUpdate.Sub_Status__c = GlobalConstants.PENDING_PAYMENT_SUB_STATUS;
            }
            else
             applicationToUpdate.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
            
            update applicationToUpdate;
            
            String applicationNumber = [SELECT CaseNumber FROM Case WHERE Id = :applicationId].CaseNumber;
            
            referencePayment = [SELECT Payment_Reference__c, BPay_Reference__c FROM Order WHERE Id = :referencePayment.Id];
            
            return referencePayment.Payment_Reference__c+','+applicationNumber+','+referencePayment.BPay_Reference__c;
            
        } catch(Exception e){
            
            System.debug('Exception: '+e.getMessage());
            System.debug('Exception: '+e.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormPaymentDetails', 'submitTaxiApplication', e.getMessage(), e);
            
            String applicationNumber = [SELECT CaseNumber FROM Case WHERE Id = :applicationId].CaseNumber;
            
            return applicationNumber;
        }        
    }
    
    private static String getIdentifier(String fName, String lName, Date dob){
        return (fName + lName + (dob != null ? dob.format() : '')).toLowerCase();
    }
    
    //Method to fetch levy due amount for Taxi Transfer Application
    @AuraEnabled
    public static Decimal getTaxiTransferLevyDueAmount(String sellerCaseId) {
        
        Case buyerCase = [SELECT Id, Levy_Due__c FROM Case WHERE ParentId =: sellerCaseId];

        return buyerCase.Levy_Due__c;
    }
    
    //Method to submit payment details for the Taxi Transfer Application
    @AuraEnabled
    public static String submitTaxiTransferApplication(String sellerCaseId, String paymentMethod, Decimal levyDueAmount){
        
        try {
            // Get seller case record
            Case sellerCaseRecord = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c, Authorisation__c,
                                     Transfer_Reason__c, Licence_Fee_Due__c, Beneficiary_Type__c, Is_Privacy_Statement_Declared__c 
                                     FROM Case Where Id=: sellerCaseId];
            
            // Get Authorisation created for Taxi Transfer
            Authorisation__c authorisationRecord = [SELECT Licence_Class__c, Service_Provider__c FROM Authorisation__c WHERE Application__c = :sellerCaseId ORDER BY CreatedDate DESC LIMIT 1];
            
            // Create new or get existing draft payment record (Order and OrderItem)
            Pricebook2 priceBook = [SELECT Name, Id, IsActive FROM Pricebook2 where Name =: Label.ASP_Pricebook AND IsActive = true];
            
            Order paymentRecord;
            List<Order> existingDraftPayments = [SELECT AccountId, Payment_Reference__c
                                                 FROM Order 
                                                 WHERE Authorisation__c = :authorisationRecord.Id
                                                 ORDER BY CreatedDate DESC LIMIT 1];
            
            if(existingDraftPayments.size() == 0) {
                paymentRecord = new Order();
            }
            else {
                paymentRecord = existingDraftPayments[0];
            }
            
            paymentRecord.Status = GlobalConstants.TAXI_TRANSFER_APPLICATION_LEVY_DUE_STATUS;
            paymentRecord.Description = GlobalConstants.TAXI_TRANSFER_APPLICATION_LEVY_DUE_DESCRIPTION;
            paymentRecord.AccountId = authorisationRecord.Service_Provider__c;
            paymentRecord.Authorisation__c = authorisationRecord.Id;
            paymentRecord.Application__c = sellerCaseId;
            paymentRecord.Payment_Method__c = paymentMethod;
            paymentRecord.PriceBook2Id = priceBook.Id;
            paymentRecord.EffectiveDate = System.Today();
            paymentRecord.EndDate = System.Today();
            
            if(levyDueAmount == 0) {
                paymentRecord.Status = GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS;
            }
            upsert paymentRecord;
            
            OrderItem levyDuePaymentItem = new OrderItem();
            levyDuePaymentItem.OrderId = paymentRecord.Id;
            levyDuePaymentItem.Quantity = 1;
            levyDuePaymentItem.UnitPrice = levyDueAmount;
            
            PricebookEntry pricebookEntry;
            Product2 product;
            if(!String.isBlank(authorisationRecord.Licence_Class__c)) {
                
                String productNameToOperate = Label.Taxi_Transfer_Levy_Product_Name;
                
                product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name = :productNameToOperate AND IsActive = true];
                
                pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Product2.Name, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
            }
            
            levyDuePaymentItem.Product2Id = product.Id;
            levyDuePaymentItem.PriceBookEntryId = pricebookEntry.Id;
            levyDuePaymentItem.Transaction_Type__c = GlobalConstants.TAXI_TRANSFER_APPLICATION_TRANSACTION_TYPE;
            levyDuePaymentItem.Description = pricebookEntry.Product2.Name;        
            insert levyDuePaymentItem;
            
            sellerCaseRecord.Payment__c = paymentRecord.Id;
            sellerCaseRecord.Sub_Status__c = GlobalConstants.PENDING_PAYMENT_SUB_STATUS;
            
            update sellerCaseRecord;
            
            return sellerCaseRecord.CaseNumber;
            
        } catch(Exception e){
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormPaymentDetails', 'submitTaxiTransferApplication', e.getMessage(), e);
            return null;
        }        
    }
    
    //method to trigger payment gateway processing and return callback URL
    @AuraEnabled
    public static String processPayment(String appType, String orderRef,  Boolean isInitiatedFromManageAccount, String sfRecordId) {
    
      try {
      
       String paymentMethod;
       Decimal amount;
       
       Order tempPayment = [SELECT Payment_Method__c, TotalAmount 
                            FROM Order 
                            WHERE Payment_Reference__c = :orderRef];
                            
       paymentMethod = tempPayment.Payment_Method__c;
       amount = tempPayment.TotalAmount;
       
       System.debug('Payment Method: '+paymentMethod);
       System.debug('App Type: '+appType);
       System.debug('Amount: '+amount);
       System.debug('Order Ref. Number: '+orderRef);
       System.debug('Salesforce Record Id: '+sfRecordId);
       
       //field to store if invokation is via a community user or by internal staff
       String invokationContext;
       
       String loggedInUserProfile = getLoggedInUserProfile();
       
       if(GlobalUtility.isInternalUser())
          invokationContext = GlobalConstants.INVOCATION_CONTEXT_INTERNAL_STAFF;
       else
          invokationContext = GlobalConstants.INVOCATION_CONTEXT_TAXI;
          
       P2PWIBSPaymentFacade paymentFacade = new P2PWIBSPaymentFacade();
       Map<String, String> processedPaymentDetails = paymentFacade.securityToken(invokationContext, amount, orderRef, GlobalConstants.PAYMENT_METHOD_FACADE_MAPPING.get(paymentMethod), isInitiatedFromManageAccount, sfRecordId);
       
       return processedPaymentDetails.get('redirectURL');
      }
      catch(Exception e) {
      
       System.debug(LoggingLevel.ERROR, e);
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormPaymentDetails', 'processPayment', e.getMessage(), e);
       return NULL;
      } 
    }
    
    // Method to update payment method on Order in case of Offline Payment
    @AuraEnabled
    public static String updateOrderPaymentMethod(String paymentMethod, String orderId) {
        
        try{
            
            System.debug('Payment Method: ' + paymentMethod);
            System.debug('Order Id: ' + orderId);
            
            Order paymentRecord = [SELECT Id, Payment_Method__c FROM Order
                                 WHERE Id =: orderId];
            
            paymentRecord.Payment_Method__c = paymentMethod;
            paymentRecord.Payment_Summary_Code__c = '';
            paymentRecord.Payment_Response_Code__c  = '';
            paymentRecord.Payment_Response_Description__c = '';
            upsert paymentRecord;
            
            paymentRecord = [SELECT Payment_Reference__c, BPay_Reference__c FROM Order WHERE Id = :paymentRecord.Id];
            
            return paymentRecord.Payment_Reference__c+','+paymentRecord.BPay_Reference__c;
            
            //return 'SUCCESS';
        }
        catch(Exception e) {
            
            System.debug(LoggingLevel.ERROR, e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormPaymentDetails', 'updateOrderPaymentMethod', e.getMessage(), e);
            return NULL;
        } 
    }
    
    @AuraEnabled
    public static String orderStatus(String caseId) {
        system.debug('caseID '+ caseId);
        Order orderst = [SELECT status FROM Order WHERE Application__c =: caseId LIMIT 1];
        system.debug('orderStatus '+ orderst.status);
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