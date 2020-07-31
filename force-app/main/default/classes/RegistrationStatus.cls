/**
*	update the payment details after the response is received from Quick Vault
*	If customer registers for credit card then the direct debit fields will be cleared.
*	If customer registers for direct debit then the credit card fields will be cleared.
*/
public  without sharing class RegistrationStatus {
    
    public static void updateDirectDebitAuthDetails(String customerReferenceNumber, String accountName, String accountNumber, String bsb, String preregistrationCode) {
        
        List<Authorisation__c> listAuthorisations = [SELECT Id, Name, Service_Provider__c, Is_Renewal_Licence__c, Status__c 
                                                     FROM Authorisation__c 
                                                     WHERE Name =: customerReferenceNumber];
        
        Map<String, Authorisation__c> mapAuthorisationsToUpdate = new Map<String, Authorisation__c>();
        Set<String> setAuthorisationNames = new Set<String>();
        List<Authorisation__c> listDuplicateAuthorisationsToUpdate = new List<Authorisation__c>();
        
        for(Authorisation__c authorisationRec :  listAuthorisations) {
            
            if(setAuthorisationNames.add(authorisationRec.Name)) {
                
                // First occurance of Authorisation Name
                mapAuthorisationsToUpdate.put(authorisationRec.Name, authorisationRec);
                
            } else {
                
                // Found duplicate Authorisation Name
                
                Authorisation__c previousAuthWithSameName = mapAuthorisationsToUpdate.get(authorisationRec.Name);
                
                if(previousAuthWithSameName.Service_Provider__c == authorisationRec.Service_Provider__c) {
                    
                    // If Renewal scenario (Account is the same on both Authorisations and Is_Renewal_Licence__c is true for the one with Draft status), 
                    // the update should occur on both (Granted & Draft) Authorisations
                    
                    if(previousAuthWithSameName.Status__c == GlobalConstants.AUTHORISATION_GRANTED) {
                        // If previous authorisation status is Granted
                        // Do nothing as we have alrady added this authorisation to map
                    } else if(authorisationRec.Status__c == GlobalConstants.AUTHORISATION_GRANTED) {
                        
                        // Remove prev authorisation from map as it has status other than Granted
                        mapAuthorisationsToUpdate.remove(previousAuthWithSameName.Name);
                        
                        // Check for current authorisation record status as Granted
                        mapAuthorisationsToUpdate.put(authorisationRec.Name, authorisationRec);
                    } 
                    
                    if((previousAuthWithSameName.Is_Renewal_Licence__c
                        && previousAuthWithSameName.Status__c == GlobalConstants.AUTHORISATION_STATUS_DRAFT)
                       || (authorisationRec.Is_Renewal_Licence__c
                           && authorisationRec.Status__c == GlobalConstants.AUTHORISATION_STATUS_DRAFT)) {
                               
                               listDuplicateAuthorisationsToUpdate.add(authorisationRec);
                           }
                } else {
                    
                    // If Transfer Scenario (Account is different on both Authorisations and there are open Transfer Cases associated with the Authorisations), 
                    // the update should only occur on the Authorisation with status as Granted.
                    
                    if(isExistingTransferApplicationOpen(previousAuthWithSameName.Id)) {
                        
                        if(previousAuthWithSameName.Status__c == GlobalConstants.AUTHORISATION_GRANTED) {
                            // If previous authorisation status is Granted
                            // Do nothing as we have alrady added this authorisation to map
                        } else {
                            
                            // Remove prev authorisation from map as it has status other than Granted
                            mapAuthorisationsToUpdate.remove(previousAuthWithSameName.Name);
                            
                            // Check for current authorisation record status as Granted
                            if(authorisationRec.Status__c == GlobalConstants.AUTHORISATION_GRANTED) {
                                mapAuthorisationsToUpdate.put(authorisationRec.Name, authorisationRec);
                            }
                        }
                    }
                }
            }
            
        }
        
        List<Authorisation__c> listAuthorisationsToUpdate = new List<Authorisation__c>();
        listAuthorisationsToUpdate.addAll(mapAuthorisationsToUpdate.values());
        listAuthorisationsToUpdate.addAll(listDuplicateAuthorisationsToUpdate);
        
        if(listAuthorisationsToUpdate.size() > 0) {
            
            for(Authorisation__c authorisationRec :  listAuthorisationsToUpdate) {
                authorisationRec.Bank_Account_Name__c = accountName;
                authorisationRec.Bank_Account_Number__c = accountNumber;
                authorisationRec.BSB_Number__c = bsb;
                authorisationRec.Payment_Token__c = preregistrationCode;
                // clear the card details fields                                                        
                authorisationRec.Payment_Expiry_Date__c = '';
                authorisationRec.Payment_Card_Number__c = '';
                authorisationRec.Payment_Card_Type__c = '';             
            }
            
            update listAuthorisationsToUpdate;
        }
        
    }
    
    public static void updateCreditCardAuthDetails(String customerReferenceNumber, String cardName, String maskedCardNumber, String expiryDateMonth, String expiryDateYear, String cardScheme, String preregistrationCode) {
        
        List<Authorisation__c> listAuthorisations = [SELECT Id, Name, Service_Provider__c, Is_Renewal_Licence__c, Status__c 
                                                     FROM Authorisation__c 
                                                     WHERE Name =: customerReferenceNumber];
        
        Map<String, Authorisation__c> mapAuthorisationsToUpdate = new Map<String, Authorisation__c>();
        Set<String> setAuthorisationNames = new Set<String>();
        List<Authorisation__c> listDuplicateAuthorisationsToUpdate = new List<Authorisation__c>();
        
        for(Authorisation__c authorisationRec :  listAuthorisations) {
            
            if(setAuthorisationNames.add(authorisationRec.Name)) {
                
                // First occurance of Authorisation Name
                mapAuthorisationsToUpdate.put(authorisationRec.Name, authorisationRec);
                
            } else {
                
                // Found duplicate Authorisation Name
                
                Authorisation__c previousAuthWithSameName = mapAuthorisationsToUpdate.get(authorisationRec.Name);
                
                if(previousAuthWithSameName.Service_Provider__c == authorisationRec.Service_Provider__c) {
                    
                    // If Renewal scenario (Account is the same on both Authorisations and Is_Renewal_Licence__c is true for the one with Draft status), 
                    // the update should occur on both (Granted & Draft) Authorisations
                    
                    if(previousAuthWithSameName.Status__c == GlobalConstants.AUTHORISATION_GRANTED) {
                        // If previous authorisation status is Granted
                        // Do nothing as we have alrady added this authorisation to map
                    } else if(authorisationRec.Status__c == GlobalConstants.AUTHORISATION_GRANTED) {
                        
                        // Remove prev authorisation from map as it has status other than Granted
                        mapAuthorisationsToUpdate.remove(previousAuthWithSameName.Name);
                        
                        // Check for current authorisation record status as Granted
                        mapAuthorisationsToUpdate.put(authorisationRec.Name, authorisationRec);
                    } 
                    
                    if((previousAuthWithSameName.Is_Renewal_Licence__c
                        && previousAuthWithSameName.Status__c == GlobalConstants.AUTHORISATION_STATUS_DRAFT)
                       || (authorisationRec.Is_Renewal_Licence__c
                           && authorisationRec.Status__c == GlobalConstants.AUTHORISATION_STATUS_DRAFT)) {
                               
                               listDuplicateAuthorisationsToUpdate.add(authorisationRec);
                           }
                } else {
                    
                    // If Transfer Scenario (Account is different on both Authorisations and there are open Transfer Cases associated with the Authorisations), 
                    // the update should only occur on the Authorisation with status as Granted.
                    
                    if(isExistingTransferApplicationOpen(previousAuthWithSameName.Id)) {
                        
                        if(previousAuthWithSameName.Status__c == GlobalConstants.AUTHORISATION_GRANTED) {
                            // If previous authorisation status is Granted
                            // Do nothing as we have alrady added this authorisation to map
                        } else {
                            
                            // Remove prev authorisation from map as it has status other than Granted
                            mapAuthorisationsToUpdate.remove(previousAuthWithSameName.Name);
                            
                            // Check for current authorisation record status as Granted
                            if(authorisationRec.Status__c == GlobalConstants.AUTHORISATION_GRANTED) {
                                mapAuthorisationsToUpdate.put(authorisationRec.Name, authorisationRec);
                            }
                        }
                    }
                }
            }
            
        }
        
        List<Authorisation__c> listAuthorisationsToUpdate = new List<Authorisation__c>();
        listAuthorisationsToUpdate.addAll(mapAuthorisationsToUpdate.values());
        listAuthorisationsToUpdate.addAll(listDuplicateAuthorisationsToUpdate);
        
        if(listAuthorisationsToUpdate.size() > 0) {
            
            for(Authorisation__c authorisationRec :  listAuthorisationsToUpdate) {
                authorisationRec.Payment_Expiry_Date__c = expiryDateMonth+'/'+expiryDateYear;
                authorisationRec.Payment_Card_Number__c = maskedCardNumber;
                authorisationRec.Payment_Card_Type__c = cardScheme;
                authorisationRec.Payment_Token__c = preregistrationCode;  
                // clear the direct debit fields
                authorisationRec.Bank_Account_Name__c = '';
                authorisationRec.Bank_Account_Number__c = '';
                authorisationRec.BSB_Number__c = '';   
            }
            
            update listAuthorisationsToUpdate;
        }
    }
    
    private static boolean isExistingTransferApplicationOpen(String authorisationId) {
        
        try {
            
            Id taxiAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            List<Case> taxiAdministrationCasesList = [SELECT Id, CaseNumber, Type, Sub_Type__c FROM Case 
                                                      WHERE IsClosed = false 
                                                      AND RecordTypeId =: taxiAdministrationRecordTypeId 
                                                      AND Type =: GlobalConstants.SERVICE_TYPE_TAXI
                                                      AND Sub_Type__c =: GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER
                                                      AND Authorisation__c =: authorisationId];
            
            if(taxiAdministrationCasesList.isEmpty()) {
                
                Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                    .get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
                
                List<Case> taxiTransferCasesList = [SELECT Id, CaseNumber, Type, Sub_Type__c FROM Case  
                                                    WHERE IsClosed = false 
                                                    AND RecordTypeId =: transferRecordTypeId 
                                                    AND Type =: GlobalConstants.SERVICE_TYPE_TAXI
                                                    AND Sub_Type__c =: GlobalConstants.CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER
                                                    AND Authorisation__c =: authorisationId];
                
                return !taxiTransferCasesList.isEmpty();
            } 
            
            return !taxiAdministrationCasesList.isEmpty();
        }
        catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'RegistrationStatus', 'isExistingTransferApplicationOpen', e.getMessage(), e);
            return null;
        }
    }
}