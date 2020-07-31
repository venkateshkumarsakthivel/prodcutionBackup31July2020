//Test Class Name : TaxiLicenceTrasferInviteBuyerTest
public with sharing class TaxiLicenceTrasferInviteBuyerController {
    
    @AuraEnabled
    public static String inviteBuyer(Id caseId) {
        
        try {
            
            Case buyerCase = [SELECT Id, CaseNumber, Record_Type_dev_Name__c, Levy_Due__c, Licence_Market_Value__c, 
                              ContactId, AccountId, ParentId, Authorisation__c , Account.Notice_Email__c, Send_Party_B_Emails__c, Account.Name
                              FROM Case WHERE Id =: caseId];
        
            Case sellerCase = [SELECT Id, CaseNumber, Sub_Status__c FROM Case WHERE Id =: buyerCase.ParentId];
            
            // 1 - Update both case sub status as pending payment
            sellerCase.Sub_Status__c = GlobalConstants.PENDING_PAYMENT_SUB_STATUS;
            update sellerCase;
            
            // 2 -  Send an e-mail to the Transfer - Proposed Owner notification e-mail -  
            // (Transfer e-mail goes to the Account notification address)
            // 2.1 - Set Case Notice Email same as Account Notice Email
            // 2.2 - Set Send_Taxi_Transfer_Invite_Buyer_Email__c = true to invoke workflow
            // Update buyer case (Only to trigger email)
            buyerCase.Sub_Status__c = GlobalConstants.PENDING_PAYMENT_SUB_STATUS;
            buyerCase.Notice_Email__c = buyerCase.Account.Notice_Email__c;
            //buyerCase.Send_Taxi_Transfer_Invite_Buyer_Email__c = true; //Removed this logic by BAU team for ticket P2PSUPPORT-22 
            buyerCase.Status = GlobalConstants.CASE_DRAFT;
            
            //create a new copy of licence been transferred.
            TransferLicenceCreator licenceCreator = new TransferLicenceCreator(buyerCase);
            Authorisation__c licence = licenceCreator.create();
            
            if(!String.isBlank(licence.Agency__c) && !String.isBlank(licence.Agreement_Type__c)){
                
                licence.Agreement_Type__c = GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE;
                update licence;
                
                Authorisation_Agent__c authAgent = [SELECT Id,Account__c,Agreement_Type__c,Approved_Date__c,
                                                    Expiry_Date__c,Authorisation__c,Status__c 
                                                    FROM Authorisation_Agent__c 
                                                    WHERE Authorisation__c =: buyerCase.Authorisation__c AND Status__c=: GlobalConstants.MASTER_CONDITION_ACTIVE];
                
                Authorisation_Agent__c newAuthAgent = new Authorisation_Agent__c();
                newAuthAgent.Account__c = authAgent.Account__c;
                newAuthAgent.Agreement_Type__c = GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE;
                newAuthAgent.Approved_Date__c = system.today();
                newAuthAgent.Expiry_Date__c = NULL;
                newAuthAgent.Authorisation__c = licence.Id;
                newAuthAgent.Status__c = GlobalConstants.MASTER_CONDITION_ACTIVE;
                insert newAuthAgent;
            }
            
            buyerCase.Authorisation__c = licence.Id;
            update buyerCase;
            
            //create payment record for transfer levy to be paid by buyer
            TransferLevyPaymentCreator paymentCreator = new TransferLevyPaymentCreator(buyerCase);
            paymentCreator.create();
            
            //create portal user for buyer if one doesn't exists
            if(buyerCase.Send_Party_B_Emails__c == true){
                
                InviteApplicantHelper helper = new InviteApplicantHelper(new List<Case>{buyerCase});
                helper.invite();   
            }
            
            
            return 'SUCCESS';            
        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getStacktraceString());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,
                                             'TaxiLicenceTrasferInviteBuyerController','inviteBuyer',ex.getMessage(),ex);
            return null;  
        }  
    }
    
    // Modified on 18 Nov 2019 by Venkatesh:  P2PSUPPORT-255 : Expected Transfer process
    // This method just retriggers the email to the end user, doesnt not do the other functions as inviteBuyer method
    
    @AuraEnabled
    public static String retriggerInviteBuyerEmail(Id caseId){
        Case cas = new case (id=caseId);
        cas.Send_Party_B_Emails__c = false;
        update cas;
        
        Case casUpdate = [select ID,Send_Party_B_Emails__c from case where ID =: caseId];
        
        if(casUpdate.Send_Party_B_Emails__c == false)
            	casUpdate.Send_Party_B_Emails__c = true;
        
        update casUpdate;
        
        return 'SUCCESS';
        
    }
    
    // Check if Licence Market Value and Levy Due values are populated on case
    // If Authorisation contact (buyer) does not have portal access, create a new user for them with a profile Taxi Licence User.
    @AuraEnabled
    public static String validateCaseData(Id caseId) {
        try{
            
            Case buyerCase =[SELECT Id, CaseNumber, Record_Type_dev_Name__c, Levy_Due__c, 
                             Licence_Market_Value__c, ContactId, AccountId, Account.Name, Sub_Status__c
                             FROM Case WHERE Id =: caseId];
            
            System.Debug('[TaxiLicenceTrasferInviteBuyerController.validateCaseData][Case]' + buyerCase);
            
            //check if licence market value and transfer levy is populated on case
            if(buyerCase.Levy_Due__c == null || buyerCase.Licence_Market_Value__c == null) {
                return GlobalConstants.INVITE_BUYER_MISSING_LEVY_FEE ;
            }
            
            //check if proposed buyer account and contact are linked to case
            if(buyerCase.AccountId == null || buyerCase.ContactId == null) {                
                return GlobalConstants.INVITE_BUYER_MISSING_ACT_ERR;
                
            }
            
            if(buyerCase.Sub_Status__c == GlobalConstants.PENDING_PAYMENT_SUB_STATUS)
               // Modified on 18 Nov 2019 by Venkatesh:  P2PSUPPORT-255 : Expected Transfer process
               //return 'Party B invitation already sent.';
               return 'An email had already been sent. do you wish to send it again';
            
            return buyerCase.Account.Name;            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,
                                             'TaxiLicenceTrasferInviteBuyerController','validateCaseData',ex.getMessage(),ex);
            return null;  
        }  
    }    
}