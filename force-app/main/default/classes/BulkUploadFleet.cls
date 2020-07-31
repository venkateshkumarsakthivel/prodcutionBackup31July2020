public with sharing class BulkUploadFleet {
	
    //Input :- Content of CSV file uploaded from DVD dashboard page
    //Output :- Number of successfully inserted records
    @AuraEnabled
    public static Integer addDriversFromCSV(String fileContent){
    	Integer successUploads;
        System.debug('fileContent is = '+fileContent);
    	BulkFleetLoader bfl = new BulkFleetLoader(fileContent, DVDEntityBuilder.DVDEntityType.DRIVER);
		successUploads = bfl.execute();
        System.debug('SuccessFully inserted '+ successUploads +' Drivers');
		return successUploads;
    }


    //Input :- Content of CSV file uploaded from DVD dashboard page
    //Output :- Number of successfully inserted records
    @AuraEnabled
    public static Integer addVehiclesFromCSV(String fileContent){
        Integer successUploads;
        System.debug('fileContent is = '+fileContent);
        BulkFleetLoader bfl = new BulkFleetLoader(fileContent, DVDEntityBuilder.DVDEntityType.VEHICLE);
        successUploads = bfl.execute();
        System.debug('SuccessFully inserted '+ successUploads +' Vehicles');
        return successUploads;
    }
}