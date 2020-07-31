@isTest
public class BatchToDeleteDVDQueriesPost90DaysTest {
    
    @testSetup
    static void setup() {
            
            DVD_Query_Group__c dvdQueryGroup = new DVD_Query_Group__c(	Status__c = 'Completed', Run_Type__c = 'Drivers');
            insert dvdQueryGroup;
            
            DVD_Query__c dvdQuery = new DVD_Query__c(DVD_Query_Group__c = dvdQueryGroup.Id, Query_Status__c = 'Completed');    
            insert dvdQuery;
            Date before90days = date.today().addMonths(-3);
            Test.setCreatedDate(dvdQuery.Id, before90days);
    }
   
    @isTest
    public static void testScheduler() {
        try{
            Test.StartTest();
            SchedulerToDeleteDVDQueriesPost90Days batchUpdator = new SchedulerToDeleteDVDQueriesPost90Days();
            System.schedule('Update Applications Test', '0 0 * * * ?', batchUpdator); 
            Test.StopTest();
           
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'SchedulerToDeleteDVDQueriesPost90Days','executeTest',ex.getMessage(),ex);
            
        }
    }
   
    @isTest
    public static void testBatchableException() {
        Test.StartTest();
        BatchToDeleteDVDQueriesPost90Days batch = new BatchToDeleteDVDQueriesPost90Days(); 
        batch.execute(null,null);
        Test.StopTest();
    } 
}