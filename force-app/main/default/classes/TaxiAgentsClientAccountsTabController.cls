/**
* Server side rest resource controller for taxi agents client accounts tab
*/
public without sharing class TaxiAgentsClientAccountsTabController {
    
    /* This function retrives Account details logged in user. */
    @AuraEnabled
    public static Account getAccountDetails(){
        
      User user = GlobalUtility.getLoggedInUser();
            
      Account acc = [SELECT Id, Name, Customer_Number__c, ABN__c
                      FROM Account
                      WHERE Id =: user.AccountId];
           
      return acc; 
    }
    
    //function returns account list to which agent has access to
    @AuraEnabled
    public static List<Account> getAgentAccounts() {   
      
      Set<String> targetAgentAccountIds = new Set<String>();
      Map<String, Integer> accountIdVsManagedLicencesCount = new Map<String, Integer>();
      
      User loggedInUser = GlobalUtility.getLoggedInUser();
      
      for(Authorisation_Agent__c tempAuthAgent : [SELECT Name, Agreement_Type__c, Account__c, Approved_Date__c, Status__c,
                                                   Expiry_Date__c, Authorisation__c, Authorisation__r.Service_Provider__c,
                                                   Authorisation__r.Status__c, Authorisation__r.Name
                                                   FROM Authorisation_Agent__c
                                                   WHERE Status__c = :GlobalConstants.STATUS_ACTIVE
                                                   AND Authorisation__r.Status__c != :GlobalConstants.SUPERSEEDED_AUTHORISATION_STATUS
                                                   AND (Expiry_Date__c >= :System.Today()
                                                         OR Expiry_Date__c = NULL)
                                                   AND Account__c = :loggedInUser.AccountId]) {
          
             targetAgentAccountIds.add(tempAuthAgent.Authorisation__r.Service_Provider__c);
            
             if(tempAuthAgent.Authorisation__r.Status__c == GlobalConstants.AUTHORISATION_GRANTED) {
             
              Integer managedLicencesCount = accountIdVsManagedLicencesCount.containsKey(tempAuthAgent.Authorisation__r.Service_Provider__c) ? accountIdVsManagedLicencesCount.get(tempAuthAgent.Authorisation__r.Service_Provider__c) : 0;                                           
              managedLicencesCount++;
              accountIdVsManagedLicencesCount.put(tempAuthAgent.Authorisation__r.Service_Provider__c, managedLicencesCount);
             }
      }
      
      List<Account> tempAccounts = new List<Account>();
      for(Account tempAcc : [SELECT Customer_Number__c, Name, Record_Type_Dev_Name__c, No_of_Licences__c
                              FROM Account
                              WHERE Id IN :targetAgentAccountIds]) {
          
          if(accountIdVsManagedLicencesCount.containsKey(tempAcc.Id))
              tempAcc.No_of_Licences__c = accountIdVsManagedLicencesCount.get(tempAcc.Id);  
          else 
              tempAcc.No_of_Licences__c = 0;
              
          tempAccounts.add(tempAcc);                
      }
                       
      return tempAccounts;
    }
}