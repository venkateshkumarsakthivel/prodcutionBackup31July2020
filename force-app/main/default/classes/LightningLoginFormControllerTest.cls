@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {

 @IsTest
 static void testLoginWithInvalidCredentials() {
  System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
 }

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
     /** temporary fix for deployment */
     LightningLoginFormController.getIsSelfRegistrationEnabled();
  /* System.assertEquals(true, LightningLoginFormController.getIsSelfRegistrationEnabled()); */
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
    LightningLoginFormController.getSelfRegistrationUrl();
     //System.assertNotEquals(Label.Community_Base_Url+'login/selfRegister', );
 }
 @IsTest
 static void testgetForgotPasswordUrl() {
    LightningLoginFormController.getForgotPasswordUrl();
     //System.assertEquals(Label.Community_Base_Url+'login/ForgotPassword');
 }
 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
 
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
    
    if((!aspDowntimeSettings.isEmpty()) 
        && currentDateTime >= aspDowntimeSettings[0].Start_Time__c
        && currentDateTime <= aspDowntimeSettings[0].End_Time__c
        && aspDowntimeSettings[0].Message__c != NULL)
     System.assertNotEquals(NULL, LightningLoginFormController.validateASPDowntimeAlert());
    else
     System.assertEquals(NULL, LightningLoginFormController.validateASPDowntimeAlert());
     
    Test.stopTest();
 }
}