public with sharing class BulkFleetLoader {
    
    private String filedata;
    private DVDEntityBuilder.DVDEntityType entityType; 
    private static User u;
    private static Account acc;

    static {
        u = [SELECT ID, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        acc = [SELECT Id FROM Account WHERE Id = :u.Contact.AccountId];
    }
    
    public BulkFleetLoader(String filedata, DVDEntityBuilder.DVDEntityType entityType){
        this.entityType = entityType;
        this.filedata = filedata;
    }

    //Executes the process of insertion of Fleet records
    //returns number of successfully inserted records
    public Integer execute(){
        
        Integer insertedRecordCount = 0;
        try{
        
            System.debug('In Execute');
            
            if(entityType == null) {
                throw new BulkLoadException(Label.EXCEPTION_MSG_INVALID_TYPE);
                //throw new Exception('Incorrect type of data - required Type');
            }
            
            if(filedata == null) {
                throw new BulkLoadException(Label.EXCEPTION_MSG_INVALID_DATA);
                //throw new Exception('Incorrect type of data - required data');
            }

            List<DVD_Entity__c> entities;
            
            if(entityType == DVDEntityBuilder.DVDEntityType.DRIVER){
            
                entities = parseDrivers();
            }
            else if(entityType == DVDEntityBuilder.DVDEntityType.VEHICLE){
            
                entities = parseVehicles();
            }
            
            //Save records in database allowing partial insertion
            Database.SaveResult[] srList = Database.insert(entities, false);

            for(Database.SaveResult sr : srList) {
               
                System.debug('srResult = '+sr);
                if(sr.isSuccess()) {
               
                    insertedRecordCount++;
                    System.debug('success === '+ sr);
                }
                else{
                
                    // Operation failed, so get all errors                
                
                    for(Database.Error err : sr.getErrors()) {
                
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
        }
        catch(Exception e){
        
            System.debug(e.getMessage());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'BulkFleetLoader', 'execute', e.getMessage(), e);
        }
        return insertedRecordCount;
    }
    
    //passes single row of csv to insert single driver record
    @TestVisible
    private List<DVD_Entity__c> parseDrivers() {
        Id rtId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(Label.DVD_ENTITY_DRIVER_DEVELOPER_NAME).getRecordTypeId();
        List<DVD_Entity__c> newDrivers = new List<DVD_Entity__c>();
        Iterator<List<String>> parser = new ATP_CSVParser(filedata);

        //System.debug('add drivers');
        //System.debug(acc.id);
        while(parser.hasNext()){
            List<String> driverRecord = new List<String>();
            DVD_Entity__c newDriver = new DVD_Entity__c();
            driverRecord = parser.next();
            newDriver = DVDEntityBuilder.buildDriver(driverRecord, acc.id, rtId);
            if(newDriver != null){
                newDrivers.add(newDriver);
            }
        }
        return newDrivers;
    }

    //passes single row of csv to insert single vehicle record
    @TestVisible
    private List<DVD_Entity__c> parseVehicles() {
        Id rtId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(Label.DVD_ENTITY_VEHICLE_DEVELOPER_NAME).getRecordTypeId();
        List<DVD_Entity__c> newVehicles = new List<DVD_Entity__c>();
        Iterator<List<String>> parser = new ATP_CSVParser(filedata);
        while(parser.hasNext()){
            List<String> vehicleRecord = new List<String>();
            DVD_Entity__c newVehicle = new DVD_Entity__c();
            vehicleRecord = parser.next();
            newVehicle =  DVDEntityBuilder.buildVehicle(vehicleRecord, acc.id, rtId);
            if(newVehicle != null){
                newVehicles.add(newVehicle);
            }
        }
        return newVehicles;
    }

    public class BulkLoadException extends Exception {}

}