/*
 * Created date : 10/October/2019
 * Author : Venkatesh Kumar
 * Requirement : P2PSUPPORT-210 :DVD - ability for ASP to do bulk removal of drivers
 * Reference : BulkDeleteFleet lightning component
 * Referred By : BulkFleetDelete apex class
 * Test Class : BulkDeleteFleetTest 
 * */

public with sharing class BulkDeleteFleet {
	
    //Input :- Content of CSV file uploaded from DVD dashboard page
    //Output :- Number of successfully deleted records
    @AuraEnabled
    public static Integer deleteDriversFromCSV(String fileContent){
    	Integer successDeletes;
        System.debug('fileContent is = '+fileContent);
    	BulkFleetDelete bfl = new BulkFleetDelete(fileContent, DVDEntityBuilder.DVDEntityType.DRIVER);
		successDeletes = bfl.execute();
        System.debug('SuccessFully deleted '+ successDeletes +' Drivers');
		return successDeletes;
    }


    //Input :- Content of CSV file uploaded from DVD dashboard page
    //Output :- Number of successfully deleted records
    @AuraEnabled
    public static Integer deleteVehiclesFromCSV(String fileContent){
        Integer successDeletes;
        System.debug('fileContent is = '+fileContent);
        BulkFleetDelete bfl = new BulkFleetDelete(fileContent, DVDEntityBuilder.DVDEntityType.VEHICLE);
        successDeletes = bfl.execute();
        System.debug('SuccessFully deleted '+ successDeletes +' Vehicles');
        return successDeletes;
    }
}