trigger FleetTrigger on DVD_Entity__c (before insert, before update) {

    // Added on 07 April 2020 : Venkat : For SDO changes 

    List<string> lstDriveLicenseno = new List<string>();
    set<string> setDriversExcempted = new set<string>();

  for(DVD_Entity__c tempFleet : Trigger.New) {
   
   String tempUniqueId = '';
      if( tempFleet.Serious_Driving_Offence__c != null && tempFleet.Serious_Driving_Offence__c == 'Red' ){
          lstDriveLicenseno.add(tempFleet.Drivers_Licence_Number__c);
      }
      
   tempUniqueId = tempFleet.Authorised_Service_Provider__c;
   
   if(tempFleet.Drivers_Licence_Number__c != '' && tempFleet.Drivers_Licence_Number__c != NULL)
     tempUniqueId += tempFleet.Drivers_Licence_Number__c;
    
   if(tempFleet.Date_of_Birth__c != NULL)
     tempUniqueId += tempFleet.Date_of_Birth__c;
     
   if(tempFleet.Last_Name__c != '' && tempFleet.Last_Name__c != NULL)
     tempUniqueId += tempFleet.Last_Name__c;
     
   if(tempFleet.Plate_Number__c != '' && tempFleet.Plate_Number__c != NULL)
     tempUniqueId += tempFleet.Plate_Number__c;
     
   if(tempFleet.VIN_Number_or_Chassis_Number__c != '' && tempFleet.VIN_Number_or_Chassis_Number__c != NULL)
     tempUniqueId += tempFleet.VIN_Number_or_Chassis_Number__c; 
   
   if(tempFleet.Plate_Type__c != '' && tempFleet.Plate_Type__c != NULL)
     tempUniqueId += tempFleet.Plate_Type__c; 
     
   tempFleet.Unique_Id__c = tempUniqueId;
      
  }
    system.debug('lstDriveLicenseno------------>'+lstDriveLicenseno);
    
    // Added on 07 April 2020 : Venkat : check the list of drivers in the exception table for the SDO 'Red' drivers from the Fleet
    for(DVD_SDO_Exception_Drivers__c exccep : [Select ID,Drivers_Licence_Number__c from DVD_SDO_Exception_Drivers__c where Drivers_Licence_Number__c IN: lstDriveLicenseno and isActive__c = TRUE]){
        setDriversExcempted.add(exccep.Drivers_Licence_Number__c);
    }
    system.debug('setDriversExcempted------------>'+setDriversExcempted);
    
    // Added on 07 April 2020 : Venkat : change the SDO from Red to Green on the Fleet record based on the exception table
    for(DVD_Entity__c tempFleet : Trigger.New) {
         system.debug('Drivers_Licence_Number__c------------>'+tempFleet.Drivers_Licence_Number__c);
            system.debug('ContainsCheck------------>'+setDriversExcempted.contains(string.valueof(tempFleet.Drivers_Licence_Number__c)));
          if(tempFleet.Serious_Driving_Offence__c == 'Red' && setDriversExcempted.contains(tempFleet.Drivers_Licence_Number__c)){
            tempFleet.Serious_Driving_Offence__c = 'Green';
        }
      }
}