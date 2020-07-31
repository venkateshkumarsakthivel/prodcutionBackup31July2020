/**
 * Queue for Minimum Standards Check Groups 
 * Provides interface methods for consumption from check controller
 */
public with sharing class DVDQueue {
    
    /**
     * Custom DVD Queue Exception
     */  
    public class DVDQueueException extends Exception{}
    
    /** ASP who is queueing the check*/
    private Account asp;
    private User requester;
    
    /** only for testing purposes without requester*/
    @TestVisible
    private DVDQueue(Account asp){
        this.asp = asp;
    }
    
    public DVDQueue(Account asp, User requester){
        if(asp == null || requester == null) {
            throw new DVDQueueException('Cannot have empty ASP or Requester for DVD');
        }
        this.asp = asp;
        this.requester = requester;
    }
    
    /**
     * Create queue for all Drivers in ASP
     */
    public void checkAllDrivers(){
        //insert a DVD_Query_Group record
        DVD_Query_Group__c queryGroup = createQueryGroup('All Drivers');
        //start a batch to load up all entity records (with DVD_Query_Group) into DVD_Query table
        //attach a oncomplete postprocessor to update status on 
        DVDQueueLoadedPostProcessor postProcessor = getQueuePostProcessor(queryGroup);
        DVDQueryGroupLoaderBatch loaderBatch = new DVDQueryGroupLoaderBatch(asp.Id, queryGroup, 
                                                                            postProcessor, 
                                                                            DVDQueryGroupLoaderBatch.DVDEntityType.DRIVER);
        Id jobId = Database.executeBatch(loaderBatch, 2000);
        if(!Test.isRunningTest()) {
            FlexQueue.moveJobToFront(jobId);
        }
    }
    /**
     * Create queue for all Vehicles in ASP
     */
    public void checkAllVehicles(){
        //insert a DVD_Query_Group record
        DVD_Query_Group__c queryGroup = createQueryGroup('All Vehicles');
        //start a batch to load up all entity records (with DVD_Query_Group) into DVD_Query table
        //attach a oncomplete postprocessor to update status on 
        DVDQueueLoadedPostProcessor postProcessor = getQueuePostProcessor(queryGroup);
        DVDQueryGroupLoaderBatch loaderBatch = new DVDQueryGroupLoaderBatch(asp.Id, queryGroup, 
                                                                            postProcessor, 
                                                                            DVDQueryGroupLoaderBatch.DVDEntityType.VEHICLE);
        Id jobId = Database.executeBatch(loaderBatch, 2000);
        if(!Test.isRunningTest()) {
            FlexQueue.moveJobToFront(jobId);
        }
    }
    
    /**
     * Query to Export all the DVD fleet records and mail it to the user who clicks it.
     */
    
     public void ExportAllBatch(){
      /*  //insert a DVD_Query_Group record
        DVD_Query_Group__c queryGroup = createQueryGroup('All Drivers');
        //start a batch to load up all entity records (with DVD_Query_Group) into DVD_Query table
        //attach a oncomplete postprocessor to update status on 
        DVDQueueLoadedPostProcessor postProcessor = getQueuePostProcessor(queryGroup);
        DVDQueryAllExporter loaderBatch = new DVDQueryAllExporter(asp.Id, queryGroup, 
                                                                            postProcessor);
        Id jobId = Database.executeBatch(loaderBatch, 2000);
        if(!Test.isRunningTest()) {
            FlexQueue.moveJobToFront(jobId);
        }*/
        
    }
    
    /**
     * Create queue for selected Drivers
     */
    public void checkSelectedDrivers(List<DVD_Entity__c> drivers){
        //insert a DVD_Query_Group record
        DVD_Query_Group__c queryGroup = createQueryGroup(Label.DVD_Run_Type_Drivers);
        //start a batch to load up passed entity records (with DVD_Query_Group) into DVD_Query table
        //attach a oncomplete postprocessor to update status on 
        DVDQueueLoadedPostProcessor postProcessor = getQueuePostProcessor(queryGroup);
        DVDQueryGroupLoaderBatch loaderBatch = new DVDQueryGroupLoaderBatch(asp.Id, queryGroup, postProcessor, DVDQueryGroupLoaderBatch.DVDEntityType.DRIVER,drivers);
       
        //DVDQueryGroupLoaderBatch loaderBatch = new DVDQueryGroupLoaderBatch(asp.Id, queryGroup, postProcessor, DVDQueryGroupLoaderBatch.DVDEntityType.DRIVER);
        Id jobId = Database.executeBatch(loaderBatch, 2000);
        if(!Test.isRunningTest()) {
            FlexQueue.moveJobToFront(jobId);
        }
    }
    
    /**
     * Create queue for selected Vehicles
     */
    public void checkSelectedVehicles(List<DVD_Entity__c> vehicles){
        //insert a DVD_Query_Group record
        DVD_Query_Group__c queryGroup = createQueryGroup(Label.DVD_Run_Type_Vehicle);
        //start a batch to load up passed entity records (with DVD_Query_Group) into DVD_Query table
        //attach a oncomplete postprocessor to update status on 
        DVDQueueLoadedPostProcessor postProcessor = getQueuePostProcessor(queryGroup);
        DVDQueryGroupLoaderBatch loaderBatch = new DVDQueryGroupLoaderBatch(asp.Id, queryGroup, 
                                                                            postProcessor, 
                                                                            DVDQueryGroupLoaderBatch.DVDEntityType.VEHICLE,
                                                                            vehicles);
        Id jobId = Database.executeBatch(loaderBatch, 2000);
        if(!Test.isRunningTest()) {
            FlexQueue.moveJobToFront(jobId);
        }
    }
        
    /**
     * @XXX - change to default pre-processor once mock testing is complete
     */
    @testvisible
    private DVDQueueLoadedPostProcessor getQueuePostProcessor(DVD_Query_Group__c queryGroup) {
        //return new MockDVDQueueLoadedPostProcessor(queryGroup); 
        return new DVDQueueLoadedPostProcessor(queryGroup); 
    }
    
    @testvisible
    private DVD_Query_Group__c createQueryGroup(String runType){
        DVD_Query_Group__c queryGroup = new DVD_Query_Group__c();
        queryGroup.Authorised_Service_Provider__c = asp.Id;
        queryGroup.Status__c = 'Loading';
        queryGroup.Run_Type__c = runType;
        queryGroup.Organisation_Code__c= Label.RMS_Org_Id;
        if(requester != null) {
            queryGroup.Requester__c = requester.Id;
        }
        insert queryGroup;
        return queryGroup;
    }
    
    /**
     * Post Process callback for hooking into the batch 
     */
    public virtual class DVDQueueLoadedPostProcessor implements GenericCommand{
        protected DVD_Query_Group__c queryGroup;
        public DVDQueueLoadedPostProcessor(DVD_Query_Group__c queryGroup){
            this.queryGroup = queryGroup;
        }
        /** set status to 'Queued' */ 
        public virtual void execute(){
            //@TODO - load the record with fields
            // need to include Eligibility_Check_Total_Count__c field for checking the number of records in the group to chjeck
            // so that we can priorties the less number of records before the high count record group processing completed
            DVD_Query_Group__c qg = [SELECT ID, Status__c, Eligibility_Check_Total_Count__c FROM DVD_Query_Group__c WHERE ID = :queryGroup.ID];
            qg.Status__c = 'Queued';
            update qg;
            
            //Not queueing this for Tests as we can only have one executeBatch in a test
            if(!Test.isRunningTest()){
                //schedule the query group
                P2PDVDAppClientBatchSemaphore clientBatchSemaphore = new P2PDVDAppClientBatchSemaphore(qg);
                clientBatchSemaphore.checkAndQueue();
            }
        }
    }
    
    
    /**
     * Mock Post Processor for updating query records with dummy response values
     * without actually working through the callouts
     * @TODO - remove once DVD Integration comes through correctly
     */
    /*public class MockDVDQueueLoadedPostProcessor extends DVDQueueLoadedPostProcessor{
        public MockDVDQueueLoadedPostProcessor(DVD_Query_Group__c queryGroup){
            super(queryGroup);
        }
        
        List<String> CHECK_STATUSES = new List<String>{'Red','Green','White'};
        public override void execute(){
            super.execute();
            //update the query records with mock result values
            List<DVD_Query__c> queries = [SELECT ID, DVD_Entity__c FROM DVD_Query__c WHERE DVD_Query_Group__c = :queryGroup.Id];
            Set<Id> entityIds = new Set<Id>();
            for(DVD_Query__c q: queries){ entityIds.add(q.DVD_Entity__c); }
            Map<Id, DVD_Entity__c> dvdEntities = new Map<Id, DVD_Entity__c>([SELECT Id FROM DVD_Entity__c WHERE Id in :entityIds]);
            for(DVD_Query__c q: queries){
                //@TODO
                //get the DVD_Entity
                DVD_Entity__c e = dvdEntities.get(q.DVD_Entity__c);
                //update the response status required here in DVD_Query & DVD_Entity
                e.DVD_Status__c = 'Success';
                e.Last_DVD_Check_date__c = System.now();
                e.Licence_Check__c = CHECK_STATUSES[Math.mod(Math.abs(Crypto.getRandomLong().intValue()),CHECK_STATUSES.size())];
                e.Vehicle_Check__c = CHECK_STATUSES[Math.mod(Math.abs(Crypto.getRandomLong().intValue()),CHECK_STATUSES.size())];
                e.Criminal_Check__c = CHECK_STATUSES[Math.mod(Math.abs(Crypto.getRandomLong().intValue()),CHECK_STATUSES.size())];
                e.P2P_Offence__c = CHECK_STATUSES[Math.mod(Math.abs(Crypto.getRandomLong().intValue()),CHECK_STATUSES.size())];
                e.Serious_Driving_Offence__c = CHECK_STATUSES[Math.mod(Math.abs(Crypto.getRandomLong().intValue()),CHECK_STATUSES.size())];
                
            }
            //fix the values
            update dvdEntities.values();
        }
    }*/
}