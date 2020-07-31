/*
*/
public with sharing class InternalReviewAppFormController {
    
    private static set<String> validAuthorisationStatusForASP =  new set<String>{GlobalConstants.GRANTED_CONDITIONALLY, 
                                                                                 GlobalConstants.GRANTED_UNCONDITIONALLY,
                                                                                 GlobalConstants.AUTHORISATION_SUSPENDED, 
                                                                                 GlobalConstants.AUTHORISATION_STATUS_CANCELLED,
                                                                                 GlobalConstants.AUTHORISATION_STATUS_REFUSED
                                                                                };
    private static set<String> validAuthorisationStatusForTaxi =  new set<String>{GlobalConstants.AUTHORISATION_SUSPENDED, 
                                                                                  GlobalConstants.AUTHORISATION_STATUS_CANCELLED,
                                                                                  GlobalConstants.AUTHORISATION_GRANTED
                                                                                 }; 
    
    @AuraEnabled
    public static InternalReviewAppWrapper getAuthorisationDetails(String authorisationID, String portalContextName){
        list<Case> reviewableDecisionCases = new list<Case>();
        InternalReviewAppWrapper interReviewWrap = new InternalReviewAppWrapper();
        interReviewWrap.portalContextName = portalContextName;
        set<String> caseStatusValues = new Set<String>{GlobalConstants.CASE_DRAFT};
        Authorisation__c authorisationObj = new Authorisation__c();
        
        try{
    
            // fetch logged in user's account and contact details
            User userDetails = [SELECT Id, Name, FirstName, Contact.LastName, Contact.MailingCity, Contact.MailingState,  
                                       Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingStreet, Contact.Email, 
                                       Contact.Phone, Contact.Account.Name, Contact.AccountId, Contact.MailingAddress, Contact.Name                                                                          
                                FROM User
                                WHERE ID = : UserInfo.getUserId() limit 1
                               ];
                   
            interReviewWrap.userObj = userDetails;
            interReviewWrap.contact = userDetails.Contact;
            interReviewWrap.accountName = userDetails.Contact.Account.Name;
            interReviewWrap.userAddress = getFormattedAddress(userDetails.Contact);
            
            // Fetch Authorisation details using authorisation number
            if(String.isNotBlank(authorisationID)){

                /*
                 * If selected record is of type case then we need to fetch the corresponding authorisation. 
                 * This is required when we open the lodged/draft cases under Activity section
                */
                if(Id.valueof(authorisationID).getSObjectType().getDescribe().getName() == 'Case'){
                    caseStatusValues.add(GlobalConstants.LODGED_CASE_STATUS);
                    reviewableDecisionCases = [SELECT Id, CaseNumber, Status, Date_of_Original_Decision__c, Ground_For_Review__c,Internal_Review_Supporting_Documents__c,
                                                             Decision_Description__c  , Authorisation__c,  Authorisation__r.Name, Information_Declaration__c, Is_Privacy_Statement_Declared__c, 
                                                             Date_Submitted__c, Internal_Review_Copy_of_Decision__c
                                               FROM Case
                                               WHERE Id = : authorisationID AND
                                                    Status IN : caseStatusValues AND RecordType.DeveloperName = : GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS_DEVNAME 
                                              ];                        
                }else if(Id.valueof(authorisationID).getSObjectType().getDescribe().getName() == 'Authorisation__c'){
                    reviewableDecisionCases = [SELECT Id, CaseNumber, Status, Date_of_Original_Decision__c, Ground_For_Review__c,Internal_Review_Supporting_Documents__c,
                                                             Decision_Description__c  , Authorisation__c, Information_Declaration__c, Is_Privacy_Statement_Declared__c, Date_Submitted__c, Internal_Review_Copy_of_Decision__c
                                               FROM Case
                                               WHERE Authorisation__c = : authorisationID AND
                                                     Status IN : caseStatusValues AND RecordType.DeveloperName = : GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS_DEVNAME 
                                              ];
                    authorisationObj = [SELECT Id, Name, Status__c FROM Authorisation__c 
                                        WHERE Id = :authorisationID limit 1];
                   interReviewWrap.authorisationNumber          = authorisationObj.Name;
                   interReviewWrap.isAuthorisationNumberValid   = true;
                   interReviewWrap.authorisationRecordID        = authorisationObj.Id; 
                }
                
                
                // If record ID provided is for Case object then we need to get detail for Authorisation from Case
                if(String.isBlank(interReviewWrap.authorisationNumber) && reviewableDecisionCases.size() > 0){
                    interReviewWrap.authorisationNumber = reviewableDecisionCases[0].Authorisation__r.Name;
                    interReviewWrap.isAuthorisationNumberValid = true;
                    interReviewWrap.authorisationRecordID = reviewableDecisionCases[0].Authorisation__c;
                }                                                                  
            }
            
            // check if case is present for this authorisation                                    
            if(reviewableDecisionCases.size() > 0)  {
                interReviewWrap.csObj = reviewableDecisionCases[0];
                interReviewWrap.decisionCopy = reviewableDecisionCases[0].Internal_Review_Copy_of_Decision__c;
                list<Attachment> attachmentObj = [SELECT Id FROM Attachment WHERE parentId = : interReviewWrap.csObj.Id];                   
                if(attachmentObj.size() > 0){
                    interReviewWrap.caseAlreadyHasDocuments = true;
                }
            }else{
                interReviewWrap.csObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS).getRecordTypeId();                        
                if(portalContextName == 'ASP'){
                    interReviewWrap.csObj.Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE;
                }else{
                    interReviewWrap.csObj.Type = GlobalConstants.INVOCATION_CONTEXT_TAXI;
                }
                interReviewWrap.csObj.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_INTERNAL_REVIEW;     
                interReviewWrap.csObj.status = GlobalConstants.CASE_DRAFT;  
                interReviewWrap.csObj.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;  
                interReviewWrap.csObj.Origin = GlobalConstants.CASE_ORIGIN_WEB;
                interReviewWrap.csObj.Information_Declaration__c = false;
                interReviewWrap.csObj.Is_Privacy_Statement_Declared__c = false;  
                interReviewWrap.csObj.Internal_Review_Supporting_Documents__c = false;
                interReviewWrap.csObj.Date_Submitted__c = null;
                interReviewWrap.csObj.Date_of_Original_Decision__c = null;
                interReviewWrap.csObj.Internal_Review_Copy_of_Decision__c  = false;
            }   
                             
        }catch(Exception e){
            interReviewWrap.isSuccess = false;
            interReviewWrap.message = e.getMessage();
        }                              
        return interReviewWrap;                                   
    }
    
    @AuraEnabled
    public static InternalReviewAppWrapper saveSectionData(String jsonStr){
        InternalReviewAppWrapper interReviewWrap;
        try{
            interReviewWrap = (InternalReviewAppWrapper)JSON.deserialize(jsonStr, InternalReviewAppWrapper.Class);
            
            // if Authorisation number is valid and Authorisation record ID is not null then do not check for validations
            if(interReviewWrap.isAuthorisationNumberValid == true && String.isNotBlank(interReviewWrap.authorisationRecordID)){
                interReviewWrap.isAuthorisationNumberValid  = true;
                interReviewWrap.csObj.Authorisation__c      = interReviewWrap.authorisationRecordID;
                interReviewWrap.csObj.Internal_Review_Copy_of_Decision__c = interReviewWrap.decisionCopy;
                interReviewWrap.csObj.Subject 		= 'Internal Review for '+interReviewWrap.authorisationNumber;
           		interReviewWrap.csObj.Description 	= 'Internal Review for '+interReviewWrap.authorisationNumber;
            //reviewableDecisionCases[0].Authorisation__r.Name;
                upsert interReviewWrap.csObj;
            }else{
                list<Authorisation__c> authorisationObjs = [SELECT Id, Service_Provider__c,Status__c FROM Authorisation__c 
                                                            WHERE Name = : interReviewWrap.authorisationNumber order by createdDate DESC
                                                           ];                                                       
                if(authorisationObjs.size() == 0){
                    interReviewWrap.isSuccess = false;
                    if(interReviewWrap.portalContextName.equalsIgnoreCase('ASP')){
                        interReviewWrap.message = 'Please enter the valid Authorisation number';
                    }else{
                        interReviewWrap.message = 'Please enter the valid Taxi License number';
                    }
                }else if(authorisationObjs[0].Service_Provider__c != interReviewWrap.userObj.Contact.AccountId){
                    interReviewWrap.isSuccess = false;
                    interReviewWrap.message = 'Entered authorisation number does not belong to account '+interReviewWrap.userObj.Contact.Account.Name;
                }else if(interReviewWrap.portalContextName.equalsIgnoreCase('ASP') && validAuthorisationStatusForASP.contains(authorisationObjs[0].Status__c) == false){
                    interReviewWrap.isSuccess = false;
                    interReviewWrap.message = 'Please enter the valid Authorisation number';
                }else if(interReviewWrap.portalContextName.equalsIgnoreCase('TAXI') && validAuthorisationStatusForTaxi.contains(authorisationObjs[0].Status__c) == false){
                    interReviewWrap.isSuccess = false;
                    interReviewWrap.csObj.Type = 'Taxi';
                    interReviewWrap.message = 'Please enter the valid Taxi License number';
                }else{
                    interReviewWrap.isAuthorisationNumberValid = true;
                    interReviewWrap.csObj.Authorisation__c = authorisationObjs[0].Id;
                    interReviewWrap.authorisationRecordID = authorisationObjs[0].Id;
                    upsert interReviewWrap.csObj;
                }               
            }   
        }catch(Exception e){
            interReviewWrap.isSuccess = false;
            interReviewWrap.message = e.getMessage()+' == '+e.getLineNumber();
        }
        return interReviewWrap;
    }
    
    @AuraEnabled
    public static InternalReviewAppWrapper submitReviewApplication(String jsonStr){
        InternalReviewAppWrapper interReviewWrap;
        try{
            interReviewWrap = (InternalReviewAppWrapper)JSON.deserialize(jsonStr, InternalReviewAppWrapper.Class);
            interReviewWrap.csObj.Status = GlobalConstants.LODGED_CASE_STATUS;
            interReviewWrap.csObj.Date_Submitted__c = Date.today();
            update interReviewWrap.csObj;
            
            Case csObjNew = [Select Id, CaseNumber from Case where Id =: interReviewWrap.csObj.Id];
            interReviewWrap.caseNumber = csObjNew.CaseNumber;
        }catch(Exception e){
            interReviewWrap.isSuccess = false;
            interReviewWrap.message = e.getMessage()+' == '+e.getLineNumber();
        }
        return interReviewWrap;
    }
    
    @AuraEnabled
    public static Boolean attachmentUploadedCheck(String caseId){
        Boolean check = false;
        list<Attachment> attachmentObj = [SELECT Id FROM Attachment WHERE parentId = :caseId];
        if(attachmentObj.size() > 0){
            check = true; 
        } 
        return check;
    } 

    @AuraEnabled
    public static InternalReviewAppWrapper getAuthorisationDetailsForAccount(String accountID){
        list<Case> reviewableDecisionCases = new list<Case>();
        InternalReviewAppWrapper interReviewWrap = new InternalReviewAppWrapper();
        set<String> caseStatusValues = new Set<String>{GlobalConstants.CASE_DRAFT};
        Authorisation__c authorisationObj = new Authorisation__c();
        
        interReviewWrap.csObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS).getRecordTypeId();                        
        interReviewWrap.csObj.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_INTERNAL_REVIEW;     
        interReviewWrap.csObj.status = GlobalConstants.CASE_DRAFT;  
        interReviewWrap.csObj.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;  
        interReviewWrap.csObj.Origin = GlobalConstants.CASE_ORIGIN_CONSOLE;
        interReviewWrap.csObj.Information_Declaration__c = false;
        interReviewWrap.csObj.Is_Privacy_Statement_Declared__c = false;  
        interReviewWrap.csObj.Internal_Review_Supporting_Documents__c = false;
        interReviewWrap.csObj.Date_Submitted__c = Date.today();
        interReviewWrap.csObj.Date_of_Original_Decision__c = null;
        interReviewWrap.portalContextName = '';
        interReviewWrap.csObj.accountId = accountID;
        interReviewWrap.csObj.type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE;
        
        try{
            PrimaryContactRetriever conRetriever = new PrimaryContactRetriever(new Set<Id>{accountID});
            Id contactId = conRetriever.identifyPrimaryContact(accountID);
            
            List<Contact> contacts = [SELECT Id, Name, FirstName, LastName, MailingCity,MailingState, 
                                            MailingCountry, MailingPostalCode, MailingStreet, Email, Phone, Account.Name 
                                    FROM Contact WHERE Id = :contactId];
                                    
            interReviewWrap.csObj.contactId     = contactId;
            interReviewWrap.contact 			= contacts.isEmpty()? new Contact():contacts[0];
            interReviewWrap.userAddress 		= getFormattedAddress(interReviewWrap.contact);
            interReviewWrap.accountName 		= contacts.isEmpty()? '': contacts[0].Account.Name;
        }catch(Exception e){
            interReviewWrap.isSuccess = false;
            interReviewWrap.message = e.getMessage();
        }
        return interReviewWrap;
    }    
    
    @AuraEnabled
    public static String getAuthorisationType(String authorisationID){
        system.debug('abc');
        system.debug(authorisationID);
        Authorisation__c authRec= [select Id ,Authorisation_Type__c from Authorisation__C where Id =:authorisationID];
        system.debug(authRec.Authorisation_Type__c);
        return authRec.Authorisation_Type__c;
    }
    
    /*@AuraEnabled
    public static Case getCaseDetails(String caseId){
        Case caseObj = [Select Id, CaseNumber from Case where Id =:caseId];
        return caseObj;
    }*/
    
    @AuraEnabled
    public static boolean getValidateUser()
    {
        /*-------- this step is to  verify current User logged in is authorised for case creation  or not ---------*/
        string result;
        List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId
                                                              FROM PermissionSetAssignment
                                                              WHERE AssigneeId = :Userinfo.getUserId()];
        system.debug('##lstcurrentUserPerSet' + lstcurrentUserPerSet);
        boolean isUserAuthorized = false;
        
        for (PermissionSetAssignment psa: lstcurrentUserPerSet)
        {
            system.debug('##psa.PermissionSet.Name  is' + psa.PermissionSet.Name);
            if(psa.PermissionSet.Name.equals('Sanctions_Operations_Staff')){
                isUserAuthorized = true;
                system.debug('isuserauthorised'+isUserAuthorized);
            }
        }
        return isUserAuthorized;
    }
  
    public class InternalReviewAppWrapper{
        @AuraEnabled
        public Case csObj{get;set;}
        @AuraEnabled
        public User userObj{get;set;}
        @AuraEnabled
        public String authorisationNumber{get;set;} 
        @AuraEnabled
        public String authorisationRecordID{get;set;} 
        @AuraEnabled
        public Boolean isAuthorisationNumberValid{get;set;} 
        @AuraEnabled
        public Boolean decisionCopy{get;set;}       
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public String portalContextName{get;set;}
        @AuraEnabled
        public Boolean caseAlreadyHasDocuments{get;set;}
        @AuraEnabled
        public String userAddress{get;set;}
        @AuraEnabled
        public String caseNumber{get;set;}
        @AuraEnabled
        public Contact contact {get; set;}
        @AuraEnabled
        public String accountName {get; set;}
        
        public InternalReviewAppWrapper(){
            csObj = new Case();
            isSuccess = true;
            authorisationNumber = null;
            isAuthorisationNumberValid = false;
            portalContextName = GlobalConstants.INVOCATION_CONTEXT_ASP;
            authorisationRecordID = null;
            decisionCopy = false;
            caseAlreadyHasDocuments = false;
            userAddress = '';
            caseNumber = '';
            accountName = '';
            contact = new Contact();
        }
    }
    
    private static String getFormattedAddress(Contact con){
        String address = '';
        if(con == null) return address;
        address += formatData(con.MailingStreet, ', ');
        address += formatData(con.MailingCity, ', ');
        address += formatData(con.MailingState, ', ');
        address += formatData(con.MailingCountry, '');
        address = address.trim();
        address = address.endswith(',')? address.substring(0, address.length() - 1): address;
        return address;
    }
    
    private static String formatData(String data, String delimiter){
        return String.isBlank(data)? '': data + delimiter;
    }
    
    public class AuthorisationWrapper{
        @AuraEnabled
        public String authorisationNumber{get;set;} 
        @AuraEnabled
        public String authorisationRecordID{get;set;} 
        @AuraEnabled
        public Boolean isAuthorisationNumberValid{get;set;} 
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public String message{get;set;}
        
        public AuthorisationWrapper(){
            authorisationNumber = null;
            authorisationRecordID = null;
            isAuthorisationNumberValid = false;
            isSuccess = true;
        }
    }
    
    @AuraEnabled
    public static AuthorisationWrapper getAuthorisationDetailsbyId(String authorisationNumber){ 
        AuthorisationWrapper authWrap = new AuthorisationWrapper();       
        try{
            Authorisation__c authorisationObjs 		= [Select Id, Name from Authorisation__c where Name =: authorisationNumber order by createdDate DESC Limit 1];
            authWrap.authorisationNumber 			= authorisationObjs.Name;
            authWrap.authorisationRecordID 			= authorisationObjs.Id;
            authWrap.isAuthorisationNumberValid 	= true;
        }catch(Exception e){
            authWrap.isSuccess = false;
            authWrap.message = e.getMessage(); 
        }
        return authWrap;
    }
}