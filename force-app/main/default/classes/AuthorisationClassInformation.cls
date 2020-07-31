/*
* Helper class to map taxi class metadata values to authorisation during create and update operations
*/

public with sharing class AuthorisationClassInformation {
    
    //This method helps to map the taxi class metadata based on Licence Class of authorisation during create operation.
    public void mapNewAuthorisationClassInformation(List<Authorisation__c> newAuthorisations){
        try{
            // Add custom metadata types values to the new map of Authorisation rercord.
            
            List<String> tempLicenceClass = new  List<String>();
            
            //Create map of Licence class of taxi class metadata vs metadata record.
            Map<String,Taxi_Class__mdt> LicenceClassVSMetadata= new Map<String,Taxi_Class__mdt>();
            
            for(Authorisation__c tempAuth : newAuthorisations) {
                tempLicenceClass.add(tempAuth.Licence_Class__c);
            }
            
            //get taxi class metadata for incoming authorisation to be created.
            List<Taxi_Class__mdt> getLicenceClassmdt = [SELECT Licence_Class__c, Description__c, Is_Legacy_Only__c, Is_WAT__c, 
                                                        Is_Transferable__c, Is_Renewable__c, Renew_Months__c, 
                                                        Max_Years__c, Renew_Formula__c FROM Taxi_Class__mdt where Licence_Class__c IN: tempLicenceClass];
            
            //Map metadata record with licence class as key.
            for(Taxi_Class__mdt taxiMdtRecord : getLicenceClassmdt) {
                if(!LicenceClassVSMetadata.containsKey(taxiMdtRecord.Licence_Class__c)) {
                    LicenceClassVSMetadata.put(taxiMdtRecord.Licence_Class__c, taxiMdtRecord);
                }
            }
            
            //Map metadata to incoming authorisation based on its licence class.
            for(Authorisation__c tempAuthorisation : newAuthorisations){
                if(LicenceClassVSMetadata.containsKey(tempAuthorisation.Licence_Class__c)){
                    Taxi_Class__mdt tempMdtRecord = LicenceClassVSMetadata.get(tempAuthorisation.Licence_Class__c); 
                    tempAuthorisation.Class_Description__c = tempMdtRecord.Description__c;
                    tempAuthorisation.Class_is_Grandfathered__c = tempMdtRecord.Is_Legacy_Only__c;
                    tempAuthorisation.Class_is_WAT__c = tempMdtRecord.Is_WAT__c;
                    tempAuthorisation.Class_allows_Transfers__c = tempMdtRecord.Is_Transferable__c;
                    tempAuthorisation.Class_allows_Renewals__c = tempMdtRecord.Is_Renewable__c;
                    tempAuthorisation.Class_Renewal_Period__c = tempMdtRecord.Renew_Months__c;
                    tempAuthorisation.Class_Max_Duration__c = tempMdtRecord.Max_Years__c;
                    tempAuthorisation.Application_Fee__c = tempMdtRecord.Renew_Formula__c;
                }
                else{
                    tempAuthorisation.Class_Description__c = null;
                    tempAuthorisation.Class_is_Grandfathered__c = null;
                    tempAuthorisation.Class_is_WAT__c = null;
                    tempAuthorisation.Class_allows_Transfers__c = null;
                    tempAuthorisation.Class_allows_Renewals__c = null;
                    tempAuthorisation.Class_Renewal_Period__c = null;
                    tempAuthorisation.Class_Max_Duration__c = null;
                    tempAuthorisation.Application_Fee__c = null;
                }
            }
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuthorisationClassInformation','mapNewAuthorisationClassInformation',ex.getMessage(),ex);
        }
    }
    
    //This method helps to update exisiting authorisation if its licence class gets updated/changed.
    public void populateExisitingAuthorisationClassInformation(List <Authorisation__c> newAuthorisations, Map<Id, Authorisation__c> oldAuthorisationsMap){
        try{
            
            List<Authorisation__c> targetAuthorisationsForMappingMDT = new List<Authorisation__c>();
            
            //Check authorisation's licence class for not null,record type as Taxi_Licence,etc.
            for(Authorisation__c tempAuth : newAuthorisations) {
                
                if(tempAuth.Record_Type_Dev_Name__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME)
                    targetAuthorisationsForMappingMDT.add(tempAuth);
            }
            if(targetAuthorisationsForMappingMDT.size() > 0)
                mapNewAuthorisationClassInformation(targetAuthorisationsForMappingMDT);
            //Call mapNewAuthorisationClassInformation method to update authorisation's licence class and its metadata fields. 
        }
        
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuthorisationClassInformation','populateExisitingAuthorisationClassInformation',ex.getMessage(),ex);
        }
    }
    
}