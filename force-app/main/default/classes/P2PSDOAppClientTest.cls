/*
 * Tests for E2E callout flow to RMS
 * Tests building req, callout, parsing response, committing response
 */
@isTest
public class P2PSDOAppClientTest {

    private static testmethod void testLicence1(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test SDO Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        List<DVD_Entity__c> sdoEntities = new List<DVD_Entity__c>();
         for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            sdoEntities.add(e);
        }
        insert sdoEntities;
        Test.startTest();
            DVDQueue q = new DVDQueue(aspAcc);
            q.checkAllDrivers();
        Test.stopTest();
        List<DVD_Query__c> queries = [SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, Plate_Number__c, 
                                            Plate_Type__c, VIN_Number_or_Chassis_Number__c, Authorised_Service_Provider__c, DVD_Query_Group__c,
                                            DVD_Entity__c, Requester_Id__c, Organisation_Code__c, Service_Provider_Username__c,
                                            DVD_Entity__r.RecordType.Name, DVD_Entity__r.Authorised_Service_Provider__r.Customer_Number__c, 
                                            Query_Started_At__c, Query_Status__c, DVD_Query_For__c
                                        FROM DVD_Query__c];
        System.assert(queries.size() == 10, 'Error: 10 queries not created...' + queries.size());
        //System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
        
        P2PSDOAppClient sdoClient = new P2PSDOAppClient();
        P2PSDOAppClient.P2PSDOAppResponseParserVisitor visitorSDO = new P2PSDOAppClient.P2PSDOAppResponseParserVisitor();
        for(DVD_Query__c queryParam: queries){
            sdoClient.callSDOApp(queryParam, visitorSDO);
        }
        visitorSDO.updateResponses();
        //assert that the dvd_query records have some overall_status, eligibility_status__c set
        //assert that the dvd_entity records have some licence_check__c set
        List<DVD_Query__c> resQueries = [SELECT Id, Overall_Result__c, Eligibility_Status__c FROM DVD_Query__c];
        List<DVD_Entity__c> resEntities = [SELECT Id, Licence_Check__c FROM DVD_Entity__c];
        
        for(DVD_Query__c resQ: resQueries) {
            System.assert(resQ.Overall_Result__c == 'SUCCESS', 'Error: No overall status received for this test for queryParam');
            System.debug('Result = ' + resQ.Overall_Result__c);
            System.debug('Eligibility_Status__c = ' + resQ.Eligibility_Status__c);
        }
        for(DVD_Entity__c resE: resEntities){
            System.assert(resE.Licence_Check__c != NULL, 'Error: No eligibility check updated for this test in Entity');
            System.debug('Licence_Check = ' + resE.Licence_Check__c);
        }
        
    }
    
    private static testmethod void testErrorResponse(){
        Account aspAcc = new Account();
        aspAcc.Name = 'Test SDO Batch ASP';
        aspAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        insert aspAcc;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        List<DVD_Entity__c> sdoEntities = new List<DVD_Entity__c>();
         for(Integer i=0 ;i <10;i++){
            DVD_Entity__c e = new DVD_Entity__c();
            e.RecordTypeId = driverRTID;
            e.Drivers_Licence_Number__c= 'DLJHK00'+i; 
            e.Date_of_Birth__c = System.today().addYears(-20-Math.mod(200, i+1));
            e.Last_Name__c = 'Driver';
            e.Authorised_Service_Provider__c = aspAcc.Id;
            sdoEntities.add(e);
        }
        insert sdoEntities;
        RMSSDOAPIMockImpl.TEST_FOR_ERROR = true;
        P2PSDOAppClient.TEST_FOR_ERROR = true;
        Test.startTest();
            DVDQueue q = new DVDQueue(aspAcc);
            q.checkAllDrivers();
        Test.stopTest();    
            List<DVD_Query__c> queries = [SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, Plate_Number__c, 
                                            Plate_Type__c, VIN_Number_or_Chassis_Number__c, Authorised_Service_Provider__c, DVD_Query_Group__c,
                                            DVD_Entity__c, Requester_Id__c, Organisation_Code__c, Service_Provider_Username__c,
                                            DVD_Entity__r.RecordType.Name, DVD_Entity__r.Authorised_Service_Provider__r.Customer_Number__c, 
                                            Query_Started_At__c, Query_Status__c, DVD_Query_For__c
                                        FROM DVD_Query__c];
        System.assert(queries.size() == 10, 'Error: 10 queries not created...' + queries.size());
        //System.assert(queries[0].Authorised_Service_Provider__c == aspAcc.Id, 'Error: ASP Id has not matched');
        Id qgId = queries[0].DVD_Query_Group__c;
        DVD_Query_Group__c qg = [SELECT Id, Status__c FROM DVD_Query_Group__c WHERE Id = :qgId LIMIT 1];
        System.assert(qg.Status__c == 'Queued', 'Error: Query Group Status NOT updated in batch post processing!');
        
        P2PSDOAppClient sdoClient = new P2PSDOAppClient();
        P2PSDOAppClient.P2PSDOAppResponseParserVisitor visitorSDO = new P2PSDOAppClient.P2PSDOAppResponseParserVisitor();
        for(DVD_Query__c queryParam: queries){
            sdoClient.callSDOApp(queryParam, visitorSDO);
        }
        visitorSDO.updateResponses();
        
        //assert that the dvd_query records have some overall_status, eligibility_status__c set
        //assert that the dvd_entity records have some licence_check__c set
        List<DVD_Query__c> resQueries = [SELECT Id, Overall_Result__c, Eligibility_Status__c FROM DVD_Query__c];
        List<DVD_Entity__c> resEntities = [SELECT Id, Licence_Check__c FROM DVD_Entity__c];
        
        for(DVD_Query__c resQ: resQueries) {
            System.assert(resQ.Overall_Result__c == 'ERROR' , 'Error: No overall status received for this test for queryParam');
            System.debug('Result = ' + resQ.Overall_Result__c);
            System.debug('Eligibility_Status__c = ' + resQ.Eligibility_Status__c);
        }
        for(DVD_Entity__c resE: resEntities){
            System.assert(resE.Licence_Check__c != NULL, 'Error: No eligibility check updated for this test in Entity');
            System.debug('Licence_Check = ' + resE.Licence_Check__c);
        }
        
    }
  
    
}