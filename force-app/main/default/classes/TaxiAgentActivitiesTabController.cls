/**
* Server side rest resource controller for taxi agents activities tab
*/
public without sharing class TaxiAgentActivitiesTabController {
    
    /* This function retrives Account details logged in user. */
    @AuraEnabled
    public static Account getAccountDetails(){
        
      User user = GlobalUtility.getLoggedInUser();
            
      Account acc = [SELECT Id, Name, Customer_Number__c, ABN__c
                      FROM Account
                      WHERE Id =: user.AccountId];
           
      return acc; 
    }
    
    //function returns cases list to which agent has access to
    @AuraEnabled
    public static List<Case> getAgentCases() {   
      
      User loggedInUser = GlobalUtility.getLoggedInUser();
      Set<String> targetLicences = new Set<String>();
      
      List<Case> targetCases = [SELECT CaseNumber, Account.Name, Subject, Sub_Type__c, Status, Date_Submitted__c, Licence_Holder_Name__c
                                 FROM Case
                                 WHERE AccountId = :loggedInUser.AccountId
                                 AND Sub_Type__c = :GlobalConstants.AGENT_LICENCE_AGREEMENT_SUB_TYPE
                                 ORDER BY Date_Submitted__c DESC NULLS LAST];
                             
      return targetCases;
    }
}