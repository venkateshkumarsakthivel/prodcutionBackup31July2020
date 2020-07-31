@isTest
public class BSBNumberProcessorTest {

  @testSetup 
  static void setupTestData() {
    
    BSB_Details__c testBSBData = new BSB_Details__c();
    testBSBData.Name = '111-111';
    testBSBData.Bank__c = 'ANZ';
    testBSBData.Suburb__c = 'Sydney';
    
    insert testBSBData;
  }
  
  @isTest
  public static void getBSBNumberDetailsTest(){
    
    Test.startTest();
    
    System.assertEquals('ANZ:Sydney', BSBNumberProcessor.getBSBNumberDetails('111-111'));
    System.assertEquals(NULL, BSBNumberProcessor.getBSBNumberDetails('777-777'));
    
    Test.stopTest();
  }
}