/*
 * Controller class to ensure agents have access to data 
 * which is not shared with them via sharing set
 */
public without sharing class TaxiAgentDataAccessProvider {
  
  public static String getAccountDataForAgents(String requiredAccId){
     
     Account requiredAccount = [SELECT Id, Name, CreatedDate, ABN__c, ACN__c, LastModifiedBy.Name, Email__c, Customer_Number__c,
                                 Website, BillingStreet, BillingCity, BillingState, BillingPostalCode,Document_Delivery_Preference__c,
                                 ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Notice_Email__c,Registered_Business_Name__c,
                                 Notice_Address_Street__c, Notice_Address_City__c, Notice_Address_State__c, Notice_Address_Postal_Code__c,Notice__Latitude__s,Notice__Longitude__s, 
                                 Record_Type_dev_Name__c, Phone,RecordType.Name,
                                 Business_Name_For_Customer_Contact__c, Daytime_Phone_No_For_Customer_Contact__c, Email_For_Customer_Contact__c,
                                 Website_For_Customer_Contact__c, Social_Media_For_Customer_Contact__c, Other_Details_For_Customer_Contact__c
                               FROM Account WHERE Id =:requiredAccId];
                               
     return JSON.serialize(requiredAccount);
  }
  
  public static List<Contact> getContactsDataForAgents(String requiredAccId){
    
    return [SELECT Id, Account.Name, Contact_Type__c, Primary_Contact__c,
                        FirstName, LastName, LastModifiedDate, Deactivated__c, MailingState, 
                        Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c, Of_Interest__c
                        FROM Contact 
                        WHERE AccountId = :requiredAccId 
                        and Deactivated__c = false 
                        and Contact_Type__c != :GlobalConstants.CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE 
                        ORDER BY LastModifiedDate DESC];
  }
  
  public static List<Order> getPendingPaymentsDataForAgents(String requiredAccId, List<Authorisation__c> accessibleLicences) {
    
    List<Authorisation__c> fullAccessAuths = new List<Authorisation__c>();
    List<Authorisation__c> transferOnlyAccessAuths = new List<Authorisation__c>();
    List<Order> targetPaymentRecords = new List<Order>();
    
    for(Authorisation__c tempAuth : accessibleLicences) {
       
      if(tempAuth.Agreement_Type__c == GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE_FULL_ACCESS)
         fullAccessAuths.add(tempAuth);
      
      if(tempAuth.Agreement_Type__c == GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE)
         transferOnlyAccessAuths.add(tempAuth);
    } 
    
    for(Order tempOrder : [SELECT Id, OrderNumber, Authorisation__c, Authorisation__r.Name, Order_Type_From_Application__c,
                                    TotalAmount, Status, EffectiveDate, Payment_Reference__c,
                                    Application_Sub_Type__c, Application__c
                                    FROM Order
                                    WHERE Authorisation__c != NULL
                                    AND Authorisation__c IN :transferOnlyAccessAuths
                                    AND Application__c != NULL
                                    AND Application_Type__c = :GlobalConstants.TAXI_CASE_TYPE
                                    AND Application_Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER
                                    AND AccountId = :requiredAccId
                                    AND ((Status =: GlobalConstants.PAYMENT_DUE_STATUS AND Payment_Method__c !=: GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT) OR Status =: GlobalConstants.PAYMENT_REJECTED_STATUS)
                                    ORDER BY STATUS DESC, EffectiveDate ASC, Authorisation__c ASC]) {
              
                targetPaymentRecords.add(tempOrder);                    
    }
    
    for(Order tempOrder : [SELECT Id, OrderNumber, Authorisation__c, Authorisation__r.Name, Order_Type_From_Application__c,
                                    TotalAmount, Status, EffectiveDate, Payment_Reference__c,
                                    Application_Sub_Type__c, Application__c
                                    FROM Order
                                    WHERE Authorisation__c != NULL
                                    AND Authorisation__c IN :fullAccessAuths
                                    AND Application__c != NULL
                                    AND Application_Type__c = :GlobalConstants.TAXI_CASE_TYPE
                                    AND AccountId = :requiredAccId
                                    AND ((Status =: GlobalConstants.PAYMENT_DUE_STATUS AND Payment_Method__c !=: GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT) OR Status =: GlobalConstants.PAYMENT_REJECTED_STATUS)
                                    ORDER BY STATUS DESC, EffectiveDate ASC, Authorisation__c ASC]) {
              
                targetPaymentRecords.add(tempOrder);                    
    }
    
    return targetPaymentRecords;
  }
  
  public static List<Order> getPaidPaymentsDataForAgents(String requiredAccId, List<Authorisation__c> accessibleLicences) {
    
    List<Authorisation__c> fullAccessAuths = new List<Authorisation__c>();
    List<Authorisation__c> transferOnlyAccessAuths = new List<Authorisation__c>();
    List<Order> targetPaymentRecords = new List<Order>();
    
    for(Authorisation__c tempAuth : accessibleLicences) {
       
      if(tempAuth.Agreement_Type__c == GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE_FULL_ACCESS)
         fullAccessAuths.add(tempAuth);
      
      if(tempAuth.Agreement_Type__c == GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE)
         transferOnlyAccessAuths.add(tempAuth);
    } 
    
    for(Order tempOrder : [SELECT Id, OrderNumber, Authorisation__c, Authorisation__r.Name, Order_Type_From_Application__c,
                                    TotalAmount, Status, Received_Date__c, Payment_Reference__c
                                    FROM Order
                                    WHERE Authorisation__c != NULL
                                    AND Authorisation__c IN :transferOnlyAccessAuths
                                    AND Application__c != NULL
                                    AND Application_Type__c =: GlobalConstants.TAXI_CASE_TYPE
                                    AND Application_Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER
                                    AND AccountId = :requiredAccId 
                                    AND Status =: GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS
                                    ORDER BY EffectiveDate ASC, Authorisation__c ASC]) {
        
        targetPaymentRecords.add(tempOrder);                                
    }
    
    for(Order tempOrder : [SELECT Id, OrderNumber, Authorisation__c, Authorisation__r.Name, Order_Type_From_Application__c,
                                    TotalAmount, Status, Received_Date__c, Payment_Reference__c
                                    FROM Order
                                    WHERE Authorisation__c != NULL
                                    AND Authorisation__c IN :fullAccessAuths
                                    AND Application__c != NULL
                                    AND Application_Type__c =: GlobalConstants.TAXI_CASE_TYPE
                                    AND AccountId = :requiredAccId 
                                    AND Status =: GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS
                                    ORDER BY EffectiveDate ASC, Authorisation__c ASC]) {
        
        targetPaymentRecords.add(tempOrder);                                
    }
    
    return targetPaymentRecords;
  }
  
  public static Map<Id, Order> getAgentsPaymentsMap(String requestedAccId) {
    
    Map<Id, Order> tempPaymentMap = new Map<Id, Order>();
        
    for(Order tempOrder : [SELECT Authorisation__c, Authorisation__r.Agreement_Type__c,
                                      Authorisation__r.Agency__c
                                      FROM Order
                                      WHERE AccountId = :requestedAccId]) {
          
      tempPaymentMap.put(tempOrder.Id, tempOrder);
    }
        
    return tempPaymentMap;
  }
  
  public static String getAccountPartnersForAgents(String requestedAccId) {
    
    List<Contact> individualPartners = [SELECT Id, Name, Phone, Email, Contact_Type__c  FROM Contact 
                                               WHERE Contact_Type__c = :GlobalConstants.CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE 
                                               AND Account.Id = :requestedAccId
                                               ORDER BY CreatedDate ASC];
            
    List<Account> corporatePartners = [SELECT Id, Name, Phone, Notice_Email__c FROM Account 
                                                WHERE Corporate_Partner__c = :requestedAccId
                                                ORDER BY CreatedDate ASC];
            
    List<Object> allPartners = new List<Object>();
    for(Contact individualPartner : individualPartners) {
      
      allPartners.add(individualPartner);
    }
    for(Account corporatePartner : corporatePartners) {
      
      allPartners.add(corporatePartner);
    }
            
    String result = JSON.serialize(allPartners);
    System.debug(result);
                
    return result;  
  }
    
    public static String createSurrenderCaseForTaxiAgent(String authId) {
        
        try{
        
            System.debug('In TaxiAgentDateAccessProvider');
            Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            
            Authorisation__c taxiAuth = [SELECT Id,Status__c, Contact__c,Service_Provider__c, Authorisation_Type__c,Request_Type__c, Licence_Class__c,Paired_License__c FROM Authorisation__c
                                         WHERE Id = :authId];
            
            System.debug('Authorisation: '+taxiAuth);
            
            //Create Surrender case with Authorisation Id
            Case newTaxiSurrenderCase = new Case();
            newTaxiSurrenderCase.Status = GlobalConstants.LODGED_CASE_STATUS;
            newTaxiSurrenderCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
            newTaxiSurrenderCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            newTaxiSurrenderCase.Sub_Type__c = GlobalConstants.SURRENDER_CASE_SUB_TYPE;
            newTaxiSurrenderCase.Subject = 'Surrender of Taxi license';
            newTaxiSurrenderCase.Description = 'Surrender of Taxi license';
            newTaxiSurrenderCase.AccountId = taxiAuth.Service_Provider__c;
            newTaxiSurrenderCase.ContactId = taxiAuth.Contact__c;
            newTaxiSurrenderCase.Authorisation__c = taxiAuth.Id;
           // newTaxiSurrenderCase.Confirmation_of_plates_returned__c = Boolean.valueOf(plates_returned);
            newTaxiSurrenderCase.Origin = GlobalConstants.CASE_ORIGIN_INDUSTRY_PORTAL;
            newTaxiSurrenderCase.RecordTypeId = taxiLicenseAdministrationRecordTypeId;
            newTaxiSurrenderCase.OwnerId = [Select Id, Type, Name from Group where Name = 'Taxi Support Level 3'].Id;
            newTaxiSurrenderCase.Agent__c = GlobalUtility.getLoggedInUser().AccountId;
            
            System.debug('RecordTypeId: ' + taxiLicenseAdministrationRecordTypeId);
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = FALSE;
            dmo.EmailHeader.triggerUserEmail = true;
            newTaxiSurrenderCase.setOptions(dmo);
            
            //Create Suspension Case with case assignment rule and email notification enabled.
            Database.SaveResult srList = Database.insert(newTaxiSurrenderCase, dmo);
            System.debug('DB saveresults: '+srList);
            
            taxiAuth.Request_Type__c = GlobalConstants.RETURN_REQUEST_TYPE;
            update taxiAuth;
            
            String surrenderCaseId = newTaxiSurrenderCase.Id;
            Case surrenderCase = [SELECT id, CaseNumber from Case where id=:surrenderCaseId];
            String surrenderCaseNumber = surrenderCase.CaseNumber;
            return surrenderCaseNumber;
            
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiAgentDataAccessProvider','createSurrenderCaseForTaxiAgent',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
    
    /* This function retrives the List of Applications related to required account 
     * sorted by descending order in string format for agents. 
     */
    public static String getApplicationCasesForAgent(String requiredAccId) {
        
        Id rtIdforTaxiIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        Id rtIdforTaxiCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
        Id rtIdforTaxiJointHolder = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_JOINT_HOLDER_APPLICATION).getRecordTypeId();
        Id rtIdforTransfer = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Id rtIdforTaxiLicenceAdminsitration = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Set<Id> fullAccessLicences = new Set<Id>();
        Set<Id> transferOnlyAccessLicences = new Set<Id>();
        
        List<Authorisation__c> accessibleAuthorisations = GlobalUtility.getAgentAccessibleAuthorisations(requiredAccId);
        
        for(Authorisation__c tempLicences : accessibleAuthorisations) {
             
             if(tempLicences.Agreement_Type__c == GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE_FULL_ACCESS)
                fullAccessLicences.add(tempLicences.Id);
             else if(tempLicences.Agreement_Type__c == GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE)
                transferOnlyAccessLicences.add(tempLicences.Id);                                             
        }
        System.debug('fullAccessLicences'+fullAccessLicences);
              
        List<Case> allCasesToReturn = new List<Case>();
        
        List<Case> fullAccessCasesList = [SELECT Id, AccountId, Authorisation__c, Account.Name, CaseNumber, Service_Type__c, 
                                           Status, CreatedBy.Name, LastModifiedDate, Contact.Name, RecordType.Name,
                                           Is_WAT_Application__c, Sub_Status__c, Sub_Type__c, IsClosed, Date_Submitted__c,CreatedDate,
                                           (SELECT Id, Status FROM Orders__r), (SELECT Name, Agency__c, Agreement_Type__c FROM Authorisations__r)
                                           FROM Case 
                                           WHERE AccountId = :requiredAccId
                                           AND (((RecordTypeId = :rtIdforTaxiIndividual 
                                                  OR RecordTypeId = :rtIdforTaxiCorporation
                                                  OR RecordTypeId = :rtIdforTaxiJointHolder) AND Status = :GlobalConstants.CLOSED_CASE_STATUS)
                                                 OR RecordTypeId = :rtIdforTransfer
                                                 OR RecordTypeId = :rtIdforTaxiLicenceAdminsitration
                                                 OR (Type = :GlobalConstants.TAXI_CASE_TYPE 
                                                     AND (Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER 
                                                           OR Sub_Type__c = :GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION
                                                           OR Sub_Type__c = :GlobalConstants.SURRENDER_CASE_SUB_TYPE)))
                                          AND (Status = :GlobalConstants.CASE_DRAFT
                                               OR Status = :GlobalConstants.APPLICATION_STATUS_LODGED
                                               OR (Status = :GlobalConstants.CASE_NEW AND Origin = :GlobalConstants.CASE_ORIGIN_INDUSTRY_PORTAL))
                                          ORDER BY CreatedDate 
                                          DESC];
        System.debug('Case here:'+fullAccessCasesList);                                  
        for(Case tempFullAccessCase : fullAccessCasesList) {
           
           for(Authorisation__c tempAuth : tempFullAccessCase.Authorisations__r) {
              
              if(fullAccessLicences.contains(tempAuth.Id))
               allCasesToReturn.add(tempFullAccessCase);
           }
           
           if(fullAccessLicences.contains(tempFullAccessCase.Authorisation__c) && !allCasesToReturn.contains(tempFullAccessCase))
             allCasesToReturn.add(tempFullAccessCase);
        }
        
        List<Case> transferOnlyAccessCasesList = [SELECT Id, AccountId, Authorisation__c, Account.Name, CaseNumber, Service_Type__c, 
                                                   Status, CreatedBy.Name, LastModifiedDate, Contact.Name, RecordType.Name,
                                                   Is_WAT_Application__c, Sub_Status__c, Sub_Type__c, IsClosed, Date_Submitted__c,CreatedDate,
                                                   (SELECT Id, Status FROM Orders__r), (SELECT Name, Agency__c, Agreement_Type__c FROM Authorisations__r)
                                                    FROM Case 
                                                    WHERE AccountId = :requiredAccId
                                                    AND (RecordTypeId = :rtIdforTransfer
                                                          OR RecordTypeId = :rtIdforTaxiLicenceAdminsitration
                                                          OR (Type = :GlobalConstants.TAXI_CASE_TYPE 
                                                              AND Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER))
                                                    AND (Status = :GlobalConstants.CASE_DRAFT
                                                          OR Status = :GlobalConstants.APPLICATION_STATUS_LODGED
                                                          OR (Status = :GlobalConstants.CASE_NEW AND Origin = :GlobalConstants.CASE_ORIGIN_INDUSTRY_PORTAL))
                                                    ORDER BY CreatedDate 
                                                    DESC];
        
        for(Case tempTrasferOnlyAccessCase : transferOnlyAccessCasesList) {
           
           for(Authorisation__c tempAuth : tempTrasferOnlyAccessCase.Authorisations__r) {
              
              if(transferOnlyAccessLicences.contains(tempAuth.Id))
               allCasesToReturn.add(tempTrasferOnlyAccessCase);
           }
           
           if(transferOnlyAccessLicences.contains(tempTrasferOnlyAccessCase.Authorisation__c) && !allCasesToReturn.contains(tempTrasferOnlyAccessCase))
             allCasesToReturn.add(tempTrasferOnlyAccessCase);
        }
                                     
        return JSON.serialize(allCasesToReturn);
    }
    
    
    public static String cancelTaxiApplication(Case caseRec) {
      
      try {
            
            System.debug(LoggingLevel.INFO, 'Case Details: ' + caseRec);
            User userRecord = GlobalUtility.getLoggedInUser();
            caseRec.Decision_Made_By__c = userRecord.Id;
            update caseRec;
            caseRec = [SELECT Id, AccountId, Authorisation__c, Status, Sub_Type__c  FROM Case WHERE Id = :caseRec.Id];
            
            if(GlobalUtility.agentHasAccountFullAccess(caseRec.AccountId) == FALSE)
               return GlobalConstants.UNAUTHORISED_ACCESS;
        
            
            List<Authorisation__c> authRecordsToUpdate = new List<Authorisation__c>();
            if(caseRec.Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION){
                for(Authorisation__c authRecord :[SELECT Id, Decision_Reason__c, Decision_Date__c, Decision_Made_By__c  FROM Authorisation__c WHERE Id  =: caseRec.Authorisation__c]){
                    authRecord.Status__c= GlobalCOnstants.AUTHORISATION_STATUS_DISCARDED;
                    authRecord.Decision_Reason__c = GlobalConstants.TAXI_APP_CANCELLED_DECISION_REASON;
                    authRecord.Decision_Date__c = system.today();
                    authRecord.Decision_Made_By__c =userRecord.id;
                    authRecordsToUpdate.add(authRecord);
                    
                }    
            }
            else{
                
                for(Authorisation__c authRecord :[SELECT Id, Decision_Reason__c, Decision_Date__c, Decision_Made_By__c  FROM Authorisation__c WHERE Application__c =: caseRec.Id]){
                    if(!Approval.isLocked(authRecord.Id)){
                        authRecord.Status__c= GlobalCOnstants.AUTHORISATION_STATUS_DISCARDED;
                        authRecord.Decision_Reason__c = GlobalConstants.TAXI_APP_CANCELLED_DECISION_REASON;
                        authRecord.Decision_Date__c = system.today();
                        authRecord.Decision_Made_By__c =userRecord.id;
                        authRecordsToUpdate.add(authRecord);
                    } 
                }    
            }
            
            update authRecordsToUpdate;
            
            return GlobalConstants.SUCCESS_MESSAGE_TO_BE_RETURNED;
            
        }catch (Exception ex) {
            system.debug('Exception: '+ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiManageAccountCases','cancelTaxiApplication',ex.getMessage(),ex);
            return null;        
        }  
    }
}