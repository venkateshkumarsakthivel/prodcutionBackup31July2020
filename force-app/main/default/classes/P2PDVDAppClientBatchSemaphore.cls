/**
 * Throttle to 'n' batches using a counting semaphore
 * and a schedulable
 * This will check for max concurrent batches allowed
 * Start the Batch if slots are available
 * Schedule the check again if no slots are available
 *
 * Note that there is a limit of 100 scheduled jobs - spring 16
 * (check CronTrigger and CronJobDetail)
 * There is a limit of 5 parallel executing Batch jobs (moved from flexqueue to batch queue)
 */
global class P2PDVDAppClientBatchSemaphore implements Schedulable {

    /**
     * Max Parallel Batches Allowed
     * Note that this will get added to the Apex Flex Queue (limit of 100 in 'Holding' state)
     * The
     */
    private final Integer MAX_PARALLEL_FLEX_Q_SLOTS;

    /** Schedule wait time offset */
    private static final Integer TIME_WAIT_MINS = 1;

    /** Number of records to execute callouts for in the batch transaction */
    private final Integer BATCH_TRANSACTION_CALLOUT_SCOPE;

    /** Query Group to use in the batch */
    private DVD_Query_Group__c queryGroup;


    private final Integer DEFAULT_BATCH_REC_SIZE;
    private final Integer MAX_BATCH_REC_SIZE;
    private final Integer PRIORITY_THRESHOLD;

    /**
     * Constructor
     */
    public P2PDVDAppClientBatchSemaphore(DVD_Query_Group__c queryGroup) {
        this.queryGroup = queryGroup;
        
        List<DVD_Check_Config__mdt> configs = [SELECT id, Max_Available_Flex_Queue_Slots__c, Max_Number_of_Callouts__c, 
                                            Max_Batch_Size__c, Min_Batch_Size__c, Range_Threshold__c, Threshold_for_high_priority__c 
                                    FROM DVD_Check_Config__mdt ORDER BY Range_Threshold__c ASC NULLS LAST];
                                    
        DVD_Check_Config__mdt configToUse = configs[configs.size() - 1];
        for(DVD_Check_Config__mdt config: configs ){
            if(config.Range_Threshold__c != null && config.Range_Threshold__c >= queryGroup.Eligibility_Check_Total_Count__c){
                configToUse = config;
                break;
            }
        }
        System.debug(LoggingLevel.INFO, configToUse);
        MAX_PARALLEL_FLEX_Q_SLOTS = Integer.valueOf(configToUse.Max_Available_Flex_Queue_Slots__c);
        MAX_BATCH_REC_SIZE = Integer.valueOf(configToUse.Max_Batch_Size__c);
        BATCH_TRANSACTION_CALLOUT_SCOPE = Integer.valueOf(configToUse.Max_Number_of_Callouts__c);
        DEFAULT_BATCH_REC_SIZE = Integer.valueOf(configToUse.Min_Batch_Size__c);
        PRIORITY_THRESHOLD = Integer.valueOf(configToUse.Threshold_for_high_priority__c);
    }

    /**
     * Check if batch semaphore has slots
     * If it has - create and add a batch
     * else schedule for a little later
     */
    public void checkAndQueue() {
        
        Integer ctxCount = [SELECT count() FROM FlexQueueItem
                                                WHERE AsyncApexJob.Status = 'Holding'
                                                        AND JobType = 'BatchApex'];

        if ( ctxCount < MAX_PARALLEL_FLEX_Q_SLOTS) {

            Integer queryIndex = 1;
            Integer startIndex = 1;
            Integer endIndex = DEFAULT_BATCH_REC_SIZE;

            while (queryGroup.Eligibility_Check_Total_Count__c > endIndex || startIndex == 1) {

                Integer recDiff = (queryIndex * DEFAULT_BATCH_REC_SIZE) > MAX_BATCH_REC_SIZE ? MAX_BATCH_REC_SIZE : (queryIndex * DEFAULT_BATCH_REC_SIZE);
                endIndex = (startIndex + recDiff) - 1;

                String  query = 'SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, '
                                + ' Plate_Number__c, Plate_Type__c, VIN_Number_or_Chassis_Number__c, '
                                + ' Authorised_Service_Provider__c, DVD_Entity__r.RecordType.Name, DVD_Entity__r.Authorised_Service_Provider__r.Customer_Number__c,'
                                + ' Requester_Id__c, Organisation_Code__c, Query_Started_At__c, '
                                + ' DVD_Query_For__c, Query_Status__c, DVD_Query_Group__c, DVD_Entity__c, '
                                + ' Service_Provider_Code__c '
                                + ' From DVD_Query__c '
                                + ' WHERE DVD_Query_Group__c = \'' + queryGroup.Id + '\''
                                + ' AND Query_Status__c = \'Queued\' AND Sequence_Number__c >= ' + startIndex + ' AND Sequence_Number__c <= ' + endIndex;

                P2PDVDAppClientBatch clientBatch = new P2PDVDAppClientBatch(queryGroup, query);

                system.debug('****Query***' + queryIndex + '****' + query);

                Id ctxBatchId = Database.executeBatch(clientBatch, BATCH_TRANSACTION_CALLOUT_SCOPE);
              
                if (queryGroup.Eligibility_Check_Total_Count__c < PRIORITY_THRESHOLD) {
                    FlexQueue.moveJobToFront(ctxBatchId);
                }
                
                queryIndex ++;
                startIndex = endIndex + 1;
                if(recDiff == MAX_BATCH_REC_SIZE) queryIndex = 1;
            }

        } else {
            //schedule this same schedulable class again in a few mins
            P2PDVDAppClientBatchSemaphore sc = new P2PDVDAppClientBatchSemaphore(queryGroup);
            Datetime dt = Datetime.now().addMinutes(TIME_WAIT_MINS);
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
            Id schedId = System.Schedule('P2PDVDAppClientBatchSemaphore:[' + timeForScheduler + ']', timeForScheduler, sc);
            System.debug(LoggingLevel.INFO, 'Scheduled P2P DVD App Client for ' + timeForScheduler);
        }
    }

    /**
     * execute the scheduled job
     * This should attempt to queue a batch using the check for concurrent batches
     */
    global void execute(SchedulableContext sc) {
        checkAndQueue();
    }
}