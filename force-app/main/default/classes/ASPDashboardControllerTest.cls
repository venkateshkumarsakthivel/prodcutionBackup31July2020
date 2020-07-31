@isTest
public class ASPDashboardControllerTest {
    @testSetup 
    static void setup(){
Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid,
                                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId());
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();       
    }
    
    
    //Test for GetDVDRecordCount
    private static testmethod void GetDVDRecordCountTest(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
  
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;e.Plate_Number__c = 'VEH-00'+i; 
            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJKL00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        List<Integer> results = ASPDashboardController.getDVDRecordCount();
        System.assert(results[0] == 10, '10 Drivers not found');
        System.assert(results[1] == 10, '10 Vehicles not found');
        Test.stopTest();
    }
    
    //Test for getInitialDVDRecords
    private static testmethod void getInitialDVDRecordsTest(){
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
          for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJKL00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        List<DVD_Entity__c> result = ASPDashboardController.getInitialDVDRecords();
        System.assert(result != null,'Records not found');
        Test.stopTest();
    }
    
    
    //Test for getInitialVehicleRecords
    private static testmethod void getInitialVehicleRecordsTest(){
        //Id ownerid = GlobalUtility.getOwnerId();
        Account aspAcc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1];
        
        //Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        List<Authorisation__c> authList = new List<Authorisation__c>();
        Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = 'TSP', 
                                                        Status__c = 'Granted Unconditionally', 
                                                        Service_Provider__c = aspAcc.Id);        
        authList.add(authRec);
        Authorisation__c authRecTaxi = new Authorisation__c(Authorisation_Type__c = 'Taxi Licence', 
                                                            Status__c = 'Granted', 
                                                            Service_Provider__c = aspAcc.Id, 
                                                            Plate_Number__c = 'TC0001');
        authList.add(authRecTaxi);  
        insert authList;

        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <200;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;
            e.Plate_Number__c = 'VEH-00'+i; 
            if(i < 2){
                //Taxi Licence Number for two plates
                e.Plate_Number__c = 'TC000'+i;
            }

            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        
        test.startTest();
        List<DVD_Entity__c> result = ASPDashboardController.getInitialVehicleRecords();
        System.assert(result != null,'Records not found');

            List<Id> vehicleIds = new List<Id>();
            for(DVD_Entity__c vehicleRec : [Select Id from DVD_Entity__c WHERE RecordTypeId =: vehicleRTID]){
                vehicleIds.add(vehicleRec.Id);
        }
            
            ASPDashboardController.runCheckSelectedVehicles(vehicleIds);
            System.assert(true);
            
        Test.stopTest();
    }
    
    
    //Test for runCheckAllDrivers,runCheckAllVehicles,getDVDQueryGroupLogs
    private static testmethod void getDVDQueryGroupLogsTest(){
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
          for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJKL00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        String queueDrivers = ASPDashboardController.runCheckAllDrivers();
        String queueVehicles = ASPDashboardController.runCheckAllVehicles();
        List<DVD_Query_Group__c> result = ASPDashboardController.getDVDQueryGroupLogs();
        System.assert(result != null,'Records not found');
        Test.stopTest();
    }
    
    
    //Test for runCheckSelectedDrivers, runCheckSelectedVehicles
    private static testmethod void runCheckSelectedTest(){
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
          for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJKL00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        
        
        List<Id> driverIds = new List<Id>();
        List<Id> vehicleIds = new List<Id>();
        
        for(DVD_Entity__c driverRec : [Select Id from DVD_Entity__c WHERE RecordTypeId =: driverRTID LIMIT 10]){
            driverIds.add(driverRec.Id);
        }
        
        for(DVD_Entity__c vehicleRec : [Select Id from DVD_Entity__c WHERE RecordTypeId =: vehicleRTID LIMIT 10]){
            vehicleIds.add(vehicleRec.Id);
        }
        
        ASPDashboardController.runCheckSelectedDrivers(driverIds);
        ASPDashboardController.runCheckSelectedVehicles(vehicleIds);
        System.assert(true);
        
        Test.stopTest();
    }
    
    
    
    //Test for dvdRecordListDeletion
    private static testmethod void dvdRecordListDeletionTest(){
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
          for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJKL00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        Test.startTest();
        
        
        List<String> driverIds = new List<String>();
        List<String> vehicleIds = new List<String>();
        
        for(DVD_Entity__c driverRec : [Select Id from DVD_Entity__c WHERE RecordTypeId =: driverRTID LIMIT 5]){
            driverIds.add(driverRec.Id);
        }
        
        for(DVD_Entity__c vehicleRec : [Select Id from DVD_Entity__c WHERE RecordTypeId =: vehicleRTID LIMIT 10]){
            vehicleIds.add(vehicleRec.Id);
        }
        
        ASPDashboardController.dvdRecordListDeletion(driverIds);
        ASPDashboardController.dvdRecordListDeletion(vehicleIds);
        
        List<DVD_Entity__c> drivers = [SELECT Id FROM DVD_Entity__c WHERE RecordTypeId =: driverRTID];
        List<DVD_Entity__c> vehicles = [SELECT Id FROM DVD_Entity__c WHERE RecordTypeId =: vehicleRTID];
        System.assertEquals(5, drivers.size());
        System.assertEquals(190, vehicles.size());        
        Test.stopTest();
    }
    
    //Test for dvdDriverRecordUpdate
    @isTest
    private static void dvdDriverRecordUpdateTest(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account act = new Account(Name = 'Test Account',OwnerId=ownerid);
        insert act;
        
        Contact ct = new Contact(LastName = 'Test Contact', AccountId = act.Id, Description = 'contacts for testing');
        insert ct; 
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = ct.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        DVD_Entity__c retriveRecord;
        
        test.startTest();
        system.runAs(user){
            DVD_Entity__c insertRecord = new DVD_Entity__c(Drivers_Licence_Number__c = '877605KL', Last_Name__c = 'Bailey', Date_of_Birth__c = Date.valueOf('1986-05-05'));
            insert insertRecord;
            
            ASPDashboardController.dvdDriverRecordUpdate(insertRecord.Id, 'Bailey', '877605JP', '05/05/1986');
            retriveRecord = [SELECT Id, Drivers_Licence_Number__c, Last_Name__c, Date_of_Birth__c from DVD_Entity__c];
            
        }
        test.stopTest();
        
        system.assertEquals('877605JP', retriveRecord.Drivers_Licence_Number__c);
    }
    
    
    //Test for dvdVehicleRecordUpdate
    @isTest
    private static void dvdVehicleRecordUpdateTest(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account act = new Account(Name = 'Test Account',OwnerId=ownerid);
        insert act;
        
        Contact ct = new Contact(LastName = 'Test Contact', AccountId = act.Id, Description = 'contacts for testing');
        insert ct; 
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = ct.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        DVD_Entity__c retriveRecord;
        test.startTest();
        system.runAs(user){
            DVD_Entity__c insertRecord = new DVD_Entity__c(Plate_Number__c = 'BB03BB', PLate_Type__c = 'O', VIN_Number_or_Chassis_Number__c = '65E4');
            insert insertRecord;
            retriveRecord = [SELECT Id, Plate_Number__c, PLate_Type__c, VIN_Number_or_Chassis_Number__c from DVD_Entity__c];
            
            ASPDashboardController.dvdVehicleRecordUpdate(retriveRecord.Id, 'BB03BC', retriveRecord.Plate_Type__c, retriveRecord.VIN_Number_or_Chassis_Number__c);
        }
        test.stopTest();
        
        DVD_Entity__c recordAfterUpdate = [SELECT Id, Plate_Number__c, PLate_Type__c, VIN_Number_or_Chassis_Number__c from DVD_Entity__c];
        system.assertEquals('BB03BC', recordAfterUpdate.Plate_Number__c);
        
    }
    
    
    
    //Test for QueriesToExport
    private static testmethod void QueriesToExportTest(){
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
          for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJKL00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        
        Test.startTest();
        
        
        String queuedDrivers = ASPDashboardController.runCheckAllDrivers();
        String queuedVehicles = ASPDashboardController.runCheckAllVehicles();
        
        
        List<DVD_Query_Group__c> result = ASPDashboardController.getDVDQueryGroupLogs();
        
        List<DVD_Query__c> queryExport;
        for(DVD_Query_Group__c var : result){
            if(var.Run_Type__c == 'All Drivers')
                queryExport = ASPDashboardController.QueriesToExport(var.Id, GlobalConstants.DVD_ENTITY_TYPE_DRIVER);
            if(var.Run_Type__c == 'All Vehicles')
                queryExport = ASPDashboardController.QueriesToExport(var.Id,GlobalConstants.DVD_ENTITY_TYPE_VEHICLE);
        }
        system.assert(true);
        Test.stopTest();
    }
    
    //Test for getAggregateGreenCount, getAggregateRedCount, 
    //getAggregateWhiteCount, getAggregatePassEligibilityCount and getAggregateFailEligibilityCount
    private static testmethod void getAggregateCountTest(){
        
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
        
        for(Integer i=0 ;i <10;i++){
        
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJKL00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        
        insert dvdEntities;
        
        Test.startTest();
        
        EntityDataWrapper dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateGreenCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.greenCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateGreenCount('Vehicle'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.greenCount);
        
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateRedCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.redCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateRedCount('Vehicle'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.redCount);
        
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateWhiteCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.noneCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateWhiteCount('Vehicle'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.noneCount);
        
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregatePassEligibilityCount(), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.p2pEligibilityGreenCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateFailEligibilityCount(), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.p2pEligibilityRedCount);
        
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateTenureGreenCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.tenureGreenCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateTenureRedCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.tenureRedCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateTenureWhiteCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.tenureNoneCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateTenureErrorCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.tenureErrorCount);
        
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateSDOGreenCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.sdoGreenCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateSDORedCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.sdoRedCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateSDOWhiteCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.sdoNoneCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateSDOErrorCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.sdoErrorCount);
        
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateCCGreenCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.ccGreenCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateCCRedCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.ccRedCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateCCWhiteCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.ccNoneCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateCCErrorCount('Driver'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.ccErrorCount);
        
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateAISDateGreenCount('Vehicle'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.inspectionDateGreenCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateAISDateRedCount('Vehicle'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.inspectionDateRedCount);
        dataWrapper = (EntityDataWrapper)JSON.deserialize(ASPDashboardController.getAggregateAISDateWhiteCount('Vehicle'), EntityDataWrapper.class);
        System.assertEquals(0, dataWrapper.inspectionDateNoneCount);
        
        Test.stopTest();
    }
}