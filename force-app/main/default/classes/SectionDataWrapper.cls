/**
* Data Struture to serialize Case 
*/
public class SectionDataWrapper {
        
        public Case currentCaseRec;
        
        @TestVisible
        private String caseId;
        
        @TestVisible
        private String accountId;
        
        public SectionDataWrapper(String caseId, String accountId) {
            
            this.caseId = caseId;
            this.accountId = accountId;
        }
        
        public void loadCaseSectionData() {
            try{  
                
                System.debug('Case Id: '+caseId);
                
                Id individualASPCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
                Id organisationASPCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_CORPORATION).getRecordTypeId();
                Id partnershipASPCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_PARTNERSHIP).getRecordTypeId();
                
                if(accountId != NULL && accountId != '' && (caseId == NULL || caseId == '')) {
                    
                    Account applicantAcc = [SELECT Record_Type_Dev_Name__c, ACN__c, ABN__c, Name, Document_Delivery_Preference__c, Notice_Email__c,
                                            Notice_Address_City__c, Notice_Address_Postal_Code__c, Notice_Address_Country__c, Notice_Address_State__c,
                                            Notice_Address_Street__c, Phone, 
                                            BillingCity, BillingState, BillingCountry, BillingStreet, BillingPostalCode, 
                                            ShippingCity, ShippingState, ShippingCountry, ShippingStreet, ShippingPostalCode, 
                                            Registered_Business_Name__c,
                                            Business_Name_For_Customer_Contact__c, Daytime_Phone_No_For_Customer_Contact__c, Email_For_Customer_Contact__c, 
                                            Other_Details_For_Customer_Contact__c, Social_Media_For_Customer_Contact__c, Website_For_Customer_Contact__c,Notice__Latitude__s,Notice__Longitude__s
                                            FROM Account
                                            WHERE Id = :accountId];
                    
                    Case newASPCase = new Case();    
                    newASPCase.AccountId = accountId;   
                    
                    //newASPCase.ACN__c = applicantAcc.ACN__c;
                    newASPCase.ABN__c = applicantAcc.ABN__c;
                    //newASPCase.Corporation_name__c = applicantAcc.Name;
                    
                    newASPCase.Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE;
                    newASPCase.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
                    newASPCase.Status = GlobalConstants.APPLICATION_STATUS_DRAFT;
                    newASPCase.Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT;
                    newASPCase.Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT;
                    newASPCase.Preferred_method_of_comm_for_notice__c = applicantAcc.Document_Delivery_Preference__c;
                    newASPCase.Business_Address_City__c = applicantAcc.ShippingCity;
                    newASPCase.Business_Address_State__c = applicantAcc.ShippingState;
                    newASPCase.Business_Address_Country__c = applicantAcc.ShippingCountry;
                    newASPCase.Business_Address_Street__c = applicantAcc.ShippingStreet;
                    newASPCase.Business_Address_Postal_Code__c = applicantAcc.ShippingPostalCode;
                    newASPCase.Registered_business_name__c = applicantAcc.Registered_Business_Name__c;
                    newASPCase.Notice_Email__c = applicantAcc.Notice_Email__c;
                    newASPCase.Notice_Address_City__c = applicantAcc.Notice_Address_City__c;
                    newASPCase.Notice_Address_Country__c = applicantAcc.Notice_Address_Country__c;
                    newASPCase.Notice_Address_Postal_Code__c = applicantAcc.Notice_Address_Postal_Code__c;
                    newASPCase.Notice_Address_State__c = applicantAcc.Notice_Address_State__c;
                    newASPCase.Notice_Address_Street__c = applicantAcc.Notice_Address_Street__c;
                    newASPCase.Record_Keeping_City__c = applicantAcc.BillingCity;
                    newASPCase.Record_Keeping_Country__c = applicantAcc.BillingCountry;
                    newASPCase.Record_Keeping_Street__c = applicantAcc.BillingStreet;
                    newASPCase.Record_Keeping_State__c = applicantAcc.BillingState;
                    newASPCase.Record_Keeping_Postal_Code__c = applicantAcc.BillingPostalCode;
                    newASPCase.Business_Name_For_Customer_Contact__c = applicantAcc.Business_Name_For_Customer_Contact__c;
                    newASPCase.Daytime_Phone_No_For_Customer_Contact__c = applicantAcc.Daytime_Phone_No_For_Customer_Contact__c;
                    newASPCase.Email_For_Customer_Contact__c = applicantAcc.Email_For_Customer_Contact__c;
                    newASPCase.Other_Details_For_Customer_Contact__c = applicantAcc.Other_Details_For_Customer_Contact__c;
                    newASPCase.Social_Media_For_Customer_Contact__c = applicantAcc.Social_Media_For_Customer_Contact__c;
                    newASPCase.Website_For_Customer_Contact__c = applicantAcc.Website_For_Customer_Contact__c;
                    
                    if(applicantAcc.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION)
                        newASPCase.RecordTypeId = organisationASPCaseRecordTypeId;
                    
                    if(applicantAcc.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL)
                        newASPCase.RecordTypeId = individualASPCaseRecordTypeId;
                    
                    if(applicantAcc.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL_PARTNERSHIP
                       || applicantAcc.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP) {
                        newASPCase.RecordTypeId = partnershipASPCaseRecordTypeId;                         
                        newASPCase.Partnership_Name__c = applicantAcc.Name;   
                    }
                    
                    this.currentCaseRec = newASPCase;
                }
                else if(caseId == NULL || caseId == '') {
                    
                    User loggedInUser = GlobalUtility.getLoggedInUser();
                    
                    Case newASPCase = new Case();
                    newASPCase.Title__c = loggedInUser.Contact.Salutation;
                    newASPCase.Family_name__c = loggedInUser.Contact.LastName;
                    newASPCase.First_given_name__c = loggedInUser.Contact.FirstName;
                    newASPCase.Birthdate__c = loggedInUser.Contact.Birthdate;
                    newASPCase.Email__c = loggedInUser.Contact.Email;
                    newASPCase.ACN__c = loggedInUser.Account.ACN__c;
                    newASPCase.ABN__c = loggedInUser.Account.ABN__c;
                    newASPCase.Registered_business_name__c = loggedInUser.Account.Registered_Business_Name__c;
                    newASPCase.Corporation_name__c = loggedInUser.Account.Name;
                    newASPCase.Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE;
                    newASPCase.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
                    newASPCase.Status = GlobalConstants.APPLICATION_STATUS_DRAFT;
                    newASPCase.Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT;
                    newASPCase.Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT;
                    
                    if(loggedInUser.Account.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION)
                        newASPCase.RecordTypeId = organisationASPCaseRecordTypeId;
                    
                    if(loggedInUser.Account.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL)
                        newASPCase.RecordTypeId = individualASPCaseRecordTypeId;
                    
                    if(loggedInUser.Account.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL_PARTNERSHIP
                       || loggedInUser.Account.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP) {
                        
                        newASPCase.RecordTypeId = partnershipASPCaseRecordTypeId;
                        newASPCase.Partnership_Name__c = loggedInUser.Account.Name;
                    }
                    
                    this.currentCaseRec = newASPCase;
                }
                else {
                    
                    
                    this.currentCaseRec = [SELECT Title__c, Family_name__c, First_given_name__c, Other_given_name__c, Birthdate__c,
                                           Australian_Driver_Licence_Number__c, Australian_Driver_Licence_State__c,  Daytime_phone_number__c,
                                           Email__c, Corporation_name__c, ABN__c,ACN__c, Registered_business_name__c,
                                           Ever_been_known_by_another_name__c, Other_Name_Details__c,
                                           Has_convicted_or_disqualifying_offence__c, Disqualifying_Offence_Details__c, 
                                           Is_current_authorized_service_provider__c, Current_ASP_Details__c,
                                           Is_authorized_to_complete_application__c, Does_ASP_have_additional_standards__c, Application_Completion_Auth_Details__c, 
                                           Has_authorization_subject_to_action__c, Auth_Action_Details__c,
                                           Has_had_authorization_refused__c, Auth_Refusal_Details__c,ASP_Nominated_Person_Disqualify_Details__c,
                                           Has_associate_disqualifying_offence__c, Associate_Disqualifying_Offence_Details__c,
                                           Has_associate_not_of_good_repute__c, Associate_Not_Good_Repute_Details__c,ASP_Nominated_Person_Convicted_Details__c,
                                           Business_Address_City__c, Business_Address_Country__c, Business_Address_Postal_Code__c, Business_Address_State__c,
                                           Business_Address_Street__c, Business_International_Address__c, Notice_Address_City__c, Notice_Address_Country__c,
                                           Notice_Address_Postal_Code__c, Notice_Address_State__c, Notice_Address_Street__c, 
                                           Notice_Email__c, Service_Type__c, Is_International_Business_Address__c,
                                           Residential_Address_City__c, Residential_Address_State__c, Residential_Address_Postal_Code__c, 
                                           Residential_Address_Street__c, Residential_Address_Country__c, Residential_International_Address__c, Registered_Office_Address_Street__c,Registered_Office_Address_City__c,
                                           Registered_Office_Address_State__c,Registered_Office_Address_Postal_Code__c,Registered_Office_Address_Country__c,
                                           Registered_Office_International_Address__c,Is_Nominee_of_Good_repute__c, Is_Privacy_Statement_Declared__c,
                                           Record_Keeping_City__c, Record_Keeping_Country__c, Record_Keeping_Postal_Code__c, Record_Keeping_State__c, Record_Keeping_Street__c,
                                           ASP_additional_standard_details__c, Nominee_Not_of_Good_Repute_Details__c, Close_Associate_Info_Provided__c,
                                           Preferred_method_of_comm_for_notice__c, Nominated_Director_Info_Provided__c, Sub_Status__c, Individual_Partnership_Info_Provided__c,
                                           Business_Name_For_Customer_Contact__c, Daytime_Phone_No_For_Customer_Contact__c, Website_For_Customer_Contact__c,
                                           Email_For_Customer_Contact__c, Social_Media_For_Customer_Contact__c, Other_Details_For_Customer_Contact__c, Business_Contact_Type__c,
                                           Resided_In_Australia_For_Past_5_Years__c, Country_Stayed_During_Last_5_Years__c, DVD_Access_Needed__c,
                                           Information_Declaration__c, Proof_Of_Identity_Documents__c, Proof_Of_National_Police_Check__c, Proof_Of_Police_Certificate_From_Country__c,
                                           Website__c, Proof_Of_Company_Extract__c, Number_Type__c, Partnership_Hold_An_ABN__c, Partnership_Name__c, Authorise_On_Behalf_Of_Partnership__c,
                                           Is_Complex_Application__c,Notice__Latitude__s,Notice__Longitude__s
                                           FROM Case WHERE Id = :caseId];
                    
                }
            }
            catch(Exception e) {
                
                System.debug('Exception: '+e);
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'SectionDataWrapper', 'loadCaseSectionData', e.getMessage(), e);
                
            }
        }
    }