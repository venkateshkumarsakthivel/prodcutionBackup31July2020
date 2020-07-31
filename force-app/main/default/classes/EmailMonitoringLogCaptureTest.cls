@isTest
public class EmailMonitoringLogCaptureTest {
public static Messaging.InboundEmail emailDATA ;
public static Messaging.InboundEnvelope emaileVDATA  ;
public static string getAuthName;

public static testMethod void TestMyController() {
 //Authorisation data

        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'Authorisation Fees - Annual');
        insert prod;
        // Create a std price book
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 1, IsActive = true);
        insert standardPrice;
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='P2P Default', isActive=true);
        insert customPB;
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id,UnitPrice = 1, IsActive = true);
        insert customPrice;
        
        // set auth start and end date of auth
        Integer currentYear = System.now().Year();
        Integer pastYear = currentYear - 2;
        Integer futureYear = currentYear + 2;
        String authStartDate = '10/12/'+pastYear;
        String authEndDate = '10/12/'+futureYear;
        Boolean DonotsendAuthorisationFee = false;
        
        Auth_Fee_Collection_Period_Configuration__mdt  FeeCollectionPeriod = [SELECT Start_Date__c, End_Date__c 
                                                                              FROM Auth_Fee_Collection_Period_Configuration__mdt
                                                                              WHERE Year__c = :String.valueOf(currentYear) LIMIT 1];
        
        Date assessmentStart = FeeCollectionPeriod.Start_Date__c;
        assessmentStart.addDays(20);
        Date assessmentEnd = FeeCollectionPeriod.Start_Date__c;
        assessmentEnd.addDays(60);
        
        //Create on account without any assessments
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION).getRecordTypeId();
        Account ac1 = new Account(ACN__c = '1234567899',ABN__c = '123456777', Name = 'testAcc1',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac1;
        
        /* Contact Related to company account */
        Contact con1 = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac1.Id,Birthdate = Date.parse('01/01/1992'), Email='test1@contest.com',FirstName = 'Name1',Phone='0211111111',Primary_Contact__c = true);
        insert con1;
        
        /* Authorisation__c Related to company account */
        Authorisation__c tspauth1 = new Authorisation__c(Name = '774758857', Service_Provider__c = ac1.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con1.Id,Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS , Authorisation_Type__c = 'Taxi Licence');
        insert tspauth1;
        
        tspauth1.Start_Date__c = Date.parse(authStartDate);
        tspauth1.End_Date__c = Date.parse(authEndDate);
        update tspauth1;  
        
        getAuthName = tspauth1.Name;

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email
        email.subject = 'Taxi Licence End Date Due Reminder';
        email.FromAddress = 'sbrady@digitalhands.com';
        email.plainTextBody ='my attachment text contacting you regarding taxi licence no. ' +getAuthName+ ' which will expire on';
        env.fromAddress = 'sbrady@digitalhands.com';

        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text contacting you regarding taxi licence no.' +getAuthName+ 'which will expire on');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        emailDATA = email; 
        emaileVDATA = env;

        // call the email service class and test it with the data in the testMethod
        EmailMonitoringLogCapture  emailProcess = new EmailMonitoringLogCapture ();
        emailProcess.handleInboundEmail(email, env);

        // create a new email and envelope object
        Messaging.InboundEmail emailNegative = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envNegative = new Messaging.InboundEnvelope();

        // setup the data for the email
        emailNegative .subject = 'Taxi eminder';
        emailNegative .FromAddress = 'sbrady@digitalhands.com';
        emailNegative .plainTextBody ='my attachment text contacting you regarding taxi licence no. ' +getAuthName+ ' which will expire on';
        envNegative .fromAddress = 'sbrady@digitalhands.com';
        
        EmailMonitoringLogCapture  emailProcessNegative = new EmailMonitoringLogCapture ();
        emailProcessNegative.handleInboundEmail(emailNegative , envNegative );
}
}