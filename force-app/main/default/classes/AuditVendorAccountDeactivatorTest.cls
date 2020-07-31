@isTest
public class AuditVendorAccountDeactivatorTest {
    
    @testSetup
    static void setup(){
        Id ownerId = GlobalUtility.getOwnerId();
        RecordType accountAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Account'];
        RecordType contactAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Contact'];
        Account ac = new Account(name ='testAuditor', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
        ac.RecordTypeId = accountAuditRecordType.Id;
        ac.Auditor_Type__c = 'External';
        ac.Auditor_Status__c = 'Active';
        ac.Equip_Vendor_Number__c = 'EVP1234';
        ac.Purchase_Order_Number__c = 'PO1234';
        insert ac;
        
        Contact con = new Contact(LastName ='testCon', firstName= 'test', AccountId = ac.Id, Email='test@contest.com');
        con.RecordTypeId = contactAuditRecordType.Id;
        con.Status__c = 'Active';
        insert con;
    }
    
    @isTest
    public static void deactivateAuditVendorAccountsTest()
    {
        Account tempAcc = [SELECT Name,Auditor_Status__c  FROM Account WHERE Name = 'testAuditor'];
        Contact tempCon = [SELECT Id,Status__c   FROM Contact WHERE LastName ='testCon']; 
        system.debug('*****BEFORE**Account****'+tempAcc) ;
        system.debug('*****BEFORE******'+tempCon.Status__c ) ;
        tempAcc.Auditor_Status__c=GlobalConstants.AUDITOR_STATUS_INACTIVE;
        update tempAcc;
        Account tempAcc1 = [SELECT Name,Auditor_Status__c  FROM Account WHERE Name = 'testAuditor'];
        Contact tempCon1 = [SELECT Id,Status__c   FROM Contact WHERE LastName ='testCon'];  
        system.debug('*****AFTER**Account****'+tempAcc1) ;
        system.debug('*****AFTER******'+tempCon1.Status__c) ;
        System.assertEquals('Inactive', tempCon1.Status__c);
    }
}