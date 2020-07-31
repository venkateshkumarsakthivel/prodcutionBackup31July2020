/*
* Helper class to perform post payment receival actions
* On purpose without sharing as guest site user needs to be able to update Case record
*/
public without sharing class PostPaymentProcessor {
    
    private Map<Id, Order> newOrders;
    private Map<Id, Order> oldOrders;
    
    
    public PostPaymentProcessor(Map<Id, Order> newOrders, Map<Id, Order> oldOrders){
        
        this.newOrders = newOrders;
        this.oldOrders = oldOrders;
    }
    
    /*
Method to perform post payment actions
*/
    public void validateSuccessfullPayments() {
        
        try { 
            
            Set<Id> targetRelatedAccounts = new Set<Id>();
            Set<Id> relatedAccountsWithDuePayment = new Set<Id>();
            
            Set<Id> targetRelatedApplicationsToLodge = new Set<Id>();
            List<Case> targetRelatedApplicationsToLodgeList = new List<Case>();
            
            Set<Id> targetRelatedApplicationsToDraft = new Set<Id>();
            List<Case> targetRelatedApplicationsToDraftList = new List<Case>();
            
            Set<Id> relatedLicencesToGrant = new Set<Id>();
            List<Authorisation__c> relatedLicencesToGrantList = new List<Authorisation__c>();
            
            Set<Id> relatedLicencesToNotifyAboutReview = new Set<Id>();
            List<Authorisation__c> relatedLicencesToNotifyAboutReviewList = new List<Authorisation__c>();
            
            Map<Id, Case> applicationsMap = new Map<Id, Case>();
            
            for(Order tempOrder : newOrders.values()) {
                
                System.debug(tempOrder.Status);
                System.debug(oldOrders.get(tempOrder.Id).Status);
                
                //check if payment is received
                if(tempOrder.Status == GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS
                   && oldOrders.get(tempOrder.Id).Status != tempOrder.Status
                   && tempOrder.Authorisation__c != null
                   && tempOrder.Application__c != null) {
                       
                       if(tempOrder.Authorisation_Record_Type_Dev_Name__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME
                          && tempOrder.Application_Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION
                          && tempOrder.Application_Type__c == GlobalConstants.TAXI_CASE_TYPE) {
                              
                              targetRelatedAccounts.add(tempOrder.AccountId);
                          }
                       
                       targetRelatedApplicationsToLodge.add(tempOrder.Application__c);  
                   }
                
                //check if payment is rejected
                if(tempOrder.Status == GlobalConstants.PAYMENT_REJECTED_STATUS
                   && oldOrders.get(tempOrder.Id).Status != tempOrder.Status
                   && tempOrder.Application__c != null
                   && tempOrder.Authorisation__c != null) {
                       
                       if(tempOrder.Authorisation_Record_Type_Dev_Name__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME
                          && tempOrder.Application_Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION
                          && tempOrder.Application_Type__c == GlobalConstants.TAXI_CASE_TYPE) {
                              
                              targetRelatedAccounts.add(tempOrder.AccountId);
                          }
                       
                       targetRelatedApplicationsToDraft.add(tempOrder.Application__c);  
                   }
            }
            
            System.debug('Related Account Size: '+targetRelatedAccounts.size());
            System.debug('Related Applications To Lodge: '+targetRelatedApplicationsToLodge.size());
            System.debug('Related Applications To Draft: '+targetRelatedApplicationsToDraft .size());
            
            if(targetRelatedAccounts.size() > 0) {
                
                //check if any due payments for filtered related accounts
                List<Order> duePayments = [SELECT Id, Status, AccountId, EffectiveDate,
                                           TotalAmount, Amount_Paid__c
                                           FROM Order WHERE Status IN :GlobalConstants.PAYMENT_DUE_STATUS_VALUES
                                           AND AccountId IN :targetRelatedAccounts
                                           AND EffectiveDate < :System.Today()
                                           AND Id NOT IN :newOrders.KeySet()];
                
                for(Order tempDuePayment : duePayments) {
                    
                    if((tempDuePayment.Amount_Paid__c == NULL) 
                       || (tempDuePayment.Amount_Paid__c < tempDuePayment.TotalAmount))
                        relatedAccountsWithDuePayment.add(tempDuePayment.AccountId);
                }
                
                for(Order tempOrder : newOrders.values()) {
                    
                    //if related account does not have any due payment
                    /*if(!relatedAccountsWithDuePayment.contains(tempOrder.AccountId)) {

relatedLicencesToGrant.add(tempOrder.Authorisation__c);
}
else {

relatedLicencesToNotifyAboutReview.add(tempOrder.Authorisation__c);
}*/
                    
                    // The license should go through the approval process regardless of payment due for the license.
                    relatedLicencesToNotifyAboutReview.add(tempOrder.Authorisation__c);
                }
                
                for(Id tempLicenceId : relatedLicencesToGrant) {
                    
                    //marking related licence as granted
                    Authorisation__c tempGrantedLicence = new Authorisation__c();
                    tempGrantedLicence.Id = tempLicenceId;
                    tempGrantedLicence.Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
                    relatedLicencesToGrantList.add(tempGrantedLicence);
                }
                
                for(Id tempLicenceId : relatedLicencesToNotifyAboutReview) {
                    
                    //marking related licence for renewal review
                    Authorisation__c tempGrantedLicence = new Authorisation__c();
                    tempGrantedLicence.Id = tempLicenceId;
                    tempGrantedLicence.Renewal_Review_Needed__c = TRUE;
                    relatedLicencesToNotifyAboutReviewList.add(tempGrantedLicence);
                }
                
                if(relatedLicencesToGrantList.size() > 0) 
                    update relatedLicencesToGrantList;
                
                if(relatedLicencesToNotifyAboutReviewList.size() > 0) 
                    update relatedLicencesToNotifyAboutReviewList;  
            }
            
            for(Case tempCase : [SELECT Is_Complex_Application__c, Record_Type_Dev_Name__c, Authorisation__c, Status, Sub_Status__c
                                 FROM Case
                                 WHERE Id IN :targetRelatedApplicationsToLodge])
                applicationsMap.put(tempCase.Id, tempCase);
            
            
            //marking sucessfull paid applications as lodged
 
                    for(String tempAppId : targetRelatedApplicationsToLodge) {
                        
                        Case tempAppToLodge = new Case();
                        tempAppToLodge.Id = tempAppId;
						if((applicationsMap.containsKey(tempAppId) && applicationsMap.get(tempAppId).Status != GlobalConstants.CLOSED_CASE_STATUS))
                        tempAppToLodge.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
                        
                        if(applicationsMap.containsKey(tempAppId) 
                           && relatedLicencesToGrant.contains(applicationsMap.get(tempAppId).Authorisation__c)){
                               continue;
                           }
                        
                        if((applicationsMap.containsKey(tempAppId) && applicationsMap.get(tempAppId).Is_Complex_Application__c == TRUE && applicationsMap.get(tempAppId).Status != GlobalConstants.CLOSED_CASE_STATUS)
                           || ((applicationsMap.get(tempAppId).Record_Type_Dev_Name__c == GlobalConstants.TAXI_CORPORATION_CASE_RECORD_TYPE_DEV_NAME
                               || applicationsMap.get(tempAppId).Record_Type_Dev_Name__c == GlobalConstants.TAXI_INDIVIDUAL_CASE_RECORD_TYPE_DEV_NAME
                               || applicationsMap.get(tempAppId).Record_Type_Dev_Name__c == GlobalConstants.TAXI_PARTNERSHIP_CASE_RECORD_TYPE_DEV_NAME) && applicationsMap.get(tempAppId).Status != GlobalConstants.CLOSED_CASE_STATUS))
                            tempAppToLodge.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING;
                        else if((applicationsMap.containsKey(tempAppId) && applicationsMap.get(tempAppId).Status != GlobalConstants.CLOSED_CASE_STATUS))
                            tempAppToLodge.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
                        
                        targetRelatedApplicationsToLodgeList.add(tempAppToLodge);   
                    }
            
            //marking payment rejected applications as draft
            for(String tempAppId : targetRelatedApplicationsToDraft) {
                
                Case tempAppToLodge = new Case();
                tempAppToLodge.Id = tempAppId;
                tempAppToLodge.Sub_Status__c = GlobalConstants.PAYMENT_REJECTED_STATUS;
                targetRelatedApplicationsToDraftList.add(tempAppToLodge);   
            }
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            List<Database.SaveResult> sr;
            
            if(targetRelatedApplicationsToLodgeList.size() > 0)
                sr = Database.update(targetRelatedApplicationsToLodgeList, dmo);
            
            if(targetRelatedApplicationsToDraftList.size() > 0)
                sr = Database.update(targetRelatedApplicationsToDraftList, dmo);
        }
        catch(Exception e) {
            
            System.debug('Exception: '+ e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'PostPaymentProcessor', 'validateSuccessfullPayments', e.getMessage(), e);
        }
        
    }
}