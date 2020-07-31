/**
* Test class for DVDQueue
*/
@isTest
private class DVDQueueTest {
    
    private static testmethod void testCheckAllDrivers(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <1500;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkAllDrivers();
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 1500, 'Error: 15000 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    private static testmethod void testCheckAllVehicles(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <1500;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;
            //            e.Drivers_Licence_Number__c= 'DL-00'+i; 
            //            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            //            e.Last_Name__c = 'Driver'+i;
            e.Plate_Number__c = 'VEH-00'+i; 
            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkAllVehicles();
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 1500, 'Error: 1500 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    private static testmethod void testCheckSelectedDrivers(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <1500;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkSelectedDrivers(dvdEntities);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 1500, 'Error: 1500 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    private static testmethod void testCheckSelectedVehicles(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <1500;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;
            //            e.Drivers_Licence_Number__c= 'DL-00'+i; 
            //            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            //            e.Last_Name__c = 'Driver'+i;
            e.Plate_Number__c = 'VEH-00'+i; 
            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkSelectedVehicles(dvdEntities);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Plate_Type__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 1500, 'Error: 1500 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        System.assert(queries[0].Plate_Type__c == 'O', 'Error: Plate Type not added to query!');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    
    

    
    private static testmethod void testCheckAllDrivers2(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <500;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkAllDrivers();
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 500, 'Error: 500 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    private static testmethod void testCheckAllVehicles2(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <500;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;
            //            e.Drivers_Licence_Number__c= 'DL-00'+i; 
            //            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            //            e.Last_Name__c = 'Driver'+i;
            e.Plate_Number__c = 'VEH-00'+i; 
            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkAllVehicles();
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 500, 'Error: 500 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    private static testmethod void testCheckSelectedDrivers2(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <500;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkSelectedDrivers(dvdEntities);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 500, 'Error: 500 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    private static testmethod void testCheckSelectedVehicles2(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <500;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;
            //            e.Drivers_Licence_Number__c= 'DL-00'+i; 
            //            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            //            e.Last_Name__c = 'Driver'+i;
            e.Plate_Number__c = 'VEH-00'+i; 
            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkSelectedVehicles(dvdEntities);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Plate_Type__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 500, 'Error: 500 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        System.assert(queries[0].Plate_Type__c == 'O', 'Error: Plate Type not added to query!');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    


    
    private static testmethod void testCheckAllDrivers3(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <50;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkAllDrivers();
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 50, 'Error: 50 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    private static testmethod void testCheckAllVehicles3(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <50;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;
            //            e.Drivers_Licence_Number__c= 'DL-00'+i; 
            //            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            //            e.Last_Name__c = 'Driver'+i;
            e.Plate_Number__c = 'VEH-00'+i; 
            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkAllVehicles();
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 50, 'Error: 50 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    private static testmethod void testCheckSelectedDrivers3(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <50;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkSelectedDrivers(dvdEntities);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 50, 'Error: 50 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    private static testmethod void testCheckSelectedVehicles3(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <50;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;
            //            e.Drivers_Licence_Number__c= 'DL-00'+i; 
            //            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            //            e.Last_Name__c = 'Driver'+i;
            e.Plate_Number__c = 'VEH-00'+i; 
            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc);
        q.checkSelectedVehicles(dvdEntities);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, DVD_Query_Group__c, Plate_Type__c, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 50, 'Error: 50 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        System.assert(queries[0].Plate_Type__c == 'O', 'Error: Plate Type not added to query!');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
    }
    
    
    
    private static testmethod void testDVDQueue(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Test.startTest();
        DVDQueue q = new DVDQueue(aspAcc, new User());
        q.checkAllDrivers();
        Test.stopTest();
    }
    
    private static testmethod void testDVDQueue2(){
        
        try{
            Test.startTest();
            DVDQueue q = new DVDQueue(null, null);
            q.checkAllDrivers();
            Test.stopTest();
        }
        catch(Exception ex) {
            
        }
    }
}