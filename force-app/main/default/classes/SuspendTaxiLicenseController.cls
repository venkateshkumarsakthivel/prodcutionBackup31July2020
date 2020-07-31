//This class is used as a controller to SuspendTaxiLicense lightning component.
//This validates and creates suspend case on an authorisation.


public class SuspendTaxiLicenseController {
    
    //This method validates current user profile and authorisation record for further creation of Suspend case.
    @AuraEnabled
    public static String validateAuthorisationRecord(String authId) {
        try{
            
            String currentUserProfile = UserInfo.getProfileId();
            Profile userProfile = [Select Name from Profile where Id =: currentUserProfile];
            System.debug('currentUserProfile: '+ userProfile.Name);
            
            Id TaxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
                    
            Authorisation__c tempAuth = [SELECT Status__c, Authorisation_Type__c, Licence_Class__c, Request_Type__c,
                                         Paired_License__c, Paired_License__r.Status__c, Paired_License__r.Request_Type__c
                                         FROM Authorisation__c
                                         WHERE Id = :authId];
                                         
            List<Case>  casealreadyexist = new List<Case>();
                    
            casealreadyexist = [select Id from Case where Status !='Closed' and (Sub_Type__c ='Unsuspend' or Sub_Type__c ='Suspend-Paired' or Sub_Type__c ='UnSuspend-Paired' or Sub_Type__c ='Suspend' or Sub_Type__c ='Surrender' or Sub_Type__c ='Cancel')
                                and Type ='Taxi' and  Authorisation__c = :tempAuth.Id and RecordTypeId = :TaxiLicenseAdministrationRecordTypeId];
             
             if((tempAuth.Licence_Class__c == 'TX03WAT'|| tempAuth.Licence_Class__c == 'TX03') && tempAuth.Paired_License__c == null){
                return 'NoPairedLicense';
            }
            
            if(userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_2 || userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_3
               || userProfile.Name == GlobalConstants.ADMIN_PROFILE_NAME) {
               
                if(tempAuth.Status__c == GlobalConstants.AUTHORISATION_GRANTED 
                   && tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE
                   && tempAuth.Licence_Class__c != NULL) {
                       
                       if(tempAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03WAT
                           && tempAuth.Paired_License__c != NULL 
                           && (tempAuth.Paired_License__r.Request_Type__c == GlobalConstants.SUSPEND_REQUEST_TYPE
                               || tempAuth.Paired_License__r.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED))
                           return 'PairedLicenceInvalidState';
                   
                       if(casealreadyexist.size() == 0)
                           return 'SUCCESS';
                       else
                           return 'CaseAlreadyCreated';
                   }
                else 
                 return 'InvalidAuthorisationRecord';
            }
            
            return 'InvalidProfileUser';
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'suspendTaxiLicenseController','validateAuthorisationRecord',ex.getMessage(),ex);
            return 'null';
        }
    }

    //This method fetch values(reasons) from Suspension_Reason__c multipicklist field at runtime.
    @AuraEnabled
    public static List<String> fetchCancelationReasonsMPicklist() {
        List<String> cancelationReasonsMPicklist = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Suspension_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            System.debug(f.getLabel());
            cancelationReasonsMPicklist.add(f.getLabel());
        }
        return cancelationReasonsMPicklist;
    } 
    
    
    //Create Suspension case for current authorisation.
    @AuraEnabled
    public static String createTaxiLicenceSuspensionCase(String authId, String reason){
       
        try{
            
            System.debug('In the controller');
            
            Set<String> taxiPairedLicences = new Set<String>();
            taxiPairedLicences.add(GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03);
            taxiPairedLicences.add(GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03WAT);
        
            Authorisation__c taxiAuth = [SELECT Id, Status__c, 
                                         Paired_License__c, Paired_License__r.Service_Provider__c, Paired_License__r.Licence_Class__c,
                                         Service_Provider__c, Authorisation_Type__c,
                                         Request_Type__c, Licence_Class__c FROM Authorisation__c
                                         WHERE Id = :authId];    
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = TRUE;
            dmo.EmailHeader.triggerUserEmail = true;
            
            Case suspensionCase = caseCreatorHelper(taxiAuth, reason);
            suspensionCase.Subject = taxiAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03 ? GlobalConstants.CASE_SUBJECT_NEXUS_SUSPEND_PAIRED : suspensionCase.Subject;
            suspensionCase.Description = taxiAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03 ? GlobalConstants.CASE_DESCRIPTION_NEXUS_SUSPEND_PAIRED : suspensionCase.Description;
            
            suspensionCase.setOptions(dmo);
            //Create Suspension Case with case assignment rule and email notification enabled.
            Database.insert(suspensionCase, dmo);
            
            //if licence class is TX03WAT the created suspension case for TX03 
            if(taxiAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03WAT) {
              
              Authorisation__c pairedLicence = new Authorisation__c();
              pairedLicence.Id = taxiAuth.Paired_License__c;
              pairedLicence.Service_Provider__c = taxiAuth.Paired_License__r.Service_Provider__c;
              pairedLicence.Licence_Class__c = taxiAuth.Paired_License__r.Licence_Class__c;
              
              Case childSuspensionCase = caseCreatorHelper(pairedLicence, reason);
              
              childSuspensionCase.setOptions(dmo);
              
              Database.insert(childSuspensionCase, dmo);
              
              pairedLicence.Request_Type__c = GlobalConstants.AUTHORISATION_REQUEST_TYPE_SUSPEND_PAIRED;
              update pairedLicence;
            
              suspensionCase.Nexus_Paired_Licence_Child_Case__c = childSuspensionCase.Id;
              update suspensionCase;
            }
            
            //Update the current authorisation's request type to "Suspend"
            taxiAuth.Request_Type__c = GlobalConstants.SUSPEND_REQUEST_TYPE;
            update taxiAuth;
              
            suspensionCase = [SELECT Id, CaseNumber from Case where Id =:suspensionCase.Id];
            return suspensionCase.CaseNumber;            
            
        }
        catch(Exception ex) {
        
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'suspendTaxiLicenseController','createTaxiLicenceSuspensionCase',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
    
    
    private static Case caseCreatorHelper(Authorisation__c taxiAuth, String reason) {
      
        Set<String> taxiPairedLicences = new Set<String>();
        taxiPairedLicences.add(GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03);
        taxiPairedLicences.add(GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03WAT);
            
        Id taxisuspensioncaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Case newTaxiSuspensionCase = new Case();
        newTaxiSuspensionCase.Status = GlobalConstants.CASE_STATUS_NEW;
            
        newTaxiSuspensionCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
            
        newTaxiSuspensionCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            
        newTaxiSuspensionCase.Sub_Type__c = taxiPairedLicences.contains(taxiAuth.Licence_Class__c) ? GlobalConstants.CASE_SUB_TYPE_SUSPEND_PAIRED : GlobalConstants.SUSPEND_CASE_SUB_TYPE;
            
        newTaxiSuspensionCase.Subject = taxiPairedLicences.contains(taxiAuth.Licence_Class__c) ? GlobalConstants.CASE_SUBJECT_SUSPEND_PAIRED : 'Suspension of Taxi license';
        newTaxiSuspensionCase.Description = taxiPairedLicences.contains(taxiAuth.Licence_Class__c) ? GlobalConstants.CASE_DESCRIPTION_SUSPEND_PAIRED : 'Suspension of Taxi license';
        newTaxiSuspensionCase.AccountId = taxiAuth.Service_Provider__c;
        newTaxiSuspensionCase.Authorisation__c = taxiAuth.Id;
        newTaxiSuspensionCase.Suspension_Reason__c = reason;
        newTaxiSuspensionCase.RecordTypeId = taxisuspensioncaseRecordTypeId;
            
        System.debug('RecordTypeId: ' + taxisuspensioncaseRecordTypeId);
            
        return newTaxiSuspensionCase;
    } 
}