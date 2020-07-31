/**
* Data Struture to serialize Case 
*/
public class TaxiSectionDataWrapper {
        
        
        public Case currentCaseRec;
        
        @TestVisible
        private String caseId;
        
        @TestVisible
        private String applicantAccountId;
        
        public TaxiSectionDataWrapper(String caseId, String applicantAccountId) {
            
            this.caseId = caseId;  
            this.applicantAccountId = applicantAccountId;
        }
        
        public void loadCaseSectionData() {
            try{  
                
                System.debug('Case Id: '+caseId);
                System.debug('Account Id: '+applicantAccountId);
                
                Id individualTaxiCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
                Id organisationTaxiCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
                Id partnershipTaxiCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_JOINT_HOLDER_APPLICATION).getRecordTypeId();
                Id tenderCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TENDER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
                      
                if((caseId == NULL || caseId == '') && (applicantAccountId != null && applicantAccountId != '')) {
                    
                    
                    Account applicantAcc = [SELECT Record_Type_Dev_Name__c, ACN__c, ABN__c, Name, Document_Delivery_Preference__c, Notice_Email__c,
                                            Notice_Address_City__c, Notice_Address_Postal_Code__c, Notice_Address_Country__c, Notice_Address_State__c,
                                            Notice_Address_Street__c, Phone, Registered_Business_Name__c
                                            FROM Account
                                            WHERE Id = :applicantAccountId];
                                            
                    List<Case> parentTenderCase = [SELECT Status 
                                                    FROM Case
                                                    WHERE Record_Type_Dev_Name__c = :GlobalConstants.TENDER_CASE_RECORD_TYPE_DEV_NAME
                                                    AND Status = :GlobalConstants.CASE_NEW
                                                    ORDER BY CreatedDate DESC LIMIT 1];
                                                    
                    if(parentTenderCase.size() == 0) {
                     
                      Case newTenderCase = new Case();
                      newTenderCase.Subject = GlobalConstants.TAXI_LICENCE_TENDER;
                      newTenderCase.Description = GlobalConstants.TAXI_LICENCE_TENDER;
                      newTenderCase.Status = GlobalConstants.CASE_NEW;
                      newTenderCase.Sub_Status__c = GlobalConstants.CASE_DRAFT;
                      newTenderCase.RecordTypeId = tenderCaseRecordTypeId;
                      
                      insert newTenderCase;
                      
                      parentTenderCase.add(newTenderCase);
                    }
                    
                    Case newTaxiCase = new Case();
                    newTaxiCase.AccountId = applicantAccountId;
                    newTaxiCase.ACN__c = applicantAcc.ACN__c;
                    newTaxiCase.ABN__c = applicantAcc.ABN__c;
                    newTaxiCase.Preferred_method_of_comm_for_notice__c = applicantAcc.Document_Delivery_Preference__c;
                    newTaxiCase.Notice_Email__c = applicantAcc.Notice_Email__c;
                    newTaxiCase.Notice_Address_City__c = applicantAcc.Notice_Address_City__c;
                    newTaxiCase.Notice_Address_Country__c = applicantAcc.Notice_Address_Country__c;
                    newTaxiCase.Notice_Address_Postal_Code__c = applicantAcc.Notice_Address_Postal_Code__c;
                    newTaxiCase.Notice_Address_State__c = applicantAcc.Notice_Address_State__c;
                    newTaxiCase.Notice_Address_Street__c = applicantAcc.Notice_Address_Street__c;
                    newTaxiCase.Registered_Business_name__c = applicantAcc.Registered_Business_Name__c;
                    
                    if(applicantAcc.Phone != NULL && applicantAcc.Phone.length() > 10)
                     newTaxiCase.Daytime_phone_number__c = applicantAcc.Phone.substring(0, 10);
                    else
                     newTaxiCase.Daytime_phone_number__c = applicantAcc.Phone;
                     
                    newTaxiCase.Corporation_name__c = applicantAcc.Name;
                    newTaxiCase.Licence_Fee_Due__c = 0;
                    
                    newTaxiCase.Type = GlobalConstants.TAXI_CASE_TYPE;
                    newTaxiCase.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
                    newTaxiCase.Status = GlobalConstants.CASE_NEW;
                    newTaxiCase.Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT;
                    newTaxiCase.Subject = GlobalConstants.NEW_TAXI_APPLICATION_CASE_SUBJECT;
                    newTaxiCase.Description = GlobalConstants.NEW_TAXI_APPLICATION_CASE_SUBJECT;
                    newTaxiCase.ParentId = parentTenderCase[0].Id;
                    
                    if(applicantAcc.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION)
                        newTaxiCase.RecordTypeId = organisationTaxiCaseRecordTypeId;
                    
                    if(applicantAcc.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL)
                        newTaxiCase.RecordTypeId = individualTaxiCaseRecordTypeId;
                        
                    if(applicantAcc.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL_PARTNERSHIP
                       || applicantAcc.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP)
                        newTaxiCase.RecordTypeId = partnershipTaxiCaseRecordTypeId;
                    
                    this.currentCaseRec = newTaxiCase;
                }
                else if(caseId == NULL || caseId == '') {
                    
                    
                    List<Case> parentTenderCase = [SELECT Status 
                                                    FROM Case
                                                    WHERE Record_Type_Dev_Name__c = :GlobalConstants.TENDER_CASE_RECORD_TYPE_DEV_NAME
                                                    AND Status = :GlobalConstants.CASE_NEW
                                                    ORDER BY CreatedDate DESC LIMIT 1];
                                                    
                    if(parentTenderCase.size() == 0) {
                     
                      Case newTenderCase = new Case();
                      newTenderCase.Subject = GlobalConstants.TAXI_LICENCE_TENDER;
                      newTenderCase.Description = GlobalConstants.TAXI_LICENCE_TENDER;
                      newTenderCase.Status = GlobalConstants.CASE_NEW;
                      newTenderCase.Sub_Status__c = GlobalConstants.CASE_DRAFT;
                      newTenderCase.RecordTypeId = tenderCaseRecordTypeId;
                      
                      insert newTenderCase;
                      
                      parentTenderCase.add(newTenderCase);
                    }
                    
                    User loggedInUser = GlobalUtility.getLoggedInUser();
                    
                    Case newTaxiCase = new Case();
                    newTaxiCase.Title__c = loggedInUser.Contact.Salutation;
                    newTaxiCase.Family_name__c = loggedInUser.Contact.LastName;
                    newTaxiCase.First_given_name__c = loggedInUser.Contact.FirstName;
                    newTaxiCase.Birthdate__c = loggedInUser.Contact.Birthdate;
                    newTaxiCase.Email__c = loggedInUser.Contact.Email;
                    newTaxiCase.ACN__c = loggedInUser.Account.ACN__c;
                    newTaxiCase.ABN__c = loggedInUser.Account.ABN__c;
                    newTaxiCase.Corporation_name__c = loggedInUser.Account.Name;
                    newTaxiCase.Type = GlobalConstants.TAXI_CASE_TYPE;
                    newTaxiCase.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
                    newTaxiCase.Status = GlobalConstants.CASE_NEW;
                    newTaxiCase.Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT;
                    newTaxiCase.Subject = GlobalConstants.NEW_TAXI_APPLICATION_CASE_SUBJECT;
                    newTaxiCase.Description = GlobalConstants.NEW_TAXI_APPLICATION_CASE_SUBJECT;
                    newTaxiCase.ParentId = parentTenderCase[0].Id;
                    
                    newTaxiCase.AccountId = loggedInUser.AccountId;
                    newTaxiCase.ACN__c = loggedInUser.Account.ACN__c;
                    newTaxiCase.Preferred_method_of_comm_for_notice__c = loggedInUser.Account.Document_Delivery_Preference__c;
                    newTaxiCase.Notice_Email__c = loggedInUser.Account.Notice_Email__c;
                    newTaxiCase.Notice_Address_City__c = loggedInUser.Account.Notice_Address_City__c;
                    newTaxiCase.Notice_Address_Country__c = loggedInUser.Account.Notice_Address_Country__c;
                    newTaxiCase.Notice_Address_Postal_Code__c = loggedInUser.Account.Notice_Address_Postal_Code__c;
                    newTaxiCase.Notice_Address_State__c = loggedInUser.Account.Notice_Address_State__c;
                    newTaxiCase.Notice_Address_Street__c = loggedInUser.Account.Notice_Address_Street__c;
                    
                    if(loggedInUser.Account.Phone != NULL && loggedInUser.Account.Phone.length() > 10)
                     newTaxiCase.Daytime_phone_number__c = loggedInUser.Account.Phone.substring(0, 10);
                    else
                     newTaxiCase.Daytime_phone_number__c = loggedInUser.Account.Phone;
                    
                    newTaxiCase.Corporation_name__c = loggedInUser.Account.Name;
                    
                    if(loggedInUser.Account.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION)
                        newTaxiCase.RecordTypeId = organisationTaxiCaseRecordTypeId;
                    
                    if(loggedInUser.Account.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL)
                        newTaxiCase.RecordTypeId = individualTaxiCaseRecordTypeId;
                        
                     if(loggedInUser.Account.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL_PARTNERSHIP
                         || loggedInUser.Account.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP)
                        newTaxiCase.RecordTypeId = partnershipTaxiCaseRecordTypeId;
                    
                    this.currentCaseRec = newTaxiCase;
                }
                else {
                    
                    
                    this.currentCaseRec = [SELECT Id, AccountId, Status, Family_name__c,First_given_name__c,Other_given_name__c,Birthdate__c,
                                           Australian_Driver_Licence_Number__c,Australian_Driver_Licence_State__c,Daytime_phone_number__c,
                                           Email__c, Residential_Address_City__c, Residential_Address_State__c, Residential_Address_Postal_Code__c,
                                           Residential_Address_Street__c, Residential_Address_Country__c,Residential_International_Address__c,
                                           Notice_Address_City__c, Notice_Address_State__c, Notice_Address_Postal_Code__c, Notice_Address_Street__c, 
                                           Notice_Address_Country__c, Tender_Number__c, Licence_Type__c, Licence_Class__c, Operation_Area__c,
                                           Operating_Locations__c, Licence_Fee_Due__c, Levy_Due__c, SNSW_Plate_Pickup_Location__c, 
                                           Registered_business_name__c, ACN__c, ABN__c, Corporation_name__c, Nominated_Director_Info_Provided__c,
                                           Notice_Email__c, Is_Privacy_Statement_Declared__c, Apply_WAT_For_Existing_Licence__c, Existing_Taxi_Licence_Id__c,
                                           Sub_Status__c, Individual_Partnership_Info_Provided__c, Is_WAT_Application__c, Information_Declaration__c,
                                           Proof_Of_Identity_Documents__c, Title__c, Authorise_On_Behalf_Of_Partnership__c, Existing_Plate_Number__c,
                                           Existing_Expiring_Licence__c, Tender_Bid_Number__c, ContactId, Contact.Name
                                           FROM Case WHERE Id = :caseId];
                }
            }
            catch(Exception e) {
                
                System.debug('Exception: '+e);
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiSectionDataWrapper', 'loadCaseSectionData', e.getMessage(), e);
            }
        }
    }