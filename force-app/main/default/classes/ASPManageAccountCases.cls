//This class is used to manage account page from Manage acount menu.

public with sharing class ASPManageAccountCases {
    
    public class BaseException extends Exception {}
    /*This function retrives the record of logged in user. */
    @AuraEnabled
    public static String getLoggedInUserAccount(){
        try{
            User userRec = GlobalUtility.getLoggedInUser();
            Account act = userRec.Account;
            return JSON.serialize(act);
            
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountCases','getLoggedInUserAccount',ex.getMessage(),ex);
            return null;
        }
    }
    // Updating payment method to null for direct debit where user has cancelled the details to enter for payment. 
    @AuraEnabled
    public static void updateOrderPaymentMethod(String paymentReferenceno) {
        try{
            
            List<Order> orderRecordsToUpdate = new List<Order>();
            for(Order ordRecord :[SELECT Id,Payment_Reference__c,Payment_Method__c FROM Order WHERE Payment_Reference__c =: paymentReferenceno]){
                if(ordRecord.Payment_Method__c=='Direct Debit'){
                    system.debug('order record found');
                    //Order ord = new Order(Id=ordRecord.Id);
                    ordRecord.Payment_Method__c='';
                    orderRecordsToUpdate.add(ordRecord);
                } 
            }
            if(orderRecordsToUpdate.Size() > 0)
            update orderRecordsToUpdate;
        }  
            catch (Exception ex) {
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ManageAccountPaymentsController','updateOrderPaymentMethod',ex.getMessage(),ex);
                
            }
        }
    
    /* 
     * Helper method to retrieve all notice records associated with accounts
     * 
     */
    @AuraEnabled
    public static String getNoticeDetails(){
        String noticesStr;
        try{  
            User user =  GlobalUtility.getLoggedInUser();
            
          List<Notice_Record__c> notices = [SELECT Id, Name, Served_to__r.Name, 
                                                Date_Issued__c, Method_of_Service__c, Notice_Type__c
                                            FROM Notice_Record__c 
                                            WHERE Issued_To__c =: user.AccountId AND Show_On_Industry_Portal__c = 'Yes'
                                            ORDER BY Date_Issued__c DESC];
                                            
                                            
          
                                            
                                            
           
            
            noticesStr = JSON.serialize(notices);            
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(
                GlobalConstants.ERROR,'ASPManageAccountCases'
                ,'getNoticeDetails',ex.getMessage(),ex);
        }
        return noticesStr;
    }
    
    
    /* Used in Applicaions tab
     * This function retrives the List of Applications related to logged in user sorted by descending order in string format. 
     */
    @AuraEnabled
    public static String getApplicationCases(){
        try{ 
            
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_CORPORATION).getRecordTypeId();
            Id rtIdforPartnership = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_PARTNERSHIP).getRecordTypeId();
            Id rtIdforAdministration = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdforReviewableDecisions = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS).getRecordTypeId();
            Id rtIdforCustomerEnquiry = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_CUSTOMER_ENQUIRY).getRecordTypeId();
            
            User user =GlobalUtility.getLoggedInUser();
            Id communityId =  Network.getNetworkId();
            system.debug('++++++++'+communityId);
            List<Case> casesList = [SELECT Id, AccountId,Account.Name, CaseNumber,Type, Sub_Type__c, Service_Type__c, Status, Sub_Status__c, Payment__r.Status,Payment__r.Payment_Method__c,
                                        CreatedBy.Name, LastModifiedDate, Contact.Name, Maintain_Request_Type__c, RecordType.Name, Date_Submitted__c
                                    FROM Case 
                                    WHERE AccountId =: user.AccountId 
                                    AND (RecordTypeId = : rtIdforIndividual 
                                         OR RecordTypeId = : rtIdforCorporation
                                         OR RecordTypeId = :rtIdforPartnership
                                         OR RecordTypeId = :rtIdforAdministration
                                         OR RecordTypeId = : rtIdforReviewableDecisions
                                         OR RecordTypeId = : rtIdforCustomerEnquiry) 
                                    AND ((Status = :GlobalConstants.CASE_DRAFT
                                          OR Status = :GlobalConstants.APPLICATION_STATUS_LODGED
                                          OR Status = :GlobalConstants.CASE_NEW)
                                          AND Sub_Status__c != :GlobalConstants.CASE_SUB_STATUS_GRANTED)
                                          AND Sub_Type__c != :GlobalConstants.CASE_SUB_TYPE_EXPIRY_RENEWABLE
                                          AND Maintain_Request_Type__c != :GlobalConstants.CASE_MAINTAIN_REQUEST_DEACTIVATE_CONTACT
                                          AND Maintain_Request_Type__c != :GlobalConstants.ADD_CONTACT_CASE_SUB_STATUS
                                 ORDER BY CreatedDate 
                                    DESC];
            String cases = JSON.serialize(casesList);
            return cases; 
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(
                GlobalConstants.ERROR,'ASPManageAccountCases',
                    'getApplicationCases',ex.getMessage(),ex);
            return null;       
        }
    }
    
    /* Method for updating Application and Authorisation__c statuses to 'Withdrawn' and 'Cancelled' respectively.
     * Note: If the Authorisation Record is locked by approval process, then a batch is running in the background which updates respective record for an application.
     */
    
    @AuraEnabled
    public static String withdrawASPApplication(Case caseRec) {
        try{
            User userRecord = GlobalUtility.getLoggedInUser();
            caseRec.Decision_Made_By__c = userRecord.Id;
            update caseRec;
            List<Authorisation__c> authRecordsToUpdate = new List<Authorisation__c>();
            for(Authorisation__c authRecord :[SELECT Id, Decision_Reason__c, Decision_Date__c, Decision_Made_By__c  FROM Authorisation__c WHERE Application__c =: caseRec.Id]){
                if(!Approval.isLocked(authRecord.Id)){
                    authRecord.Status__c= GlobalCOnstants.CANCELLED_CASE_STATUS;
                    authRecord.Decision_Reason__c = GlobalConstants.AUTHORISATION_DECISION_REASON;
                    authRecord.Decision_Date__c = system.today();
                    authRecord.Decision_Made_By__c = userRecord.Id;
                    authRecordsToUpdate.add(authRecord);
                } 
            }
            update authRecordsToUpdate;
            return GlobalConstants.SUCCESS_MESSAGE_TO_BE_RETURNED;
            
        }catch (Exception ex) {
            system.debug('Exception: '+ex.getLineNumber());
            system.debug('Exception: '+ex.getMessage());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountCases','withdrawASPApplication',ex.getMessage(),ex);
            return null;        
        }
    }
}