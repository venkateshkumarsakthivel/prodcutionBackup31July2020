/**
 * Helper class for server side rest resource LevyFormSectionDataController
*/
public without sharing class LevyFormSectionDataHelper {
    
    /* Helper method to create Case for Exemption and Rebate 
     * Assumes that registration has requested for excemption or rebate
    */
    public static Case createCaseExemptionandRebate(Tax_Payer_Registration__c levyRegistrationRec) {
        
        Case caseRec = new Case();
        Id levyAdministrationcCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Group aspLevel2Queue = [SELECT Id, DeveloperName, Type FROM Group where Type = :GlobalConstants.QUEUE And DeveloperName = :GlobalConstants.ASP_LEVEL_2_QUEUE_DEV_NAME limit 1];
        
        if(levyRegistrationRec.Applied_For_Exemption__c == 'Yes') {
        
            caseRec.Sub_Type__c = GlobalConstants.Levy_Exemption_Case_SUB_TYPE;
            caseRec.Subject = GlobalConstants.Levy_Exemption_Subject;
            caseRec.Description = levyRegistrationRec.Exemption_Comment__c;  
       }
       
       if(levyRegistrationRec.Applied_For_Rebate__c == 'Yes') {
       
            caseRec.Sub_Type__c = GlobalConstants.Levy_Rebate_Case_SUB_TYPE;
            caseRec.Subject = GlobalConstants.Levy_Rebate_Subject;
            caseRec.Description = levyRegistrationRec.Rebate_Comment__c;         
       }
       
       caseRec.OwnerId = aspLevel2Queue.Id;
       caseRec.Type = GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY;
       caseRec.AccountId = levyRegistrationRec.Service_Provider_Name__c;
       caseRec.ContactId = levyRegistrationRec.Levy_Contact__c;
       caseRec.Tax_Payer_Registration__c = levyRegistrationRec.Id;
       caseRec.RecordTypeId = levyAdministrationcCaseRecordTypeId;
       caseRec.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
       caseRec.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING;
       caseRec.Date_Submitted__c = System.Today();
       
       User user = GlobalUtility.getLoggedInUser();
       if(String.isNotBlank(user.ContactId))
         caseRec.Registration_Contact__c = user.ContactId;
       
       Database.DMLOptions dmo = new Database.DMLOptions();
       dmo.assignmentRuleHeader.useDefaultRule = TRUE;
       caseRec.setOptions(dmo);
       insert caseRec;
       
       return caseRec;
    }
    
    /* helper method to process registration submission and perform pre and post submission actions */
   public static String processRegistrationSubmission(String registrationData) {
     
     try {
        
            User loggedInUser = GlobalUtility.getLoggedInUser();    
            
            System.debug('Registeration record to submit: '+registrationData);
            
            Tax_Payer_Registration__c levyRegistrationRecToSave = (Tax_Payer_Registration__c)JSON.deserialize(registrationData, Tax_Payer_Registration__c.class);
            
            System.debug('Registeration record to submit: '+levyRegistrationRecToSave);
            
            if(String.isBlank(levyRegistrationRecToSave.Id)) {
            
                //if applying for rebate/excemption
            if(levyRegistrationRecToSave.Applied_For_Exemption__c == GlobalConstants.YES_VALUE
                || levyRegistrationRecToSave.Applied_For_Rebate__c == GlobalConstants.YES_VALUE)
              levyRegistrationRecToSave.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_P2P;
            
            //if not applying for rebate/excemption
            if(levyRegistrationRecToSave.Applied_For_Rebate__c == GlobalConstants.NO_VALUE
                || levyRegistrationRecToSave.Applied_For_Exemption__c == GlobalConstants.NO_VALUE
                || levyRegistrationRecToSave.Annual_Trip_Estimate__c == GlobalConstants.TRIP_OVER_600)
              levyRegistrationRecToSave.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_RNSW;
            
            //if applied foe exemption, update Revenue NSW status as N/A, else Pending
            if(levyRegistrationRecToSave.Applied_For_Exemption__c == GlobalConstants.YES_VALUE) 
             levyRegistrationRecToSave.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
            else
             levyRegistrationRecToSave.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
            
             /* query all existing active registration records and mark them as superseded */
             List<Tax_Payer_Registration__c> existingRegistrationRecords = [SELECT Status__c, Sub_Status__c
                                                                           FROM Tax_Payer_Registration__c
                                                                           WHERE Service_Provider_Name__c = :levyRegistrationRecToSave.Service_Provider_Name__c
                                                                           AND Status__c = :GlobalConstants.STATUS_ACTIVE];
            
             List<Tax_Payer_Registration__c> existingRegistrationRecordsToUpdate = new List<Tax_Payer_Registration__c>();
                                                                          
             for(Tax_Payer_Registration__c tempExistingRegistrationRecord : existingRegistrationRecords) {
            
               tempExistingRegistrationRecord.Status__c = GlobalConstants.STATUS_SUPERSEDED;
               existingRegistrationRecordsToUpdate.add(tempExistingRegistrationRecord);
             }
            
             if(existingRegistrationRecordsToUpdate.size() > 0)
              DataBase.update(existingRegistrationRecordsToUpdate, FALSE);     
            }
            
            levyRegistrationRecToSave.Status__c = GlobalConstants.STATUS_ACTIVE;
               
            //validates if specified registration record is pending with OSR, if yes then update existing record
            //else supersede cloned record and update existing registration for bank detail updation
            if((!String.isBlank(levyRegistrationRecToSave.Id)) && (!GlobalUtility.checkIfWithOSR(levyRegistrationRecToSave))) {
        
               System.debug('Not with OSR');
            
               Tax_Payer_Registration__c clonedRegistrationRecord = GlobalUtility.cloneRegistrationRecord(levyRegistrationRecToSave);
               clonedRegistrationRecord = clonedRegistrationRecord.clone(false, true, false, false);
               clonedRegistrationRecord.Levy_Notification_Address_Country__c = levyRegistrationRecToSave.Levy_Notification_Address_Country__c;
            
               //marking clonned registration record as superseded
               clonedRegistrationRecord.Status__c = GlobalConstants.STATUS_SUPERSEDED;
               insert clonedRegistrationRecord; 
               
               //if service provider is exmepted from levy
               if(levyRegistrationRecToSave.Exemption_Approved__c && levyRegistrationRecToSave.Annual_Trip_Estimate__c == Label.Levy_Trip_Estimate_Less_Than_150_Value)
                levyRegistrationRecToSave.Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED;
               else if(levyRegistrationRecToSave.Applied_For_Exemption__c == GlobalConstants.YES_VALUE 
                        || levyRegistrationRecToSave.Applied_For_Rebate__c == GlobalConstants.YES_VALUE)
                levyRegistrationRecToSave.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_P2P;
            /*   else
                levyRegistrationRecToSave.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_RNSW;
               
               if(String.isNotBlank(levyRegistrationRecToSave.RNSWCustomerId__c))
                levyRegistrationRecToSave.IsAuthorisationUpdate__c = TRUE; */
            }           
            
            Account registrationAccount = [SELECT OwnerId FROM Account WHERE Id = :levyRegistrationRecToSave.Service_Provider_Name__c];
            levyRegistrationRecToSave.OwnerId = registrationAccount.OwnerId;
            
            //if existing contact is chosen as levy contact person, stamp contact person details on the record
            if(levyRegistrationRecToSave.Levy_Contact__c != NULL) {
              
              Contact existingLevyContact = [SELECT FirstName, LastName, Email, Phone, Levy_Contact_Phone__c
                                             FROM Contact
                                             WHERE Id = :levyRegistrationRecToSave.Levy_Contact__c];
                                             
              
              levyRegistrationRecToSave.Levy_Contact_First_Name__c = existingLevyContact.FirstName;
              levyRegistrationRecToSave.Levy_Contact_Last_Name__c = existingLevyContact.LastName;
              levyRegistrationRecToSave.Levy_Contact_Email__c = existingLevyContact.Email;
              levyRegistrationRecToSave.Levy_Contact_Phone__c = existingLevyContact.Levy_Contact_Phone__c;
            }
            
            
            System.debug('Registeration record to submit: '+levyRegistrationRecToSave);
            
            levyRegistrationRecToSave.Date_Registered__c = DateTime.Now();
            levyRegistrationRecToSave.Date_Sent_to_Revenue__c = null;
            
            User user = GlobalUtility.getLoggedInUser();
            if(String.isNotBlank(user.ContactId))
               levyRegistrationRecToSave.Registration_Contact__c = user.ContactId;
            
            Contact levyContact = new Contact();
            
            //if existing contact is chosen as levy contact person, use its id for upsert
            if(levyRegistrationRecToSave.Levy_Contact__c != NULL)
              levyContact.Id = levyRegistrationRecToSave.Levy_Contact__c;
            else {
            
              levyContact.AccountId = levyRegistrationRecToSave.Service_Provider_Name__c;
              levyContact.FirstName = levyRegistrationRecToSave.Levy_Contact_First_Name__c;
              levyContact.LastName = levyRegistrationRecToSave.Levy_Contact_Last_Name__c;
              levyContact.Email = levyRegistrationRecToSave.Levy_Contact_Email__c;
              levyContact.Phone = levyRegistrationRecToSave.Levy_Contact_Phone__c;
            }
            
            levyContact.Is_Access_Level_Levy_Administrator__c = levyRegistrationRecToSave.Person_Enters_Returns_for_Levy__c == GlobalConstants.YES_VALUE ? TRUE : FALSE; 
            levyContact.OwnerId = registrationAccount.OwnerId;
            
            upsert levyContact;
            
            //tagging the related levy contact to registrtion record
            levyRegistrationRecToSave.Levy_Contact__c = levyContact.Id;
            
            upsert levyRegistrationRecToSave;
            
            //create exemption/rebate case if applying for an exemption or rebate
            //and previous exemption/rebate request is not approved
            if((levyRegistrationRecToSave.Applied_For_Exemption__c == GlobalConstants.YES_VALUE
                 && levyRegistrationRecToSave.Exemption_Approved__c == FALSE)
                || (levyRegistrationRecToSave.Applied_For_Rebate__c == GlobalConstants.YES_VALUE
                     && levyRegistrationRecToSave.Rebate_Approved__c == FALSE)) {
                     
               Case exemptionRebateCase = createCaseExemptionandRebate(levyRegistrationRecToSave);
               
               //reset exemption/rebate approval flags
               levyRegistrationRecToSave.Exemption_Approved__c = FALSE;
               levyRegistrationRecToSave.Exemption_Approval_Date__c = NULL;
               levyRegistrationRecToSave.Rebate_Approved__c = FALSE;
               levyRegistrationRecToSave.Rebate_Approval_Date__c = NULL;
               
               //tagging recent exemption/rebate case to registration record
               levyRegistrationRecToSave.Current_Support_Request__c = exemptionRebateCase.Id;
               
               
               /* Fetching list of attachments related to registration, which are tagged against the account 
                * and tagging them against the newly created exemption/rebate case record.
                */
               List<Attachment> attachments = [Select ParentId, Name, Id, Description, Body 
                                            FROM Attachment 
                                            WHERE ParentId = :levyRegistrationRecToSave.Service_Provider_Name__c
                                            AND Name LIKE 'TPR-%'];
                                            
               List<Attachment> newAttachments = new List<Attachment>();
        
               for(Attachment attach : attachments){
            
                Attachment file = new Attachment();
                file.ParentId = exemptionRebateCase.Id;
                file.Name = attach.Name;
                file.Description = attach.Description;
                file.Body = attach.Body;
            
                newAttachments.add(file);        
               }
            
               insert newAttachments;
        
               GlobalUtility.ALLOW_FILE_DELETE = true;
               delete attachments;           
            }
            
            update levyRegistrationRecToSave;
            
            //calling utility method to check and provide levy contact access to portal for accessing Levy stuff
            ManageAccountUsers.updateUser(new List<Id>{levyContact.Id});
            
            System.debug('Levy Granted User Creation Triggered !!');
            
            return levyRegistrationRecToSave.Id;
     }
     catch(Exception e) {
            
       System.debug('Exception: '+e.getLineNumber());
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevyFormSectionDataHelper', 'processRegistrationSubmission', e.getMessage(), e);
       return NULL;
     }
   }
}