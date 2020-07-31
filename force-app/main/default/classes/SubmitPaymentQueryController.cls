public with sharing class SubmitPaymentQueryController {
    
   @AuraEnabled
    public static SubmitPaymentWrapper initCaseRecord(String paymentID, String caseID){
        
    	SubmitPaymentWrapper wrpObj;
    	try{
    		User loggedInUser = GlobalUtility.getLoggedInUser();
            
            // Check for Existing Draft or Lodged case
            Case csObj = null;
            List<Case> casesList = new List<Case>();
            if(caseID != null) {
                
                casesList = [SELECT Id, RecordTypeID, Payment__c, Subject, ContactId, AccountId, Status, Sub_Status__c, 
                                        Description, Internal_Review_Supporting_Documents__c, Date_Submitted__c, Type, Sub_Type__c
                                        FROM Case 
                                        WHERE Id =: caseID
                                        AND (Status = 'Draft' OR Status = 'Lodged')];
            }
            
            if(casesList.size() > 0) {
                csObj = casesList.get(0);
            } else {
                
                Order ordObj = [Select Payment_Reference__c FROM Order WHERE Id = :paymentID limit 1];
                
                csObj = new Case();
                csObj.RecordTypeID = [SELECT Id FROM RecordType WHERE DeveloperName = : GlobalConstants.CASE_RECORDTYPE_CUSTOMER_ENQUIRY_DEVNAME].Id;
                csObj.Payment__c = paymentID;
                csObj.Subject = 'Query for Authorisation Fee Payment '+ordObj.Payment_Reference__c;
                csObj.ContactId = loggedInUser.Contact.Id;
                csObj.AccountId = loggedInUser.Contact.AccountId;
                csObj.Status = 'Draft';
                csObj.Sub_Status__c = 'Assessment Pending';
                csObj.Description = '';
                csObj.Internal_Review_Supporting_Documents__c = false;
                csObj.Date_Submitted__c = Date.Today();
                csObj.Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE;
                csObj.Sub_Type__c = GlobalConstants.CUSTOMER_ENQUIRY_SUB_TYPE;
            }
            wrpObj = new SubmitPaymentWrapper(csObj, 'Success', true);            
    	}catch(Exception e){
            system.debug('Exception');
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
    		wrpObj = new SubmitPaymentWrapper(null, e.getMessage(), false); 		
    	}
    	return wrpObj;
    }
    
     @AuraEnabled
    public static SubmitPaymentWrapper upsertCaseRecord(String jsonStr){
    	SubmitPaymentWrapper wrpObj;
    	try{
    		wrpObj = (SubmitPaymentWrapper)JSON.deserialize(jsonStr, SubmitPaymentWrapper.Class);
    		upsert wrpObj.csObj;
            wrpObj = new SubmitPaymentWrapper(wrpObj.csObj, 'Success', true);  
            Boolean alreadyHasDocs = checkDocumentsUploadedOrNot(wrpObj.csObj.Id);
            wrpObj.csObj.Internal_Review_Supporting_Documents__c =  alreadyHasDocs;  
            wrpObj.caseAlreadyHasDocuments = alreadyHasDocs;
            
            // We need Case number to be display on UI
            Case caseRec = [SELECT Id, CaseNumber FROM Case WHERE Id =: wrpObj.csObj.Id];
            wrpObj.caseNumber = caseRec.CaseNumber;
            
    	}catch(Exception e){
    		wrpObj = new SubmitPaymentWrapper(null, e.getMessage(), false);   		
    	}
    	return wrpObj;
    }
    
    @AuraEnabled
    public static Boolean checkDocumentsUploadedOrNot(String caseID){
    	Boolean check = false;
		list<Attachment> attachmentObj = [SELECT Id FROM Attachment WHERE parentId = :caseID];
        if(attachmentObj.size() > 0){
        	check = true; 
        } 
        return check;    	
    }
    
    public class SubmitPaymentWrapper{
    	
    	@AuraEnabled
    	public Case csObj{get;set;}
    	@AuraEnabled
    	public String message{get;set;}
    	@AuraEnabled
    	public Boolean isSuccess{get;set;}
    	@AuraEnabled
    	public Boolean caseAlreadyHasDocuments{get;set;}
         @AuraEnabled
    	public String caseNumber{get;set;}
    	
    	public SubmitPaymentWrapper(Case csObj, string message, Boolean isSuccess){
    		this.csObj = csObj;
    		this.message = message;
    		this.isSuccess = isSuccess;
    		this.caseAlreadyHasDocuments = false;
    	}
    }
}