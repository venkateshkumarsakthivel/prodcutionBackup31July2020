public with sharing class DVDEntityBuilder {
	
	public Enum DVDEntityType {DRIVER, VEHICLE}
	//Input :- Single row of CSV 
	//Output :- Driver record formed from the input
	public static DVD_Entity__c buildDriver(List<String> driverRecord, Id accId, Id rtId){
		
	
		try{
			DVD_Entity__c d = new DVD_Entity__c();
			String dateString = driverRecord[1].replace('-', '/');
			System.debug(driverRecord);
			System.debug('dateString === '+dateString);
			d.Last_Name__c = driverRecord[0];
	    	d.Date_of_Birth__c = date.parse(dateString); //formDateString(driverRecord[1]);
	    	d.Drivers_Licence_Number__c = driverRecord[2];
	    	d.Criminal_Check__c = 'None';
	    	d.Licence_Check__c = 'None';
	    	d.P2P_Offence__c = 'None';
	    	d.Serious_Driving_Offence__c = 'None';
	    	d.RecordTypeId = rtId;
			
	        d.Authorised_Service_Provider__c = accId;            
	        return d;
        }
        catch(Exception e){
        	System.debug('#########'+e.getMessage());
        	return null;
        }
	}
	
	//Input :- Single row of CSV 
	//Output :- Vehicle record formed from the input
	public static DVD_Entity__c buildVehicle(List<String> vehicleRecord, Id accId, Id rtId){
		
		//Id rtId = fleetRecordTypeIds.get(DVDEntityType.VEHICLE);
		try{
		DVD_Entity__c v = new DVD_Entity__c();
		System.debug(vehicleRecord);
		v.Plate_Number__c = vehicleRecord[0];
		v.Plate_Type__c = vehicleRecord[1];
		v.VIN_Number_or_Chassis_Number__c = vehicleRecord[2];
		v.Vehicle_Check__c = 'None';
		v.RecordTypeId = rtId;
		v.Authorised_Service_Provider__c = accId;
		
		return v;
		}
		catch(Exception e){
			System.debug(e.getMessage());
			return null;
		}
	}

	public class DVDEntityBuilderException extends Exception {}
}