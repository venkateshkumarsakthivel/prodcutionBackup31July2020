public without sharing class TaxiTransferController {
    
    //Method returns json of authorisation Record which is selected by logged in user for transfer.
    @AuraEnabled
    public static Authorisation__c getAuthorisationRecord(String authorisationId) {
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser(); 
            
            Authorisation__c authorisationRecord = [SELECT Id, Name, Service_Provider__c,  End_Date__c, Licence_Class__c, Operation_Area__c, Term__c, Status__c
                                                    FROM Authorisation__c 
                                                    WHERE Id=: authorisationId];
            
            return authorisationRecord;
        }
        catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiTransferController', 'getAuthorisationRecord', e.getMessage(), e);
            return NULL;
        }
    }
    
    //Method returns seller case record for existing open taxi transfer application.
    @AuraEnabled
    public static String getTaxiTransferApplicationDetails(String caseId) {
        
        try {
            
            Case caseRecord = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c, Authorisation__c,Information_Declaration__c,
                               Transfer_Reason__c, Licence_Fee_Due__c, Beneficiary_Type__c, Is_Privacy_Statement_Declared__c 
                               FROM Case Where Id=: caseId];
            return JSON.serialize(caseRecord); 
            
        }
        catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiTransferController', 'getTaxiTransferApplicationDetails', e.getMessage(), e);
            return NULL;
        }
    }
    
    //Method returns buyer case record for existing open taxi transfer application.
    @AuraEnabled
    public static String getLicenceMarketValueAndLevyDueTaxiTransfer(String sellerCaseId) {
        
        try {
            
            Case buyerCase = [SELECT Id, Licence_Market_Value__c, Levy_Due__c, Proof_of_Sale_or_Will_or_Death__c 
                              FROM Case WHERE ParentId =: sellerCaseId];
            return JSON.serialize(buyerCase); 
            
        }
        catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiTransferController', 'getTaxiTransferApplicationDetails', e.getMessage(), e);
            return NULL;
        }
    }
    
    //Method returns related contacts from seller case record for existing open taxi transfer application.
    @AuraEnabled
    public static String getRelatedContactsData(String caseId, String buyerType) {
        
        Related_Contact__c contact ;
        
        if(buyerType =='Individual') {
            contact =  [SELECT Id, Title__c, First_Given_Name__c, Family_Name__c, Other_Given_Name__c, 
                        Date_of_Birth__c, Australian_Driver_Licence__c, Australian_Driver_Licence_State__c,
                        Contact_Type__c, Daytime_Phone__c, Email__c 
                        FROM Related_Contact__c WHERE Related_Application__c =: caseId];   
            return JSON.serialize(contact);
        }
        
        if(buyerType =='Corporation') {
            contact =  [SELECT Id, Corporation_Name__c,ACN__c,Daytime_Phone__c, Email__c 
                        FROM Related_Contact__c WHERE Related_Application__c =: caseId];   
            return JSON.serialize(contact);
        }
        
        if(buyerType == 'Joint-Holders') {
            List<Related_Contact__c> contacts =  [SELECT Id, Corporation_Name__c,ACN__c, Title__c, First_Given_Name__c, Family_Name__c, Other_Given_Name__c, 
                                                  Date_of_Birth__c, Australian_Driver_Licence__c, Australian_Driver_Licence_State__c,
                                                  Contact_Type__c, Daytime_Phone__c, Email__c 
                                                  FROM Related_Contact__c WHERE Related_Application__c =: caseId];       
            return JSON.serialize(contacts);
        }
        
        return null;        
    }
    
    // Method to save Taxi Trasfer Application Data
    // Seller Case along with Related Contacts, Buyer Case And Clone of Existing Authorisation
    @AuraEnabled
    public static String saveLicenceTransferData(String sellerCaseRecord, String buyerCaseRecord, String buyerType, String individualPartnerData, String corporatePartnerData, String individualPartnersData, String corporatePartnersData, String authId) {
        
        try {
            
            System.debug('TaxiTransferController saveLicenceTransferData');
            
            Id individualRelatedContactRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName()
                .get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            
            Id corporateRelatedContactRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName()
                .get(GlobalConstants.CORPORATE_RECORD_TYPE).getRecordTypeId();
            
            Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Case sellerCase = (Case)JSON.deserialize(sellerCaseRecord, Case.class);
            Case buyerCase = (Case)JSON.deserialize(buyerCaseRecord, Case.class);
            
            Community_Account_Contact_Owner__mdt applicationOwner = [SELECT Id, Owner_Id__c FROM Community_Account_Contact_Owner__mdt 
                                                                     WHERE DeveloperName = :GlobalConstants.DEFAULT_OWNER];
            
            boolean isUpdateRecords = false;
            
            if(sellerCase.Id != null) {
                
                isUpdateRecords = true;
                Case existingSellerCase = [SELECT Id, Beneficiary_Type__c FROM Case WHERE Id = :sellerCase.Id];
                if(existingSellerCase.Beneficiary_Type__c != buyerType){
                    delete [SELECT Id FROM Related_Contact__c WHERE Related_Application__c = :sellerCase.Id];
                }
            }
            
            User loggedInUser = [SELECT User_Profile_Name__c, AccountId FROM User Where Id = :UserInfo.getUserId()];
            Boolean isAgent = FALSE;
            if(loggedInUser.User_Profile_Name__c == GlobalConstants.TAXI_AGENT_USERS_PROFILE_NAME)
               isAgent = TRUE;
            
            //Insert Seller Case Record
            sellerCase.RecordTypeId = transferRecordTypeId;
            sellerCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            sellerCase.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER;
            sellerCase.Subject = GlobalConstants.CASE_SUBJECT_TRANSFER_OWNER; 
            sellerCase.Description = GlobalConstants.CASE_SUBJECT_TRANSFER_OWNER;
            sellerCase.OwnerId = [Select Id, Type, Name from Group where Name =: GlobalConstants.TAXI_SUPPORT_LEVEL_1_QUEUE].Id;
            
            sellerCase.Agent__c = isAgent ? loggedInUser.AccountId : NULL;
            Authorisation__c relatedAuth = [SELECT Service_Provider__c, Contact__c FROM Authorisation__c  WHERE Id = :authId];
            if(isAgent) {
              
              sellerCase.AccountId = relatedAuth.Service_Provider__c;
              sellerCase.ContactId = relatedAuth.Contact__c;
            }
            
            upsert sellerCase;
            
            Id buyerCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            // Upsert Buyer Case Record
            // Get buyerCase id if parentId is not null
            if(isUpdateRecords) {
                Case existingBuyerCase = [SELECT Id FROM Case WHERE ParentId =: sellerCase.Id];
                buyerCase.Id = existingBuyerCase.Id;
            }
            
            buyerCase.RecordTypeId = buyerCaseRecordTypeId;
            buyerCase.ParentId = sellerCase.Id;
            buyerCase.AccountId = null;
            buyerCase.ContactId = null;
            buyerCase.OwnerId = applicationOwner.Owner_Id__c;
            buyerCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            buyerCase.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER ;
            buyerCase.Subject = GlobalConstants.CASE_SUBJECT_TRANSFER_PROPOSED_OWNER ;
            buyerCase.Description = GlobalConstants.CASE_SUBJECT_TRANSFER_PROPOSED_OWNER ;
            buyerCase.Transfer_Reason__c = sellerCase.Transfer_Reason__c;
            buyerCase.Licence_Fee_Due__c = sellerCase.Licence_Fee_Due__c;
            // Modified on 15 Nov 2019 : P2PSUPPORT-255 : Expected Transfer process
            //buyerCase.Agent__c = isAgent ? loggedInUser.AccountId : NULL;
            upsert buyerCase;
            
            System.debug('[TaxiTransferController Seller Case Id : ] : ' + sellerCase.Id);
            System.debug('[TaxiTransferController Buyer Case Id : ] : ' + buyerCase.Id);            
            
            Related_Contact__c buyerRelatedContact;
            
            // Related contacts will get upserted as they have id field populated
            if(buyerType == 'Individual') {
                
                Related_Contact__c individualPartner = (Related_Contact__c)JSON.deserialize(individualPartnerData, Related_Contact__c.class);
                individualPartner.RecordTypeId = individualRelatedContactRecordTypeId;
                individualPartner.Related_Application__c = sellerCase.Id;
                
                upsert individualPartner;
                
                buyerRelatedContact = individualPartner;
                
                System.debug('[individualPartner] : ' + individualPartner);
            }
            else if(buyerType == 'Corporation') {
                
                Related_Contact__c corporatePartner = (Related_Contact__c)JSON.deserialize(corporatePartnerData, Related_Contact__c.class);
                corporatePartner.RecordTypeId = corporateRelatedContactRecordTypeId;
                corporatePartner.Related_Application__c = sellerCase.Id;
                
                upsert corporatePartner;
                
                buyerRelatedContact = corporatePartner;
                
                System.debug('[corporatePartner] : ' + corporatePartner);
            }
            else if(buyerType == 'Joint-Holders'){
                
                List<Related_Contact__c> individualPartners = (List<Related_Contact__c>)JSON.deserialize(individualPartnersData, List<Related_Contact__c>.class);
                List<Related_Contact__c> corporatePartners = (List<Related_Contact__c>)JSON.deserialize(corporatePartnersData, List<Related_Contact__c>.class);
                
                for(Related_Contact__c individualPartner : individualPartners) {
                    
                    individualPartner.RecordTypeId = individualRelatedContactRecordTypeId;
                    individualPartner.Related_Application__c = sellerCase.Id;
                    buyerRelatedContact = individualPartner;
                }
                
                for(Related_Contact__c corporatePartner : corporatePartners) {
                    
                    corporatePartner.RecordTypeId = corporateRelatedContactRecordTypeId;
                    corporatePartner.Related_Application__c = sellerCase.Id;
                    buyerRelatedContact = corporatePartner;
                }
                
                if(individualPartners.size() > 0)
                    upsert individualPartners;
                
                if(corporatePartners.size() > 0)
                    upsert corporatePartners;
                
                System.debug('[individualPartners] : ' + individualPartners);
                System.debug('[corporatePartners] : ' + corporatePartners);
            }
            
            if(buyerRelatedContact != NULL) {
                
                buyerCase.Buyer_Daytime_Phone__c = buyerRelatedContact.Daytime_Phone__c;
                buyerCase.Buyer_Email__c = buyerRelatedContact.Email__c;
                
                update buyerCase;
            }
            
            return sellerCase.Id;
            
        }
        catch(Exception e) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiTransferController', 'saveLicenceTransferData', e.getMessage(), e);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static String saveTransferPrivacyStatement(String sellerCaseRecord) {
        
        try {
            
            Case sellerCase = (Case)JSON.deserialize(sellerCaseRecord, Case.class);
            upsert sellerCase;
            return JSON.serialize(sellerCase);
            
        } catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiTransferController', 'saveTransferPrivacyStatement', e.getMessage(), e);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static String updateSellerAndBuyerCase(String sellerCaseRecord) {
        
        try {            
            Case sellerCase = (Case)JSON.deserialize(sellerCaseRecord, Case.class);
            sellerCase.Status = GlobalConstants.LODGED_CASE_STATUS;
            sellerCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
            sellerCase.Date_Submitted__c = System.today();
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            Database.update(sellerCase, dmo);            
            
            return 'Success';
            
        } catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiTransferController', 'updateSellerAndBuyerCase', e.getMessage(), e);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static boolean isExistingTransferApplicationOpen(String authorisationId) {
        
        try {
            
            Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            List<Case> casesList = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c, 
                                    Transfer_Reason__c, Licence_Fee_Due__c, Beneficiary_Type__c, Is_Privacy_Statement_Declared__c
                                    FROM Case 
                                    WHERE IsClosed = false 
                                    AND RecordTypeId =: transferRecordTypeId 
                                    AND Type =: GlobalConstants.SERVICE_TYPE_TAXI
                                    AND Sub_Type__c =: GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER
                                    AND Authorisation__c =: authorisationId];
            
            return !casesList.isEmpty();
        }
        catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiManageAccountLicences', 'isExistingTransferApplicationOpen', e.getMessage(), e);
            return null;
        }
    }
    
    @AuraEnabled
    public static void createAttachments(List<String> attachIds, String applicationId){
        List<Attachment> attachments = [Select ParentId, Name, Id, Description, Body 
                                        FROM Attachment WHERE Id IN :attachIds];
        List<Attachment> newAttachments = new List<Attachment>();
        
        for(Attachment attach : attachments){
            Attachment file = new Attachment();
            file.ParentId = applicationId;
            file.Name = attach.Name;
            file.Description = attach.Description;
            file.Body = attach.Body;
            
            newAttachments.add(file);        
        }
        insert newAttachments;
        
        GlobalUtility.ALLOW_FILE_DELETE = true;
        delete attachments;
    }
    
}