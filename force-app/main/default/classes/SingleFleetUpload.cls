public with sharing class SingleFleetUpload {
    
    //returns the success or error message on uploading single driver record
    @AuraEnabled
    public static String saveSingleDriver(String lastName, String dateOfBirth, String licenceNo){
        
        list<String> SplitDate = dateOfBirth.split('/');
        Date birthDate = date.newinstance(Integer.valueOf(SplitDate[2]), Integer.valueOf(SplitDate[1]), Integer.valueOf(SplitDate[0]));
        
        //fetch recordtypeId for drivers
        Id rtId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(Label.DVD_ENTITY_DRIVER_DEVELOPER_NAME).getRecordTypeId();
        
        DVD_Entity__c newDriver = new DVD_Entity__c();
        newDriver.Last_Name__c = lastName;
        newDriver.Date_of_Birth__c = birthDate;
        newDriver.Drivers_Licence_Number__c = licenceNo;
        newDriver.RecordTypeId = rtId;
        System.debug('rtId === '+rtId);
        
        //all checks are set to None by default
        newDriver.Licence_Check__c = 'None';
        newDriver.Criminal_Check__c = 'None';
        newDriver.Serious_Driving_Offence__c = 'None';
        newDriver.P2P_Offence__c = 'None';
        newDriver.P2P_Eligibility__c = 'None';
        
        //provide asp on fleet record depending upon current user 
        try{
            System.debug('userId = '+UserInfo.getUserId());
            User u = [SELECT ID, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            List<Account> accs = [SELECT Id FROM Account WHERE Id = :u.Contact.AccountId LIMIT 1];
            if(accs.isEmpty()){
                return 'Error: User is not a community user';
            }
            newDriver.Authorised_Service_Provider__c = accs[0].id;
            
            insert newDriver;
            system.debug('NEW DRIVER ID: '+newDriver.Id);
            return Label.SUCCESS_MESSAGE;
            
        }catch(Exception e){
            System.debug('record not inserted '+e.getMessage());
            
            newDriver.addError(e.getMessage());
            if(e.getMessage().contains(GlobalConstants.DUPLICATE_VALUE_EXCEPTION)){
                return Label.ERRMSG_DUPLICATE_RECORD_FOUND;
            }
            else if(e.getMessage().contains(GlobalConstants.INVALID_DATE_EXCEPTION)){
                return Label.INVALID_DATE_MESSAGE;
            }
            else if(e.getMessage().contains(GlobalConstants.INVALID_LAST_NAME)){
                return GlobalConstants.INVALID_LAST_NAME_MESSAGE;
            }
            
            else if(e.getMessage().contains(GlobalConstants.INVALID_AGE_EXCEPTION)){
                return GlobalConstants.INVALID_AGE_MESSAGE;
            }
            return e.getMessage();
        }
        
    }
    
    //returns the success or error message on uploading single vehicle record
    @AuraEnabled
    public static String saveSingleVehicle(String plateNumber, String plateType, String chassisNumber){
        //fetch recordtypeId for drivers
        Id rtId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(Label.DVD_ENTITY_VEHICLE_DEVELOPER_NAME).getRecordTypeId();
        System.debug(rtId);
        
        DVD_Entity__c newVehicle = new DVD_Entity__c();
        newVehicle.Plate_Number__c = plateNumber;
        newVehicle.Plate_Type__c = plateType;
        newVehicle.VIN_Number_or_Chassis_Number__c = chassisNumber;
        newVehicle.RecordTypeId = rtId;
        
        //all checks are set to None by default
        newVehicle.Vehicle_Check__c = 'None';
        
        //provide asp on fleet record depending upon current user 
        try{
            User u = [SELECT ID, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            List<Account> accs = [SELECT Id FROM Account WHERE Id = :u.Contact.AccountId LIMIT 1];
            
            if(accs.isEmpty()){
                return 'Error: User is not a community user';
            }
            newVehicle.Authorised_Service_Provider__c = accs[0].id;
            
            insert newVehicle;
        }catch(Exception e){
            newVehicle.addError(e.getMessage());
            if(e.getMessage().contains(Label.ERRMSG_FLOW_ERROR_MESSAGE)){
                return Label.ERRMSG_DUPLICATE_RECORD_FOUND;
            }
            else if(e.getMessage().contains(GlobalConstants.DUPLICATE_VALUE_EXCEPTION)){
                return Label.ERRMSG_DUPLICATE_RECORD_FOUND;
            }
            else{
                return e.getMessage();
            }
        }
        return Label.SUCCESS_MESSAGE;
    }
}