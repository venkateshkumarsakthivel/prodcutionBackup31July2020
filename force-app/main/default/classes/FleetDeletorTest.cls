@istest
public class FleetDeletorTest {

    @istest
    private static void deleteEntitiesSuccessTest(){

         List<Id> recordIds = new List<Id>();
         DVD_Entity__c sample = new DVD_Entity__c(Last_Name__c='abc',Drivers_Licence_Number__c='1',Date_of_Birth__c=system.today()-6600);
         insert sample;
         recordIds.add(sample.Id);
         
         Test.startTest();
         System.assertEquals(TRUE, FleetDeletor.deleteEntities(recordIds));
         Test.stopTest();
   }
    
   @istest
   private static void deleteEntitiesFailureTest(){

         Test.startTest();
         System.assertEquals(FALSE, FleetDeletor.deleteEntities(NULL));
         Test.stopTest();
   } 
}