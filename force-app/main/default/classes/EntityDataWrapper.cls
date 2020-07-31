/**
* Data Struture to serialize 
* Aggregations of counts of Entities (Drivers | Vehicles)
*/ 
public with sharing class EntityDataWrapper {
    
    /** Entity Count */
    @TestVisible
    private Integer entityCount;
    
    @TestVisible
    private Integer redCount;
    @TestVisible
    private Integer greenCount;
    @TestVisible
    private Integer noneCount;
    @TestVisible
    private Integer errorCount;
    
    @TestVisible
    private Integer vehicleErrorCount;

    @TestVisible
    private Integer inspectionDateRedCount;
    @TestVisible
    private Integer inspectionDateGreenCount;
    @TestVisible
    private Integer inspectionDateNoneCount;

    @TestVisible
    private Integer sdoRedCount;
    @TestVisible
    private Integer sdoGreenCount;
    @TestVisible
    private Integer sdoNoneCount;
    @TestVisible
    private Integer sdoErrorCount;
    
    @TestVisible
    private Integer tenureRedCount;
    @TestVisible
    private Integer tenureGreenCount;
    @TestVisible
    private Integer tenureNoneCount;
    @TestVisible
    private Integer tenureErrorCount;
    
    @TestVisible
    private Integer ccRedCount;
    @TestVisible
    private Integer ccGreenCount;
    @TestVisible
    private Integer ccNoneCount;
    @TestVisible
    private Integer ccErrorCount;

    @TestVisible
    private Integer p2pEligibilityRedCount;
    @TestVisible
    private Integer p2pEligibilityGreenCount;
    
    /** Entities*/
    @TestVisible
    private List<DVD_Entity__c> dvdvehiclerecords;
    private List<DVD_Entity__c> entities;
    
    /** Account ID to constrain record by service provider 
     * this is implicit by sharing set (if it exists for Account)
     * But better to make sure by adding to query predicates
     */
    private Id serviceProviderId;
    
    public List<DVD_Entity__c> getEntities(){
        return entities;
    }
    
    @TestVisible
    private EntityDataWrapper() {
        
        User u = [SELECT ID, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];           
        this.serviceProviderId = u.Contact.AccountId;
    }
    
    
    public void limitRecords(Integer recLimit){
      
        if(recLimit <= entities.size() ){
      
            List<DVD_Entity__c> limitedEs = new List<DVD_Entity__c>();
      
            for(Integer i=0; i< recLimit; i++) {
                limitedEs.add(entities[i]);
            }
      
            entities = limitedEs;
        }
    }
    
    /**Factory Methods */
    public static EntityDataWrapper getDriverDataWrapper() {
        
        Id driverRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.loadData(driverRecordTypeId);
        
        return wrapper;
    }
    
    
    
    public static EntityDataWrapper getVehicleDataWrapper() {
        
        Id vehicleRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.loadData(vehicleRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getGreenCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateGreenCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getRedCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateRedCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getWhiteCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateWhiteCount(entityRecordTypeId);
        
        return wrapper;
    }

    public static EntityDataWrapper getVehicleErrorCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateVehicleErrorCount(entityRecordTypeId);
        
        return wrapper;
    }

  public static EntityDataWrapper getErrorCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateErrorCount(entityRecordTypeId);
        
        return wrapper;
    }

    
    public static EntityDataWrapper getPassEligibilityCountDataWrapper() {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateEligibilityPassCount(entityRecordTypeId);
        
        return wrapper;
    }
    
     public static EntityDataWrapper getDVDTotalDriverCount() {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getFinaltoalDVDcount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getDVDTotalVehicleCount() {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getFinaltotalVehicleDVDcount(entityRecordTypeId);
        return wrapper;
    }
    
    public static EntityDataWrapper getFailedEligibilityCountDataWrapper() {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateEligibilityFailCount(entityRecordTypeId);
        
        return wrapper;
    }
    


    /**
     * Create a wrapper object that includes list of all drivers/vehicles
    */     
    @TestVisible
    private void loadData(Id entityRecordTypeId) {
        
        Integer maxRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
		 system.debug('maxRows----------------->'+maxRows);
        
        // Commented on 02 Aug 2019 : Change in the logic to retreive more than 50,000 records
        this.entities = [SELECT Id, PTCode_Active_Start_Date__c,PTCode_Last_Termination_Date__c,Last_Name__c, Drivers_Licence_Number__c, Date_of_Birth__c, Last_DVD_Check_date__c, 
                         Plate_Number__c, Plate_Type__c ,VIN_Number_or_Chassis_Number__c, Last_AIS_Inspection_Date_Check__c,
                         Licence_Check__c, Vehicle_Check__c, Last_AIS_Inspection_Date__c, NSW_Tenure_Check__c,
                         Criminal_Check__c, Serious_Driving_Offence__c, P2P_Offence__c, DVD_Status__c, P2P_Eligibility__c, Taxi_Licence_Status__c
                         FROM DVD_Entity__c 
                         Where RecordTypeId=: entityRecordTypeId
                         AND Authorised_Service_Provider__c = :serviceProviderId
                         ORDER BY Last_Name__c ASC LIMIT :maxRows];
        
        // Added on 02 AUG 2019, Calling REST service to query salesforce to get the DVD entity
        //this.entities = getDVDInfoQueryRESTService.getDVDlisttoQuery(serviceProviderId,entityRecordTypeId);
        
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());

         system.debug('entities----------------->'+entities);
         system.debug('entities size----------------->'+entities.size());
        //Count of all drivers present in database
       
       /* Integer TotaCount = [Select Count() FROM DVD_Entity__c 
                         Where RecordTypeId=: entityRecordTypeId
                         AND Authorised_Service_Provider__c = :serviceProviderId ];*/

       // this.entityCount =  TotaCount;
     
      // Integer TotaCountDVD = DVDDriverCountRESTService.getDVDlisttoQuery (serviceProviderId,entityRecordTypeId);
       //system.debug('TotaCountDVD----------------->'+TotaCountDVD);
       //this.entityCount =  TotaCountDVD;
    }
    
  
    /*
     * Method to fetch aggregate count of drivers/vehicles with licence/vehilce check equal to green
    */
    private void getAggregateGreenCount(Id entityRecordTypeId) {
        List<AggregateResult> greenCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND (Licence_Check__c = 'Green'
                                          OR Vehicle_Check__c = 'Green')];

        this.greenCount = 0;
        if(!greenCount.isEmpty()){                                     
         //Count of drivers having all checks 'green'
         this.greenCount = (Integer)greenCount[0].get('expr0');
        }
    }
    
    /*
     * Method to fetch aggregate count of drivers/vehicles with licence/vehilce check equal to red
    */
    private void getAggregateRedCount(Id entityRecordTypeId) {
        List<AggregateResult> redCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND (Licence_Check__c = 'Red'
                                          OR Vehicle_Check__c = 'Red')
                                    ];

        this.redCount = 0;
        if(!redCount.isEmpty()){
         //Count of drivers having all checks 'red'
         this.redCount = (Integer)redCount[0].get('expr0');
        }     
    }
    
    /*
     * Method to fetch aggregate count of drivers/vehicles with licence/vehilce check equal to white
    */
    private void getAggregateWhiteCount(Id entityRecordTypeId) {
        List<AggregateResult> whiteCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND (Licence_Check__c = 'White'
                                          OR Vehicle_Check__c = 'White')
                                    ];
                                          
        this.noneCount = 0;
        if(!whiteCount.isEmpty()){
         //Count of drivers having all checks 'white'
            this.noneCount = (Integer)whiteCount[0].get('expr0');
        }
    }

    /*
     * Method to fetch aggregate count of drivers/vehicles with licence/vehilce check equal to unknown - unknown represents errors
    */
    private void getAggregateErrorCount(Id entityRecordTypeId) {
        List<AggregateResult> unknownCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND (Licence_Check__c = 'Unknown'
                                          OR Vehicle_Check__c = 'Unknown')
                                    ];
                                          
        this.errorCount = 0;
        if(!unknownCount.isEmpty()){
         //Count of drivers having all checks 'white'
            this.errorCount = (Integer)unknownCount[0].get('expr0');
        }
    }
    
    /*
     * Method to fetch aggregate count of drivers/vehicles with licence/vehilce check equal to unknown - unknown represents errors
    */
    private void getAggregateVehicleErrorCount(Id entityRecordTypeId) {
        List<AggregateResult> unknownCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND (Licence_Check__c = 'Unknown'
                                          OR Vehicle_Check__c = 'Unknown')
                                    ];
                                          
        this.vehicleErrorCount = 0;
        if(!unknownCount.isEmpty()){
         //Count of drivers having all checks 'white'
            this.vehicleErrorCount = (Integer)unknownCount[0].get('expr0');
        }
    }

    
    /*
     * Method to fetch aggregate count of drivers/vehicles with P2P eligibility check equal to pass
    */
    private void getAggregateEligibilityPassCount(Id entityRecordTypeId) {
      List<AggregateResult> greenCount = [SELECT count(id)
                                      FROM DVD_Entity__c 
                                      WHERE RecordTypeId=: entityRecordTypeId 
                                      AND Authorised_Service_Provider__c = :serviceProviderId
                                      AND P2P_Eligibility__c = 'Pass'
                                      ];
                                          
     this.p2pEligibilityGreenCount = 0;
     if(!greenCount.isEmpty()){
         //Count of drivers having all checks 'green'
         this.p2pEligibilityGreenCount =  (Integer)greenCount[0].get('expr0');
     }
    }
    // Added by Venkat 165
     private void getFinaltoalDVDcount (Id entityRecordTypeId) {
      List<AggregateResult> dvdCount = [SELECT count(id) FROM DVD_Entity__c Where RecordTypeId=: entityRecordTypeId AND Authorised_Service_Provider__c = :serviceProviderId];
     system.debug('dvdCount------>'+dvdCount);                                     
     this.entityCount = 0;
    
     if(!dvdCount.isEmpty()){
         //Count of drivers having all checks 'green'
         this.entityCount =  (Integer)dvdCount[0].get('expr0');
     }
    }

     // Added by Venkatesh on 29 Nov 2019
     private void getFinaltotalVehicleDVDcount (Id entityRecordTypeId) {
      List<AggregateResult> dvdCount = [SELECT count(id) FROM DVD_Entity__c Where RecordTypeId=: entityRecordTypeId AND Authorised_Service_Provider__c = :serviceProviderId];
     system.debug('dvdCount Vehicle ------>'+dvdCount);                                     
     this.entityCount = 0;
    
     if(!dvdCount.isEmpty()){
         //Count of drivers having all checks 'green'
         this.entityCount =  (Integer)dvdCount[0].get('expr0');
     }
    }   
        
    
    /*
     * Method to fetch aggregate count of drivers/vehicles with P2P eligibility check equal to fail
    */
    private void getAggregateEligibilityFailCount(Id entityRecordTypeId) {
        List<AggregateResult> redCount = [SELECT count(id)
                                      FROM DVD_Entity__c 
                                      WHERE RecordTypeId=: entityRecordTypeId 
                                      AND Authorised_Service_Provider__c = :serviceProviderId
                                      AND P2P_Eligibility__c = 'Fail'
                                      ];

        this.p2pEligibilityRedCount = 0;
        if(!redCount.isEmpty()){
         //Count of drivers having any check 'red'
            this.p2pEligibilityRedCount =  (Integer)redCount[0].get('expr0');
        }
     
    }

    // ********************* serious driver offence ********************
    /**
     * Method to fetch aggregate count of drivers/vehicles with licence/vehilce check equal to green
    **/


    public static EntityDataWrapper getSDOGreenCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateSDOGreenCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getSDORedCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateSDORedCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getSDOWhiteCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateSDOWhiteCount(entityRecordTypeId);
        
        return wrapper;
    }

    public static EntityDataWrapper getSDOErrorCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateSDOErrorCount(entityRecordTypeId);
        
        return wrapper;
    }

    private void getAggregateSDOGreenCount(Id entityRecordTypeId) {
        List<AggregateResult> greenCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND Serious_Driving_Offence__c = 'Green'
                                    ];

        this.sdoGreenCount = 0;
        if(!greenCount.isEmpty()){                                     
            //Count of drivers having all checks 'green'
            this.sdoGreenCount = (Integer)greenCount[0].get('expr0');
        }
    }
    
    /*
     * Method to fetch aggregate count of drivers/vehicles with licence/vehilce check equal to red
    */
    private void getAggregateSDORedCount(Id entityRecordTypeId) {
        List<AggregateResult> redCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND Serious_Driving_Offence__c = 'Red'
                                    ];

        this.sdoRedCount = 0;
        if(!redCount.isEmpty()){
            //Count of drivers having all checks 'red'
            this.sdoRedCount = (Integer)redCount[0].get('expr0');
        }     
    }
    
    /*
     * Method to fetch aggregate count of drivers/vehicles with licence/vehilce check equal to white
    */
    private void getAggregateSDOWhiteCount(Id entityRecordTypeId) {
        List<AggregateResult> whiteCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND Serious_Driving_Offence__c = 'White'
                                    ];
                                          
        this.sdoNoneCount = 0;
        if(!whiteCount.isEmpty()){
            //Count of drivers having all checks 'white'
            this.sdoNoneCount = (Integer)whiteCount[0].get('expr0');
        }
    }

    /*
     * Method to fetch aggregate count of drivers/vehicles with licence/vehilce check equal to unknown - unknown represents errors
    */
    private void getAggregateSDOErrorCount(Id entityRecordTypeId) {
        List<AggregateResult> unknownCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND Serious_Driving_Offence__c = 'Unknown'
                                    ];
                                          
        this.sdoErrorCount = 0;
        if(!unknownCount.isEmpty()){
        //Count of drivers having all checks 'white'
            this.sdoErrorCount = (Integer)unknownCount[0].get('expr0');
        }
    }
     
    public static EntityDataWrapper getCCGreenCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateCCGreenCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getCCRedCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateCCRedCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getCCWhiteCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateCCWhiteCount(entityRecordTypeId);
        
        return wrapper;
    }

    public static EntityDataWrapper getCCErrorCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateCCErrorCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    /***************** Tenure Check Summary Methods: Start ************************/
    public static EntityDataWrapper getTenureGreenCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateTenureGreenCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getTenureRedCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateTenureRedCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getTenureWhiteCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateTenureWhiteCount(entityRecordTypeId);
        
        return wrapper;
    }

    public static EntityDataWrapper getTenureErrorCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateTenureErrorCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    /*
     * Method to fetch aggregate count of drivers with tenure check check equal to green
    */
    private void getAggregateTenureGreenCount(Id entityRecordTypeId) {
        
        List<AggregateResult> greenCount = [SELECT count(id)
                                            FROM DVD_Entity__c 
                                            WHERE RecordTypeId=: entityRecordTypeId 
                                            AND Authorised_Service_Provider__c = :serviceProviderId
                                            AND NSW_Tenure_Check__c = 'Green'
                                           ];

        this.tenureGreenCount = 0;
        if(!greenCount.isEmpty()){                                     
            //Count of drivers having all checks 'green'
            this.tenureGreenCount = (Integer)greenCount[0].get('expr0');
        }
    }
    
    /*
     * Method to fetch aggregate count of drivers with tenure check check equal to red
    */
    private void getAggregateTenureRedCount(Id entityRecordTypeId) {
        List<AggregateResult> redCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND NSW_Tenure_Check__c = 'Red'
                                    ];

        this.tenureRedCount = 0;
        if(!redCount.isEmpty()){
            //Count of drivers having all checks 'red'
            this.tenureRedCount = (Integer)redCount[0].get('expr0');
        }     
    }
    
    /*
     * Method to fetch aggregate count of drivers with tenure check check equal to white
    */
    private void getAggregateTenureWhiteCount(Id entityRecordTypeId) {
        List<AggregateResult> whiteCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND NSW_Tenure_Check__c = 'White'
                                    ];
                                          
        this.tenureNoneCount = 0;
        if(!whiteCount.isEmpty()){
            //Count of drivers having all checks 'white'
            this.tenureNoneCount = (Integer)whiteCount[0].get('expr0');
        }
    }

    /*
     * Method to fetch aggregate count of drivers with tenure check check equal to unknown
    */
    private void getAggregateTenureErrorCount(Id entityRecordTypeId) {
        List<AggregateResult> unknownCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND NSW_Tenure_Check__c = 'Unknown'
                                    ];
                                          
        this.tenureErrorCount = 0;
        if(!unknownCount.isEmpty()){
        //Count of drivers having all checks 'white'
            this.tenureErrorCount = (Integer)unknownCount[0].get('expr0');
        }
    }
    
    /***************** Tenure Check Summary Methods: End ************************/
    
    
    /***************** AIS Inspection Date Summary Methods: Start ************************/
    public static EntityDataWrapper getAISDateGreenCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateAISDateGreenCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getAISDateRedCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateAISDateRedCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    public static EntityDataWrapper getAISDateWhiteCountDataWrapper(String entityType) {
        
        Id entityRecordTypeId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(entityType).getRecordTypeId();
        EntityDataWrapper wrapper = new EntityDataWrapper();
        wrapper.getAggregateAISDateWhiteCount(entityRecordTypeId);
        
        return wrapper;
    }
    
    /*
     * Method to fetch aggregate count of vehicles with AIS inspection date check equal to green
    */
    private void getAggregateAISDateGreenCount(Id entityRecordTypeId) {
        
        List<AggregateResult> greenCount = [SELECT count(id)
                                            FROM DVD_Entity__c 
                                            WHERE RecordTypeId=: entityRecordTypeId 
                                            AND Authorised_Service_Provider__c = :serviceProviderId
                                            AND Last_AIS_Inspection_Date_Check__c = 'Green'
                                           ];

        this.inspectionDateGreenCount = 0;
        if(!greenCount.isEmpty()){                                     
            //Count of vehicles having AIS inspection date as 'green'
            this.inspectionDateGreenCount = (Integer)greenCount[0].get('expr0');
        }
    }
    
    /*
     * Method to fetch aggregate count of vehicles with AIS inspection date check equal to red
    */
    private void getAggregateAISDateRedCount(Id entityRecordTypeId) {
        List<AggregateResult> redCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND Last_AIS_Inspection_Date_Check__c = 'Red'
                                    ];

        this.inspectionDateRedCount = 0;
        if(!redCount.isEmpty()){
            //Count of vehicles having AIS inspection date as 'red'
            this.inspectionDateRedCount = (Integer)redCount[0].get('expr0');
        }     
    }
    
    /*
     * Method to fetch aggregate count of vehicles with AIS inspection date check equal to white
    */
    private void getAggregateAISDateWhiteCount(Id entityRecordTypeId) {
        List<AggregateResult> whiteCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND Last_AIS_Inspection_Date_Check__c = 'White'
                                    ];
                                          
        this.inspectionDateNoneCount = 0;
        if(!whiteCount.isEmpty()){
            //Count of vehicles having AIS inspection date as white
            this.inspectionDateNoneCount = (Integer)whiteCount[0].get('expr0');
        }
    }
    
    /***************** AIS Inspection Date Summary Methods: End ************************/
    
    
    /*
     * Method to fetch aggregate count of drivers with criminal check check equal to green
    */
    private void getAggregateCCGreenCount(Id entityRecordTypeId) {
        
        List<AggregateResult> greenCount = [SELECT count(id)
                                            FROM DVD_Entity__c 
                                            WHERE RecordTypeId=: entityRecordTypeId 
                                            AND Authorised_Service_Provider__c = :serviceProviderId
                                            AND Criminal_Check__c = 'Green'
                                           ];

        this.ccGreenCount = 0;
        if(!greenCount.isEmpty()){                                     
            //Count of drivers having all checks 'green'
            this.ccGreenCount = (Integer)greenCount[0].get('expr0');
        }
    }
    
    /*
     * Method to fetch aggregate count of drivers with criminal check check equal to red
    */
    private void getAggregateCCRedCount(Id entityRecordTypeId) {
        List<AggregateResult> redCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND Criminal_Check__c = 'Red'
                                    ];

        this.ccRedCount = 0;
        if(!redCount.isEmpty()){
            //Count of drivers having all checks 'red'
            this.ccRedCount = (Integer)redCount[0].get('expr0');
        }     
    }
    
    /*
     * Method to fetch aggregate count of drivers with criminal check check equal to white
    */
    private void getAggregateCCWhiteCount(Id entityRecordTypeId) {
        List<AggregateResult> whiteCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND Criminal_Check__c = 'White'
                                    ];
                                          
        this.ccNoneCount = 0;
        if(!whiteCount.isEmpty()){
            //Count of drivers having all checks 'white'
            this.ccNoneCount = (Integer)whiteCount[0].get('expr0');
        }
    }

    /*
     * Method to fetch aggregate count of drivers with criminal check check equal to unknown
    */
    private void getAggregateCCErrorCount(Id entityRecordTypeId) {
        List<AggregateResult> unknownCount = [SELECT count(id)
                                    FROM DVD_Entity__c 
                                    WHERE RecordTypeId=: entityRecordTypeId 
                                    AND Authorised_Service_Provider__c = :serviceProviderId
                                    AND Criminal_Check__c = 'Unknown'
                                    ];
                                          
        this.ccErrorCount = 0;
        if(!unknownCount.isEmpty()){
        //Count of drivers having all checks 'white'
            this.ccErrorCount = (Integer)unknownCount[0].get('expr0');
        }
    }
    
    /**
     * @author       Abhi Indulkar
     * @createdDate  23/10/2018
     * @description  Method to determine Taxi Licence Status
     **/
    public static void populateTaxiLicenceStatus(List<DVD_Entity__c> pSObjects){
        Map<String, DVD_Entity__c> mEntityByPlate = new Map<String, DVD_Entity__c>();
        List<String> lGreenPlates = new List<String>();

        for(DVD_Entity__c ent : pSObjects){
            //default Taxi Licence Check to White
            ent.Taxi_Licence_Status__c = 'White';
            if(String.isNotEmpty(ent.Plate_Number__c) 
                && isValidTaxiPlateNumber(ent.Plate_Number__c)){
                //Plate number to be added for Taxi licence query
                mEntityByPlate.put(ent.Plate_Number__c, ent);
            }
        }

        // Check if valid Taxi Licence Authorisation exists
        if(!mEntityByPlate.isEmpty()){
            Integer maxRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            System.debug('@@@maxRows: ' + maxRows);
            if(mEntityByPlate.size() > maxRows){
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPDashboardController.EntityDataWrapper', 'populateTaxiLicenceStatus', 'DML Limits exceeded: Taxi Licence Check could not be retrieved for all records', null);
            }
            for(Authorisation__c auth : GlobalUtility.getValidTaxiLicences(mEntityByPlate.keySet(), maxRows))
            {
                lGreenPlates.add(auth.Plate_Number__c);
            }

            // Populate appropriate taxi licence status on each Taxi entity
            for(String sPlateNumber : mEntityByPlate.keySet()){
                DVD_Entity__c ent = mEntityByPlate.get(sPlateNumber);
                if(lGreenPlates.contains(sPlateNumber)){
                    ent.Taxi_Licence_Status__c = 'Green';
                }
                else{
                    ent.Taxi_Licence_Status__c = 'Red';
                }
            }
        }
        System.debug('@@@Entities with Taxi Licence Status: ' + pSObjects);
    }

    /**
     * @author       Abhi Indulkar
     * @createdDate  23/10/2018
     * @description  Method to check if the plate number is in valid taxi plate number
     **/
    private static Boolean isValidTaxiPlateNumber(String pPlateNumber){
        // Valid taxi number plate number formats
        // Ex. T999, T9999, T99999, TC999, TC9999 or TC99999
        //System.debug('@@@isValidPlate: ' + pPlateNumber + '- ' + Pattern.matches('T{1}C?+[0-9]{3,5}+', pPlateNumber));
        return Pattern.matches('T{1}C?+[0-9]{3,5}+', pPlateNumber);
    }
}