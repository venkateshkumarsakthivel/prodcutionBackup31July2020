@isTest
public class BatchToUpdateDVDEntityStatusPost12Test {
    
    @testSetup
    static void setup() {
            String dvd1JSON = '{"attributes":{"type":"DvdEntity","url":"/services/data/v25.0/sobjects/DVD_Entity__c/a0J0l0000004zh0EBA"},"Date_of_Birth__c":"1980-10-04","CreatedDate":"2017-10-03T17:54:26.000+0000","LastModifiedDate":"2017-10-04T17:54:26.000+0000","Drivers_Licence_Number__c":"12233333333","Last_Name__c":"testDVD","DVD_Status__c":"Requested"}';
            DVD_Entity__c dvd1 = (DVD_Entity__c) JSON.deserialize(dvd1JSON, DVD_Entity__c.class );
            insert dvd1;
            system.debug('test Insert '+dvd1);
            
            DVD_Query_Group__c dvdQueryGroup1 = new DVD_Query_Group__c(	Status__c = 'Completed', Run_Type__c = 'Drivers');
            insert dvdQueryGroup1;
            
            DVD_Query__c dvdQuery1 = new DVD_Query__c(DVD_Query_Group__c = dvdQueryGroup1.Id, DVD_Entity__c = dvd1.Id, Query_Status__c = 'Completed');    
            insert dvdQuery1;
    }
   
    @isTest
    public static void testScheduler() {
        try{
            Test.StartTest();
            SchedulerToUpdateDVDEntityStatusPost12H batchUpdator = new SchedulerToUpdateDVDEntityStatusPost12H();
            System.schedule('Update Applications Test', '0 0 * * * ?', batchUpdator); 
            Test.StopTest();
           
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'BatchToUpdateDVDEntityStatusPost12Test','executeTest',ex.getMessage(),ex);
            
        }
    }
    
    @isTest
    public static void testBatchable() {
        List<DVD_Entity__c> dvdRecList = [SELECT Id,DVD_Status__c,(select Id from DVD_Queries__r) FROM DVD_Entity__c];
        
        Test.StartTest();
        BatchToUpdateDVDEntityStatusPost12Hours batch = new BatchToUpdateDVDEntityStatusPost12Hours(); 
        batch.execute(null,dvdRecList);
        Test.StopTest();
        
        DVD_Entity__c dvdRec = [SELECT Id,DVD_Status__c,(select Id from DVD_Queries__r) FROM DVD_Entity__c];
        System.assertNotEquals(NULL, dvdRec);
        System.assertEquals('Error', dvdRec.DVD_Status__c);
    }
    
    @isTest
    public static void testBatchableException() {
        Test.StartTest();
        BatchToUpdateDVDEntityStatusPost12Hours batch = new BatchToUpdateDVDEntityStatusPost12Hours(); 
        batch.execute(null,null);
        Test.StopTest();
    }
    
}