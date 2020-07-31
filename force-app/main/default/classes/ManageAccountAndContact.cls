public class ManageAccountAndContact {
       @AuraEnabled
      public static Account getAccountData(){
          Account acc;
          User user = [SELECT Id, Profile.Name, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
          Id accId = user.Contact.AccountId;
          if(accId != NULL){
                acc = [select id,Name,ABN__c,ACN__c,Account_Postal_Address__c from Account where id =: accId LIMIT 1];
            }
          return acc;
      }
}