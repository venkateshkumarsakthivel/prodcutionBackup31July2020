public class VehicleManagementController {

    //returns list of vehicles present in database
    @AuraEnabled
    public static List<DVD_Entity__c> getVehicles(){
        List<DVD_Entity__c> entityList = new List<DVD_Entity__c>();
        
        entityList = [SELECT Id,Plate_Type__c,Plate_Number__c from DVD_Entity__c
                       ];
        
        return entityList;
    }
}