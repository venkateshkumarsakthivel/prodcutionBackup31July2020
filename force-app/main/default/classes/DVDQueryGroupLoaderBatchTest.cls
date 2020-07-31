/**
* Test class for Query Group Loader Batch
*/
@istest
private class DVDQueryGroupLoaderBatchTest {
    
    private static testMethod void testExecuteDrivers() {
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <200;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        DVDQueue q = new DVDQueue(aspAcc);
        DVD_Query_Group__c queryGroup = q.createQueryGroup('All Drivers');
        Test.startTest();
        DVDQueryGroupLoaderBatch obj = 
            new DVDQueryGroupLoaderBatch(aspAcc.Id, queryGroup, 
                                         new DVDQueue.DVDQueueLoadedPostProcessor(queryGroup), 
                                         DVDQueryGroupLoaderBatch.DVDEntityType.DRIVER);
        DataBase.executeBatch(obj);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 200, '200 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'ASP Id has not matched');
    }
    
    private static testMethod void testExecuteSelectedDrivers() {
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <200;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        DVDQueue q = new DVDQueue(aspAcc);
        DVD_Query_Group__c queryGroup = q.createQueryGroup('Selected Drivers');
        Test.startTest();
        DVDQueryGroupLoaderBatch obj = 
            new DVDQueryGroupLoaderBatch(aspAcc.Id, queryGroup, 
                                         new DVDQueue.DVDQueueLoadedPostProcessor(queryGroup), 
                                         DVDQueryGroupLoaderBatch.DVDEntityType.DRIVER, dvdEntities);
        DataBase.executeBatch(obj);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 200, '200 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'ASP Id has not matched');
    }    
    
    private static testMethod void testExecuteVehicles() {
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <200;i++){
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
        DVD_Query_Group__c queryGroup = q.createQueryGroup('All Vehicles');
        DVDQueryGroupLoaderBatch obj = 
            new DVDQueryGroupLoaderBatch(aspAcc.Id, queryGroup, 
                                         new DVDQueue.DVDQueueLoadedPostProcessor(queryGroup), 
                                         DVDQueryGroupLoaderBatch.DVDEntityType.VEHICLE);
        DataBase.executeBatch(obj);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 200, '200 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'ASP Id has not matched');
    }   
    
    private static testMethod void testExecuteSelectedVehicles() {
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <200;i++){
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
        DVD_Query_Group__c queryGroup = q.createQueryGroup('Selected Vehicles');
        DVDQueryGroupLoaderBatch obj = 
            new DVDQueryGroupLoaderBatch(aspAcc.Id, queryGroup, 
                                         new DVDQueue.DVDQueueLoadedPostProcessor(queryGroup), 
                                         DVDQueryGroupLoaderBatch.DVDEntityType.VEHICLE, dvdEntities);
        DataBase.executeBatch(obj);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 200, '200 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'ASP Id has not matched');
    }    
    
    
    
    
    private static testMethod void testExecuteDrivers2() {
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
        DVDQueue q = new DVDQueue(aspAcc);
        DVD_Query_Group__c queryGroup = q.createQueryGroup('All Drivers');
        Test.startTest();
        DVDQueryGroupLoaderBatch obj = 
            new DVDQueryGroupLoaderBatch(aspAcc.Id, queryGroup, 
                                         new DVDQueue.DVDQueueLoadedPostProcessor(queryGroup), 
                                         DVDQueryGroupLoaderBatch.DVDEntityType.DRIVER);
        DataBase.executeBatch(obj);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 50, '50 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'ASP Id has not matched');
    }
    
    private static testMethod void testExecuteSelectedDrivers2() {
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
        DVDQueue q = new DVDQueue(aspAcc);
        DVD_Query_Group__c queryGroup = q.createQueryGroup('Selected Drivers');
        Test.startTest();
        DVDQueryGroupLoaderBatch obj = 
            new DVDQueryGroupLoaderBatch(aspAcc.Id, queryGroup, 
                                         new DVDQueue.DVDQueueLoadedPostProcessor(queryGroup), 
                                         DVDQueryGroupLoaderBatch.DVDEntityType.DRIVER, dvdEntities);
        DataBase.executeBatch(obj);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 50, '50 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'ASP Id has not matched');
    }    
    
    private static testMethod void testExecuteVehicles2() {
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
        DVD_Query_Group__c queryGroup = q.createQueryGroup('All Vehicles');
        DVDQueryGroupLoaderBatch obj = 
            new DVDQueryGroupLoaderBatch(aspAcc.Id, queryGroup, 
                                         new DVDQueue.DVDQueueLoadedPostProcessor(queryGroup), 
                                         DVDQueryGroupLoaderBatch.DVDEntityType.VEHICLE);
        DataBase.executeBatch(obj);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 50, '50 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'ASP Id has not matched');
    }   
    
    private static testMethod void testExecuteSelectedVehicles2() {
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
        DVD_Query_Group__c queryGroup = q.createQueryGroup('Selected Vehicles');
        DVDQueryGroupLoaderBatch obj = 
            new DVDQueryGroupLoaderBatch(aspAcc.Id, queryGroup, 
                                         new DVDQueue.DVDQueueLoadedPostProcessor(queryGroup), 
                                         DVDQueryGroupLoaderBatch.DVDEntityType.VEHICLE, dvdEntities);
        DataBase.executeBatch(obj);
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT ID, Authorised_Service_Provider__c FROM DVD_Query__c];
        System.assert(queries.size() == 50, '50 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'ASP Id has not matched');
    } 
}