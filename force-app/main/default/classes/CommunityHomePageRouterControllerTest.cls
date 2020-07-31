@isTest
private class CommunityHomePageRouterControllerTest {

  @isTest
  static void validateASPDowntimeAlertTest() {  
    
    List<ASP_Portal_Downtime_Setting__mdt> aspDowntimeSettings = new List<ASP_Portal_Downtime_Setting__mdt>();
    aspDowntimeSettings = [SELECT DeveloperName, Start_Time__c, End_Time__c, Message__c
                             FROM ASP_Portal_Downtime_Setting__mdt
                             WHERE (DeveloperName = :GlobalConstants.INDEX_LOGIN_PAGE_MESSAGE_PRIOR_OUTAGE
                                    OR DeveloperName = :GlobalConstants.INDEX_LOGIN_PAGE_MESSAGE_DURING_OUTAGE) 
                             AND Start_Time__c != NULL
                             AND End_Time__c != NULL];
                             
    Test.startTest();
    
    DateTime currentDateTime = System.Now();
    System.assertEquals(NULL, CommunityHomePageRouterController.validateASPDowntimeAlert());
     
    Test.stopTest();
  }
}