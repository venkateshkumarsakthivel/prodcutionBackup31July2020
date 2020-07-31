@isTest
public class P2POSRReassessmentHandlerTest {
    
    @testSetup
    static void setup() {
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), 
                                  Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
            
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id, Levy_Contact__c = con.Id, 
                                                                               ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayerData.Revenue_NSW_Status__c = 'Pending';
        taxPayerData.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        insert taxPayerData;
            
    }
    
    @isTest
    private static void getAccountDetailsTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Tax_Payer_Registration__c taxPayerData = [select id from Tax_Payer_Registration__c LIMIT 1];
        
        List<Assessment__c> assessmentList = new List<Assessment__c>();
        List<Tax_Payer_Registration__c> taxPayerRegistrations = new List<Tax_Payer_Registration__c>();
        Date todayPlusOne = System.today() + 1;
        Id grantedAuthRTID = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get('Granted Authorisation').getRecordTypeId();
        
        List<Authorisation__c> authList = new List<Authorisation__c>();
        Authorisation__c authRec1 = new Authorisation__c(RecordTypeId = grantedAuthRTID, Authorisation_Type__c = 'TSP' ,Start_Date__c = System.today()-20,
                                                        End_Date__c = todayPlusOne,Service_Provider__c = accountId, Status__c ='Granted');

        Authorisation__c authRec2 = new Authorisation__c(RecordTypeId = grantedAuthRTID, Authorisation_Type__c = 'TSP' ,Start_Date__c = System.today()-20,
                                                        End_Date__c = todayPlusOne,Service_Provider__c = accountId, Status__c ='Granted');
        
        Authorisation__c authRec3 = new Authorisation__c(RecordTypeId = grantedAuthRTID, Authorisation_Type__c = 'BSP' ,Start_Date__c = System.today()-20,
                                                        End_Date__c = todayPlusOne, Service_Provider__c = accountId, Status__c ='Granted');
        
        Authorisation__c authRec4 = new Authorisation__c(RecordTypeId = grantedAuthRTID, Authorisation_Type__c = 'BSP' ,Start_Date__c = System.today()-20,
                                                        End_Date__c = todayPlusOne, Service_Provider__c = accountId, Status__c ='Granted');
        
        authList.add(authRec1);
        authList.add(authRec2);
        authList.add(authRec3);
        authList.add(authRec4);
        insert authList;
        
        
        Tax_Payer_Registration__c taxPayer1 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c = conId, 
                                                                            ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayer1.Revenue_NSW_Status__c = 'Pending';
        taxPayer1.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        taxPayer1.Taxi_Service_Provider_Number__c = authRec1.Id;
        taxPayer1.Status__c = 'Active';
        //taxPayer1.Booking_Service_Provider_Number__c = authRec1;
        taxPayerRegistrations.add(taxPayer1);
        
        Tax_Payer_Registration__c taxPayer2 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c = conId, 
                                                                            ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayer2.Revenue_NSW_Status__c = 'Pending';
        taxPayer2.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        taxPayer2.Taxi_Service_Provider_Number__c = authRec2.Id;
        taxPayer2.Status__c = 'Active';
        //taxPayer1.Booking_Service_Provider_Number__c = authRec1;
        taxPayerRegistrations.add(taxPayer2);
        
        Tax_Payer_Registration__c taxPayer3 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c = conId, 
                                                                            ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayer3.Revenue_NSW_Status__c = 'Pending';
        taxPayer3.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        taxPayer3.Taxi_Service_Provider_Number__c = authRec3.Id;
        taxPayer3.Status__c = 'Active';
        taxPayerRegistrations.add(taxPayer3);
        
        Tax_Payer_Registration__c taxPayer4 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c = conId, 
                                                                            ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayer4.Revenue_NSW_Status__c = 'Pending';
        taxPayer4.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        taxPayer4.Taxi_Service_Provider_Number__c = authRec4.Id;
        //taxPayer4.Booking_Service_Provider_Number__c = authRec4.Id;
        taxPayer4.Status__c = 'Active';
        taxPayerRegistrations.add(taxPayer4);
        insert taxPayerRegistrations;
        
        Assessment__c assessment1 = new Assessment__c();
        assessment1.Account__c = accountId;
        assessment1.Status__c = 'Issued';
        assessment1.Period_Start_Date__c = System.Today().addMonths(-1);
        assessment1.Taxpayer_Registration__c = taxPayer1.Id;
        assessment1.Payment_via_Sweep__c = FALSE;
        assessment1.Assessment_Type__c = 'Assessment';
        insert assessment1;
        
        Assessment__c assessment2 = new Assessment__c();
        assessment2.Account__c = accountId;
        assessment2.Status__c = 'Issued';
        assessment2.Period_Start_Date__c = System.Today().addMonths(-1);
        assessment2.Taxpayer_Registration__c = taxPayer2.Id;
        assessment2.Payment_via_Sweep__c = FALSE;
        assessment2.Assessment_Type__c = 'Reassessment';
        assessment2.Related_Assessment__c = assessment1.Id;
        assessmentList.add(assessment2);
        
        Assessment__c assessment3 = new Assessment__c();
        assessment3.Account__c = accountId;
        assessment3.Status__c = 'Issued';
        assessment3.Period_Start_Date__c = System.Today().addMonths(-1);
        assessment3.Payment_Due_Date__c = System.today();
        assessment3.Taxpayer_Registration__c = taxPayer3.Id;
        assessment3.Payment_via_Sweep__c = FALSE;
        assessment3.Assessment_Type__c = 'Reassessment';
        assessment3.Related_Assessment__c = assessment1.Id;
        assessmentList.add(assessment3);
        
        Assessment__c assessment4 = new Assessment__c();
        assessment4.Account__c = accountId;
        assessment4.Status__c = 'Issued';
        assessment3.Period_Start_Date__c = System.Today().addMonths(-1);
        assessment4.Payment_Due_Date__c = System.today()-20;
        assessment4.Taxpayer_Registration__c = taxPayer4.Id;
        assessment4.Payment_via_Sweep__c = FALSE;
        assessment4.Assessment_Type__c = 'Reassessment';
        assessment4.Related_Assessment__c = assessment1.Id;
        //assessmentList.add(assessment4);
        insert assessmentList;

        Test.startTest();
                
        assessmentList = [SELECT Id, Name, Account__r.Customer_Number__c, 
                          Period_Start_Date__c, Period_End_Date__c, 
                          TSP_Assessment_Number__c, BSP_Assessment_Number__c, 
                          Revenue_Assessment_Number_TSP__c, Revenue_Assessment_Number_BSP__c, 
                          TSP_Levy_Amount__c, BSP_Levy_Amount__c, 
                          Taxpayer_Registration__r.Taxi_Service_Provider_Number__c, 
                          Taxpayer_Registration__r.Booking_Service_Provider_Number__c,
                          Related_Assessment__c, Related_Assessment__r.Revenue_Assessment_Number_TSP__c,
                          Related_Assessment__r.Revenue_Assessment_Number_BSP__c
                          FROM Assessment__c];
        for(Assessment__c assessment : assessmentList) {
            System.debug('tsp number: '+assessment.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c);
            System.debug('bsp number: '+assessment.Taxpayer_Registration__r.Booking_Service_Provider_Number__c);
        }
        P2POSRReassessmentHandler handler = new P2POSRReassessmentHandler(assessmentList);
        handler.process();
        
        Test.stopTest();

        
    }
        
}