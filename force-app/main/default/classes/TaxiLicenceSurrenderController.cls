public class TaxiLicenceSurrenderController {
    @AuraEnabled
    public static String validateAuthorisationRecord(String authId) { 
        try{
            
            String currentUserProfile = UserInfo.getProfileId();
            Profile userProfile = [Select Name from Profile where Id =: currentUserProfile];
            System.debug('currentUserProfile: '+ userProfile.Name);
            Id TaxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id TaxiTransferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Authorisation__c tempAuth = [SELECT End_Date__c, Status__c, Authorisation_Type__c, Licence_Class__c, Request_Type__c, Paired_License__c FROM Authorisation__c
                                         WHERE Id = :authId];
            List<Case>  casealreadyexist = new List<Case>();
            
            casealreadyexist = [select Id from Case where Status !='Closed' and (Sub_Type__c ='Unsuspend' or Sub_Type__c ='Suspend' or Sub_Type__c ='Suspend-Paired' or Sub_Type__c ='UnSuspend-Paired' or Sub_Type__c ='Surrender' or Sub_Type__c = 'Surrender-Paired' or Sub_Type__c ='Cancel')
                                and Type ='Taxi' and  Authorisation__c = :tempAuth.Id and (RecordTypeId = :TaxiLicenseAdministrationRecordTypeId or RecordTypeId = :TaxiTransferRecordTypeId)];
            
            if(tempAuth.Licence_Class__c == 'TX03WAT' && tempAuth.Paired_License__c == null){
                return 'NoPairedLicense';
            }
            
			//P2PSUPPORT-123 - Level 1 should be able to initiate Taxi licence surrender
            if(userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_1 || userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_2 || userProfile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_3 || userProfile.Name == GlobalConstants.ADMIN_PROFILE_NAME){
                if((tempAuth.Status__c == GlobalConstants.AUTHORISATION_GRANTED || tempAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED) 
                   && (tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE)
                   && (tempAuth.Licence_Class__c != null)){

                        //P2PSUPPORT-147 Don't allow surrender if the End Date is less than or equal to 28 days
                        Date currentPlus28Days = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_Expiry_of_Licence));
                        if(tempAuth.End_Date__c <= currentPlus28Days){
                            return 'RequestInRenewalPeriod';
                        }
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
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceSurrenderController','validateAuthorisationRecord',ex.getMessage(),ex);
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
    public static List<String> getAuthorisationPaymentCalculation(String authId) {
        System.debug('total orders');
        System.debug('amount due');
        List<Order> paymentDueOrders = new List<Order>();
        
        
        paymentDueOrders = [SELECT Authorisation__c, Authorisation__r.Payment_Frequency__c,Status, Amount_Due__c, TotalAmount 
                            From Order where (Authorisation__c = :authId AND (Status = 'Payment Due' OR Status = 'Payment Uncleared' OR Status = 'Payment Rejected') AND (Authorisation__r.Payment_Frequency__c = 'Monthly'))];
        
        if(paymentDueOrders.isEmpty()){
            System.debug('No orders');
            List<String> my_list1 = new List<String>();
            String totalpaymentOrders = '0';
            my_list1.add(totalpaymentOrders);
            return my_list1;
        }
        else{
            System.debug('With Orders');
            String totalpaymentOrders =String.valueOf(paymentDueOrders.size());
            Order selectedOrder = paymentDueOrders.get(0);
            String amountDue = String.valueOf(selectedOrder.TotalAmount);
            String paymentfrequency = String.valueOf(selectedOrder.Authorisation__r.Payment_Frequency__c);
            System.debug('total orders'+totalpaymentOrders);
            System.debug('amount due'+amountDue);
            
            List<String> my_list = new List<String>();
            my_list.add(totalpaymentOrders);
            my_list.add(amountDue);
            my_list.add(paymentfrequency);
            
            System.debug('list my_list: '+my_list);
            return my_list;
        } 
    }
    
    
    @AuraEnabled
    public static String createTaxiLicenceSurrenderCase(String authId){
        
        try{
            System.debug('In the controller');
            Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            Authorisation__c taxiAuth = [SELECT Id,Status__c, Service_Provider__c, Authorisation_Type__c,Request_Type__c, Licence_Class__c FROM Authorisation__c
                                         WHERE Id = :authId];
            
            Case newTaxiSurrenderCase = new Case();
            newTaxiSurrenderCase.Status = GlobalConstants.CASE_STATUS_NEW;
            newTaxiSurrenderCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
            newTaxiSurrenderCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            newTaxiSurrenderCase.Sub_Type__c = GlobalConstants.SURRENDER_CASE_SUB_TYPE;
            newTaxiSurrenderCase.Subject = 'Surrender of Taxi license';
            newTaxiSurrenderCase.Description = 'Surrender of Taxi license';
            newTaxiSurrenderCase.AccountId = taxiAuth.Service_Provider__c;
            newTaxiSurrenderCase.Authorisation__c = taxiAuth.Id;
            newTaxiSurrenderCase.RecordTypeId = taxiLicenseAdministrationRecordTypeId;
            
            System.debug('RecordTypeId: ' + taxiLicenseAdministrationRecordTypeId);
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = TRUE;
            dmo.EmailHeader.triggerUserEmail = true;
            newTaxiSurrenderCase.setOptions(dmo);
            
            //Create Suspension Case with case assignment rule and email notification enabled.
            Database.insert(newTaxiSurrenderCase, dmo);
            
            
            taxiAuth.Request_Type__c = GlobalConstants.RETURN_REQUEST_TYPE;
            update taxiAuth;
            
            String cancellationCaseId = newTaxiSurrenderCase.Id;
            Case cancellationCase = [SELECT id, CaseNumber from Case where id=:cancellationCaseId];
            String cancellationCaseNumber = cancellationCase.CaseNumber;
            return cancellationCaseNumber;
            //return CaseNumber for redirecting to new taxi suspension case created.
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceSurrenderController','createTaxiLicenceSurrenderCase',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
    
    @AuraEnabled
    public static String createTaxiLicenceSurrenderCaseTX03WAT(String authId, String reason){
        
        try{
            System.debug('In the controller');
            Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            
            Authorisation__c taxiAuth = [SELECT Id,Status__c, Service_Provider__c, Authorisation_Type__c,Request_Type__c, Licence_Class__c,Paired_License__c FROM Authorisation__c
                                         WHERE Id = :authId];
            
            
            
            //Create Parent case with Authorisation Id as TX03WAT's Authorisation Id
            Case newTaxiSurrenderCase = new Case();
            newTaxiSurrenderCase.Status = GlobalConstants.CASE_STATUS_NEW;
            newTaxiSurrenderCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
            newTaxiSurrenderCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            newTaxiSurrenderCase.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_SURRENDER_PAIRED;
            newTaxiSurrenderCase.Subject = 'Surrender of Paired Taxi license';
            newTaxiSurrenderCase.Description = 'Surrender of Paired Taxi license';
            newTaxiSurrenderCase.AccountId = taxiAuth.Service_Provider__c;
            newTaxiSurrenderCase.Authorisation__c = taxiAuth.Id;
            newTaxiSurrenderCase.RecordTypeId = taxiLicenseAdministrationRecordTypeId;
            
            System.debug('RecordTypeId: ' + taxiLicenseAdministrationRecordTypeId);
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = TRUE;
            dmo.EmailHeader.triggerUserEmail = true;
            newTaxiSurrenderCase.setOptions(dmo);
            
            //Create Suspension Case with case assignment rule and email notification enabled.
            Database.insert(newTaxiSurrenderCase, dmo);
            
            //Update Request Type of selected Authorisation to 'Cancel'
            taxiAuth.Request_Type__c = GlobalConstants.RETURN_REQUEST_TYPE;
            update taxiAuth;
            
            //Create Child case with Paired License id of TX03WAT's Authorisation and parent case id as newTaxiSurrenderCase id.
            Case newTaxiSurrenderCaseChildCase = new Case();
            newTaxiSurrenderCaseChildCase.ParentId = newTaxiSurrenderCase.Id;
            newTaxiSurrenderCaseChildCase.Status = GlobalConstants.CASE_STATUS_NEW;
            newTaxiSurrenderCaseChildCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
            newTaxiSurrenderCaseChildCase.Type = GlobalConstants.TAXI_CASE_TYPE;
            newTaxiSurrenderCaseChildCase.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_SURRENDER_PAIRED;
            newTaxiSurrenderCaseChildCase.Subject = 'Surrender of Paired Taxi license';
            newTaxiSurrenderCaseChildCase.Description = 'Surrender of Paired Taxi license';
            newTaxiSurrenderCaseChildCase.AccountId = taxiAuth.Service_Provider__c;
            newTaxiSurrenderCaseChildCase.Authorisation__c = taxiAuth.Paired_License__c;
            newTaxiSurrenderCaseChildCase.RecordTypeId = taxiLicenseAdministrationRecordTypeId;
            
            Database.DMLOptions dmo1 = new Database.DMLOptions();
            dmo1.assignmentRuleHeader.useDefaultRule = TRUE;
            dmo1.EmailHeader.triggerUserEmail = true;
            newTaxiSurrenderCaseChildCase.setOptions(dmo1);
            
            //Create Cancellation Case with case assignment rule and email notification enabled.
            Database.insert(newTaxiSurrenderCaseChildCase, dmo1);
            
            String tx03authId = taxiAuth.Paired_License__c;
            Authorisation__c tx03taxiAuth = [SELECT Id,Status__c, Service_Provider__c, Authorisation_Type__c,Request_Type__c, Licence_Class__c,Paired_License__c FROM Authorisation__c
                                             WHERE Id = :tx03authId];   
            
            tx03taxiAuth.Request_Type__c = GlobalConstants.RETURN_REQUEST_TYPE;
            update tx03taxiAuth;
            
            String parentCaseId = newTaxiSurrenderCase.Id;
            Case parentCaseCreated = [SELECT id, CaseNumber from Case where id=:parentCaseId];
            String parentCaseNumber = parentCaseCreated.CaseNumber;
            return parentCaseNumber;
            //return CaseNumber for reference message of new taxi cancellation case created.
            
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceSurrenderController','createTaxiLicenceSurrenderCaseTX03WAT',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
    
    @AuraEnabled
    public static String createTaxiLicenceSurrenderCaseFromPortal(String authId,String surrenderdate){
        try{
            System.debug('In the controller');
            Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            List<Case> casesList = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c, 
                                    Transfer_Reason__c, Licence_Fee_Due__c, Beneficiary_Type__c, Is_Privacy_Statement_Declared__c, Origin
                                    FROM Case
                                    WHERE RecordTypeId =: taxiLicenseAdministrationRecordTypeId 
                                    AND (Status != 'Closed' AND Sub_Status__c != 'Approved')
                                    AND Type =: GlobalConstants.TAXI_CASE_TYPE
                                    AND (Sub_Type__c =: GlobalConstants.SURRENDER_CASE_SUB_TYPE)
                                    AND Authorisation__c =: authId];
            
            if(casesList.size() > 0) { 
                return null;
            }
            else {
                Authorisation__c taxiAuth = [SELECT Id,Status__c, Service_Provider__c, Authorisation_Type__c,Request_Type__c, Licence_Class__c,Paired_License__c FROM Authorisation__c
                                             WHERE Id = :authId];
                
                //Create Surrender case with Authorisation Id
                Case newTaxiSurrenderCase = new Case();
                newTaxiSurrenderCase.Status = GlobalConstants.LODGED_CASE_STATUS;
                newTaxiSurrenderCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
                newTaxiSurrenderCase.Type = GlobalConstants.TAXI_CASE_TYPE;
                newTaxiSurrenderCase.Sub_Type__c = GlobalConstants.SURRENDER_CASE_SUB_TYPE;
                newTaxiSurrenderCase.Subject = 'Surrender of Taxi licence';
                newTaxiSurrenderCase.Description = 'Surrender of Taxi licence';
                newTaxiSurrenderCase.AccountId = taxiAuth.Service_Provider__c;
                newTaxiSurrenderCase.Authorisation__c = taxiAuth.Id;
                //newTaxiSurrenderCase.Confirmation_of_plates_returned__c = Boolean.valueOf(plates_returned);
                newTaxiSurrenderCase.Origin = GlobalConstants.CASE_ORIGIN_INDUSTRY_PORTAL;
                newTaxiSurrenderCase.RecordTypeId = taxiLicenseAdministrationRecordTypeId;
                newTaxiSurrenderCase.ASPSurrenderDate__c = date.valueOf(surrenderdate);
                System.debug('RecordTypeId: ' + taxiLicenseAdministrationRecordTypeId);
                
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = TRUE;
                dmo.EmailHeader.triggerUserEmail = true;
                newTaxiSurrenderCase.setOptions(dmo);
                
                //Create Suspension Case with case assignment rule and email notification enabled.
                Database.SaveResult srList = Database.insert(newTaxiSurrenderCase, dmo);
                System.debug('DB saveresults: '+srList);
                
                System.debug('Surrender Case Id: ' + newTaxiSurrenderCase.Id);
                System.debug('Surrender Case Attributes: ' + newTaxiSurrenderCase);
                
                taxiAuth.Request_Type__c = GlobalConstants.RETURN_REQUEST_TYPE;
                taxiAuth.Surrender_Date__c= date.valueOf(surrenderdate);
                update taxiAuth;
                
                System.debug('Surrender Case Authorisation Update Id: ' + taxiAuth.Id);
                System.debug('Surrender Case Authorisation Update Attributes: ' + taxiAuth);
                
                String surrenderCaseId = newTaxiSurrenderCase.Id;
                Case surrenderCase = [SELECT id, CaseNumber from Case where id=:surrenderCaseId];
                String surrenderCaseNumber = surrenderCase.CaseNumber;
                return surrenderCaseNumber;
            }           
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceSurrenderController','createTaxiLicenceSurrenderCaseFromPortal',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
    
    @AuraEnabled
    public static String createSurrenderCaseFromAgentPortal(String authId){
        String surrenderCaseNumber = TaxiAgentDataAccessProvider.createSurrenderCaseForTaxiAgent(authId);
        System.debug('Surrender Case from Agent created: '+surrenderCaseNumber);
        return surrenderCaseNumber;
    }
    
    
}