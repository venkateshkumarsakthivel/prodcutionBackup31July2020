public with sharing class UnsuspendTaxiLicenseController {
    
    @AuraEnabled
    public static String validateAuthorisationRecord(String authId) { 
        try{
            Id TaxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
            String currentUserProfile = UserInfo.getProfileId();
            Profile userProfile = [Select Name from Profile where Id =: currentUserProfile];
            System.debug('currentUserProfile: '+ userProfile.Name);
            
            Authorisation__c tempAuth = [SELECT Name,Status__c, Authorisation_Type__c, Licence_Class__c, Request_Type__c,
                                         Paired_License__c, Paired_License__r.Status__c, Paired_License__r.Name, Paired_License__r.Request_Type__c
                                         FROM Authorisation__c
                                         WHERE Id = :authId];
            
            List<Case>  casealreadyexist = new List<Case>();
            
            casealreadyexist = [select Id from Case where Status !='Closed'  and (Sub_Type__c ='Unsuspend' or Sub_Type__c ='Suspend-Paired' or Sub_Type__c ='UnSuspend-Paired' or Sub_Type__c ='Suspend' or Sub_Type__c ='Surrender' or Sub_Type__c ='Cancel') and Type ='Taxi' 
                                and  Authorisation__c = :tempAuth.Id and RecordTypeId = :TaxiLicenseAdministrationRecordTypeId];
            
            if((tempAuth.Licence_Class__c == 'TX03WAT'|| tempAuth.Licence_Class__c == 'TX03') && tempAuth.Paired_License__c == null){
                return 'NoPairedLicense';
            }
            
            
            if(userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_2 || userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_3 || userProfile.Name == GlobalConstants.ADMIN_PROFILE_NAME)
            {
                if((tempAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED) &&
                   (tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE) &&
                   (tempAuth.Licence_Class__c != null)){
                       
                      if(tempAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03
                          && tempAuth.Paired_License__c != NULL 
                          && (tempAuth.Paired_License__r.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED )){
                                  String AuthName =  tempAuth.Paired_License__r.Name;
                           			return AuthName;
                              }
                       if(casealreadyexist.size()==0){
                           return 'SUCCESS';
                       }
                       else{
                           return 'CaseAlreadyCreated';
                       }
                   }
                
                else
                    return 'FAILURE';
            }
            
            return 'ERROR'; 
        }  catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'UnsuspendTaxiLicenseController','validateAuthorisationRecord',ex.getMessage(),ex);
            return null;
        }
    }
    
    @AuraEnabled
    public static String createUnsuspensionCase(String authId)
    {
        try{
            
            Set<String> taxiPairedLicences = new Set<String>();
            taxiPairedLicences.add(GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03);
            taxiPairedLicences.add(GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03WAT);
            
            Id TaxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            Authorisation__c taxiAuth = [SELECT Id, Status__c, 
                                         Paired_License__c, Paired_License__r.Service_Provider__c, Paired_License__r.Licence_Class__c,
                                         Service_Provider__c, Authorisation_Type__c,
                                         Request_Type__c, Licence_Class__c FROM Authorisation__c
                                         WHERE Id = :authId]; 
            
            System.debug('taxiauth is '+ taxiAuth);
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = TRUE;
            dmo.EmailHeader.triggerUserEmail = true;
            
            Case UnsuspensionCase = caseCreatorHelper(taxiAuth);
            UnsuspensionCase.setOptions(dmo);
            UnsuspensionCase.Subject = taxiAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03 ? GlobalConstants.CASE_SUBJECT_NEXUS_UNSUSPEND_PAIRED : UnsuspensionCase.Subject;
            UnsuspensionCase.Description = taxiAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03 ? GlobalConstants.CASE_DESCRIPTION_NEXUS_UNSUSPEND_PAIRED : UnsuspensionCase.Description;
            
            //Create Suspension Case with case assignment rule and email notification enabled.
            Database.insert(UnsuspensionCase, dmo);
            
            //if licence class is TX03WAT the created suspension case for TX03 
            if(taxiAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03WAT) {
              Authorisation__c pairedLicence = new Authorisation__c();
              pairedLicence.Id = taxiAuth.Paired_License__c;
              pairedLicence.Service_Provider__c = taxiAuth.Paired_License__r.Service_Provider__c;
              pairedLicence.Licence_Class__c = taxiAuth.Paired_License__r.Licence_Class__c;
              
              Case childUnSuspensionCase = caseCreatorHelper(pairedLicence);
               
              childUnSuspensionCase.Subject = taxiAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03 ? GlobalConstants.CASE_SUBJECT_NEXUS_UNSUSPEND_PAIRED : UnsuspensionCase.Subject;
              childUnSuspensionCase.Description = taxiAuth.Licence_Class__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03 ? GlobalConstants.CASE_DESCRIPTION_NEXUS_UNSUSPEND_PAIRED : UnsuspensionCase.Description;
            
              childUnSuspensionCase.setOptions(dmo);
              Database.insert(childUnSuspensionCase, dmo);
              
              pairedLicence.Request_Type__c = GlobalConstants.AUTHORISATION_REQUEST_TYPE_UNSUSPEND_PAIRED;
              update pairedLicence;
            
              UnsuspensionCase.Nexus_Paired_Licence_Child_Case__c = childUnSuspensionCase.Id;
              update UnsuspensionCase;
            }
             //Update the current authorisation's request type to "Suspend"
            taxiAuth.Request_Type__c = GlobalConstants.UNSUSPEND_REQUEST_TYPE;
            update taxiAuth;
              
            UnsuspensionCase = [SELECT Id, CaseNumber from Case where Id =:UnsuspensionCase.Id];
            return UnsuspensionCase.CaseNumber; 
            
        }catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'UnsuspendTaxiLicenseController','createUnsuspensionCase',ex.getMessage(),ex);
            return null;
        }
    }
    
    private static Case caseCreatorHelper(Authorisation__c taxiAuth) {
      
        Set<String> taxiPairedLicences = new Set<String>();
        taxiPairedLicences.add(GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03);
        taxiPairedLicences.add(GlobalConstants.TAXI_LICENCE_AUTHORISATION_CLASS_TX03WAT);
            
        Id taxisuspensioncaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Case newTaxiUnSuspensionCase = new Case();
        newTaxiUnSuspensionCase.Status = GlobalConstants.CASE_STATUS_NEW;
        newTaxiUnSuspensionCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
        newTaxiUnSuspensionCase.Type = GlobalConstants.TAXI_CASE_TYPE;
        newTaxiUnSuspensionCase.Sub_Type__c = taxiPairedLicences.contains(taxiAuth.Licence_Class__c) ? GlobalConstants.CASE_SUB_TYPE_UNSUSPEND_PAIRED : GlobalConstants.CASE_SUB_TYPE_UNSUSPEND;
        newTaxiUnSuspensionCase.Subject = taxiPairedLicences.contains(taxiAuth.Licence_Class__c) ? GlobalConstants.CASE_SUBJECT_UNSUSPEND_PAIRED : 'Unsuspension of Taxi license';
        newTaxiUnSuspensionCase.Description = taxiPairedLicences.contains(taxiAuth.Licence_Class__c) ? GlobalConstants.CASE_DESCRIPTION_UNSUSPEND_PAIRED : 'Unsuspension of Taxi license';
        newTaxiUnSuspensionCase.AccountId = taxiAuth.Service_Provider__c;
        newTaxiUnSuspensionCase.Authorisation__c = taxiAuth.Id;
        newTaxiUnSuspensionCase.RecordTypeId = taxisuspensioncaseRecordTypeId;
            
        System.debug('RecordTypeId: ' + taxisuspensioncaseRecordTypeId);
            
        return newTaxiUnSuspensionCase;
    } 
    
}