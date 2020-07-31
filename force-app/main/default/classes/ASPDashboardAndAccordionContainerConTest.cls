@isTest
private class ASPDashboardAndAccordionContainerConTest {

  @isTest
  static void validateDVDDownTimeTest() {  
    
    DateTime currentDateTime = System.Now();
    
    List<ASP_Portal_Downtime_Setting__mdt> dvdDowntimeSettings = new List<ASP_Portal_Downtime_Setting__mdt>();
    dvdDowntimeSettings = [SELECT DeveloperName, Start_Time__c, End_Time__c, Message__c
                             FROM ASP_Portal_Downtime_Setting__mdt
                             WHERE DeveloperName = :GlobalConstants.DVD_DASHBOARD_MESSAGE
                             AND Start_Time__c != NULL
                             AND End_Time__c != NULL];
                             
    Test.startTest();
    
    if((!dvdDowntimeSettings.isEmpty()) 
        && dvdDowntimeSettings[0].Start_Time__c >= currentDateTime
        && dvdDowntimeSettings[0].End_Time__c <= currentDateTime
        && dvdDowntimeSettings[0].Message__c != NULL)
     System.assertNotEquals(NULL, ASPDashboardAndAccordionContainerCon.validateDVDDownTime());
    else
     System.assertEquals(NULL, ASPDashboardAndAccordionContainerCon.validateDVDDownTime());
     
    Test.stopTest();
  }
}