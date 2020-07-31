public class TaxiLicenceCancellationController {
    @AuraEnabled
    public static String validateAuthorisationRecord(String authId) {
        try{
            
            String currentUserProfile = UserInfo.getProfileId();
            Profile userProfile = [Select Name from Profile where Id =: currentUserProfile];
            System.debug('currentUserProfile: '+ userProfile.Name);
            Id TaxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
            
            Authorisation__c tempAuth = [SELECT Status__c, Authorisation_Type__c, Licence_Class__c, Request_Type__c, Paired_License__c FROM Authorisation__c
                                         WHERE Id = :authId];
            
            List<Case>  casealreadyexist = new List<Case>();
                    
            casealreadyexist = [select Id from Case where Status !='Closed' and (Sub_Type__c ='Unsuspend' or Sub_Type__c ='Suspend-Paired' or Sub_Type__c ='UnSuspend-Paired' or Sub_Type__c ='Suspend' or Sub_Type__c ='Surrender' or Sub_Type__c ='Cancel')
                                and Type ='Taxi' and  Authorisation__c = :tempAuth.Id and RecordTypeId = :TaxiLicenseAdministrationRecordTypeId];
                 
            
            if(tempAuth.Licence_Class__c == 'TX03WAT' && tempAuth.Paired_License__c == null){
                return 'NoPairedLicense';
            }
            
            if(userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_2 || userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_3 || userProfile.Name == GlobalConstants.ADMIN_PROFILE_NAME){
                if((tempAuth.Status__c == GlobalConstants.AUTHORISATION_GRANTED || tempAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED) 
                   && (tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE)
                   && (tempAuth.Licence_Class__c != null)){
                       if(casealreadyexist.size()==0){
                           return 'SUCCESS';
                       }
                       else{
                           return 'CaseAlreadyCreated';
                       }
                   }
                else{
                    return 'InvalidAuthorisationRecord';
                }
            }
            return 'InvalidProfileUser';
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceCancellationController','validateAuthorisationRecord',ex.getMessage(),ex);
            return 'null';
        }
    }
    
    @AuraEnabled
    public static String getAuthorisation(String authId) {
        Authorisation__c tempAuth = [SELECT Status__c, Authorisation_Type__c, Licence_Class__c FROM Authorisation__c
                                     WHERE Id = :authId];
        return JSON.serialize(tempAuth);
    }
    
    
    @AuraEnabled
    public static List<String> fetchCancelationReasonsMPicklist(){
        List<String> cancelationReasonsMPicklist = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Suspension_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            System.debug(f.getLabel());
            cancelationReasonsMPicklist.add(f.getLabel());
        }
        return cancelationReasonsMPicklist;
    } 
    
    
    @AuraEnabled
    public static String createTaxiLicenceCancellationCase(String authId, String reason){
        
        try{
            System.debug('In the controller');
            Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            Authorisation__c taxiAuth = [SELECT Id,Status__c, Service_Provider__c, Authorisation_Type__c,Request_Type__c, Licence_Class__c FROM Authorisation__c
                                         WHERE Id = :authId];
            
            Case newTaxiCancellationCase = new Case();
            newTaxiCancellationCase.Status = GlobalConstants.CASE_STATUS_NEW;
            newTaxiCancellationCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
            
            newTaxiCancellationCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            newTaxiCancellationCase.Sub_Type__c = GlobalConstants.CANCEL_CASE_SUB_TYPE;
            newTaxiCancellationCase.Subject = 'Cancellation of Taxi licence';
            newTaxiCancellationCase.Description = 'Cancellation of Taxi licence';
            newTaxiCancellationCase.AccountId = taxiAuth.Service_Provider__c;
            newTaxiCancellationCase.Authorisation__c = taxiAuth.Id;
            newTaxiCancellationCase.Suspension_Reason__c = reason;
            newTaxiCancellationCase.RecordTypeId = taxiLicenseAdministrationRecordTypeId;
            
            System.debug('RecordTypeId: ' + taxiLicenseAdministrationRecordTypeId);
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = TRUE;
            dmo.EmailHeader.triggerUserEmail = true;
            newTaxiCancellationCase.setOptions(dmo);
            
            //Create Suspension Case with case assignment rule and email notification enabled.
            Database.insert(newTaxiCancellationCase, dmo);
            
            
            taxiAuth.Request_Type__c = GlobalConstants.CANCEL_REQUEST_TYPE;
            update taxiAuth;
            
            String cancellationCaseId = newTaxiCancellationCase.Id;
            Case cancellationCase = [SELECT id, CaseNumber from Case where id=:cancellationCaseId];
            String cancellationCaseNumber = cancellationCase.CaseNumber;
            return cancellationCaseNumber;
            //return CaseNumber for redirecting to new taxi suspension case created.
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceCancellationController','createTaxiLicenceCancellationCase',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
    
   @AuraEnabled
    public static String createTaxiLicenceCancellationCaseTX03WAT(String authId, String reason){
        
        try{
            System.debug('In the controller');
            Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            
            Authorisation__c taxiAuth = [SELECT Id,Status__c, Service_Provider__c, Authorisation_Type__c,Request_Type__c, Licence_Class__c,Paired_License__c FROM Authorisation__c
                                         WHERE Id = :authId];
           
            //Create Parent case with Authorisation Id as TX03WAT's Authorisation Id
            Case newTaxiCancellationCase = new Case();
            newTaxiCancellationCase.Status = GlobalConstants.CASE_STATUS_NEW;
            newTaxiCancellationCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
            newTaxiCancellationCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            newTaxiCancellationCase.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_CANCEL_PAIRED;
            newTaxiCancellationCase.Subject = 'Cancellation of Paired Taxi licence';
            newTaxiCancellationCase.Description = 'Cancellation of Paired Taxi licence';
            newTaxiCancellationCase.AccountId = taxiAuth.Service_Provider__c;
            newTaxiCancellationCase.Authorisation__c = taxiAuth.Id;
            newTaxiCancellationCase.Suspension_Reason__c = reason;
            newTaxiCancellationCase.RecordTypeId = taxiLicenseAdministrationRecordTypeId;
            
            System.debug('RecordTypeId: ' + taxiLicenseAdministrationRecordTypeId);
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = TRUE;
            dmo.EmailHeader.triggerUserEmail = true;
            newTaxiCancellationCase.setOptions(dmo);
            
            //Create Suspension Case with case assignment rule and email notification enabled.
            Database.insert(newTaxiCancellationCase, dmo);
            
            //Update Request Type of selected Authorisation to 'Cancel'
            taxiAuth.Request_Type__c = GlobalConstants.CANCEL_REQUEST_TYPE;
            update taxiAuth;
            
            //Create Child case with Paired License id of TX03WAT's Authorisation and parent case id as newTaxiCancellationCase id.
            Case newTaxiCancellationCaseChildCase = new Case();
            newTaxiCancellationCaseChildCase.ParentId = newTaxiCancellationCase.Id;
            newTaxiCancellationCaseChildCase.Status = GlobalConstants.CASE_STATUS_NEW;
            newTaxiCancellationCaseChildCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
            newTaxiCancellationCaseChildCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            newTaxiCancellationCaseChildCase.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_CANCEL_PAIRED;
            newTaxiCancellationCaseChildCase.Subject = 'Cancellation of Paired Taxi licence';
            newTaxiCancellationCaseChildCase.Description = 'Cancellation of Paired Taxi licence';
            newTaxiCancellationCaseChildCase.AccountId = taxiAuth.Service_Provider__c;
            newTaxiCancellationCaseChildCase.Authorisation__c = taxiAuth.Paired_License__c;
            newTaxiCancellationCaseChildCase.Suspension_Reason__c = reason;
            newTaxiCancellationCaseChildCase.RecordTypeId = taxiLicenseAdministrationRecordTypeId;
            
            Database.DMLOptions dmo1 = new Database.DMLOptions();
            dmo1.assignmentRuleHeader.useDefaultRule = TRUE;
            dmo1.EmailHeader.triggerUserEmail = true;
            newTaxiCancellationCaseChildCase.setOptions(dmo1);
            
            //Create Cancellation Case with case assignment rule and email notification enabled.
            Database.insert(newTaxiCancellationCaseChildCase, dmo1);
            
            String tx03authId = taxiAuth.Paired_License__c;
            Authorisation__c tx03taxiAuth = [SELECT Id,Status__c, Service_Provider__c, Authorisation_Type__c,Request_Type__c, Licence_Class__c,Paired_License__c FROM Authorisation__c
                                         WHERE Id = :tx03authId];   
                
            tx03taxiAuth.Request_Type__c = GlobalConstants.CANCEL_REQUEST_TYPE;
            update tx03taxiAuth;
            
            String parentCaseId = newTaxiCancellationCase.Id;
            Case parentCaseCreated = [SELECT id, CaseNumber from Case where id=:parentCaseId];
            String parentCaseNumber = parentCaseCreated.CaseNumber;
            return parentCaseNumber;
            //return CaseNumber for reference message of new taxi cancellation case created.
            
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceCancellationController','createTaxiLicenceCancellationCaseTX03WAT',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
}