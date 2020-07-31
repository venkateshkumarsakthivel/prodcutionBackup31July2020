/*
 * Tests for E2E callout flow to RMS
 * Tests building req, callout, parsing response, committing response
 */
@isTest
public class P2PDVDAppClientTest {

    private static testmethod void testVehicle1(){ 
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;
            e.Plate_Number__c = 'VEH-00'+i; 
            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        List<DVD_Entity__c> insertedEs = [SELECT Id FROM DVD_Entity__c WHERE Inactive__c = false];
        System.assert(insertedEs.size() == 10, 'Error: 10 Vehicles not created...' + insertedEs.size());
        Test.startTest();
            DVDQueue q = new DVDQueue(aspAcc);
            q.checkAllVehicles();
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, Plate_Number__c, DVD_Entity__r.Authorised_Service_Provider__r.Customer_Number__c, 
                                            Plate_Type__c, VIN_Number_or_Chassis_Number__c, Authorised_Service_Provider__c, DVD_Query_Group__c,
                                            DVD_Entity__c, Requester_Id__c, Organisation_Code__c, Service_Provider_Username__c,
                                            Query_Started_At__c, Query_Status__c, DVD_Query_For__c
                                        FROM DVD_Query__c];
        System.assert(queries.size() == 10, 'Error: 10 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
        P2PDVDAppClient appClient = new P2PDVDAppClient();
        P2PDVDAppClient.P2PDVDAppResponseParserVisitor visitor = new P2PDVDAppClient.P2PDVDAppResponseParserVisitor();
        for(DVD_Query__c queryParam: queries){
            appClient.callDVDApp(queryParam, visitor);
        }
        visitor.updateResponses();  
        
        //assert that the dvd_query records have some overall_status, eligibility_status__c set
        //assert that the dvd_entity records have some licence_check__c set
        List<DVD_Query__c> resQueries = [SELECT Id, Overall_Result__c, Eligibility_Status__c FROM DVD_Query__c];
        List<DVD_Entity__c> resEntities = [SELECT Id, Vehicle_Check__c FROM DVD_Entity__c];
        
        for(DVD_Query__c resQ: resQueries){
            System.assert(resQ.Overall_Result__c != NULL, 'Error: No overall status received for this test for queryParam');
        }
        for(DVD_Entity__c resE: resEntities){
            System.assert(resE.Vehicle_Check__c != NULL, 'Error: No eligibility check updated for this test in Entity');
        }
    } 

    private static testmethod void testForError(){ 
        Account aspAcc = new Account();
        aspAcc.Name = 'Test DVD Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = vehicleRTID;
            e.Plate_Number__c = 'VEH-00'+i; 
            e.Plate_Type__c = 'O'; 
            e.VIN_Number_or_Chassis_Number__c = String.valueOf(1111+i);
            e.Authorised_Service_Provider__c = aspAcc.Id;
            dvdEntities.add(e);
        }
        insert dvdEntities;
        List<DVD_Entity__c> insertedEs = [SELECT Id FROM DVD_Entity__c WHERE Inactive__c = false];
        System.assert(insertedEs.size() == 10, 'Error: 10 Vehicles not created...' + insertedEs.size());
        P2PDVDAppClient.TEST_FOR_ERROR = true;
        RMSDVDAPIMockImpl.TEST_FOR_ERROR = true;
        Test.startTest();
            DVDQueue q = new DVDQueue(aspAcc);
            q.checkAllVehicles();
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, Plate_Number__c, DVD_Entity__r.Authorised_Service_Provider__r.Customer_Number__c, 
                                            Plate_Type__c, VIN_Number_or_Chassis_Number__c, Authorised_Service_Provider__c, DVD_Query_Group__c,
                                            DVD_Entity__c, Requester_Id__c, Organisation_Code__c, Service_Provider_Username__c,
                                            Query_Started_At__c, Query_Status__c, DVD_Query_For__c
                                        FROM DVD_Query__c];
        System.assert(queries.size() == 10, 'Error: 10 queries not created...' + queries.size());
        System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
        P2PDVDAppClient appClient = new P2PDVDAppClient();
        P2PDVDAppClient.P2PDVDAppResponseParserVisitor visitor = new P2PDVDAppClient.P2PDVDAppResponseParserVisitor();
        for(DVD_Query__c queryParam: queries){
            appClient.callDVDApp(queryParam, visitor);
        }
        visitor.updateResponses();  
        
        //assert that the dvd_query records have some overall_status, eligibility_status__c set
        //assert that the dvd_entity records have some licence_check__c set
        List<DVD_Query__c> resQueries = [SELECT Id, Overall_Result__c, Eligibility_Status__c FROM DVD_Query__c];
        List<DVD_Entity__c> resEntities = [SELECT Id, Vehicle_Check__c FROM DVD_Entity__c];
        
        for(DVD_Query__c resQ: resQueries){
            System.assert(resQ.Overall_Result__c != NULL, 'Error: No overall status received for this test for queryParam');
        }
        for(DVD_Entity__c resE: resEntities){
            System.assert(resE.Vehicle_Check__c != NULL, 'Error: No eligibility check updated for this test in Entity');
        }
    }   
    
}