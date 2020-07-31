@isTest
public class InviteTaxiApplicantControllerTest {   
    @testSetup 
    static void TestSetup(){
        try{
            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            insert ac;
            Contact con = new Contact(FirstName = 'testFname', LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
            insert con;
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InviteTaxiApplicantControllerTest','TestSetup',ex.getMessage(),ex);
        }   
    }
    
    /* Commented as it is no longer in use
    //Is all tender applications are completed checking
    @isTest
    private static void isAllTenderApplicationsCompletedPositiveTest(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
            Id rtIdforTender = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TENDER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            Id p = GlobalUtility.getASPProfile().id;
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                 contactId = conId,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            
            List<Case> casesToBeInsert = new List<Case>();
            
            Case Caserec1 = new Case();
            Caserec1.AccountId = user.AccountId;
            Caserec1.ContactId = user.ContactId;
            Caserec1.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec1.Status = GlobalConstants.CASE_NEW;
            Caserec1.RecordTypeId = rtIdforTender;
            
            insert Caserec1;
            
            Case Caserec2 = new Case();
            Caserec2.AccountId = user.AccountId;
            Caserec2.ContactId = user.ContactId;
            Caserec2.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec2.Status = GlobalConstants.CASE_NEW;
            Caserec2.Sub_Status__c = GlobalConstants.WITHDRAWN_CASE_SUB_STATUS;
            Caserec2.ParentId = Caserec1.Id;
            Caserec2.RecordTypeId = rtIdforIndividual;
            casesToBeInsert.add(CaseRec2);
            
            Case Caserec3 = new Case();
            Caserec3.AccountId = user.AccountId;
            Caserec3.ContactId = user.ContactId;
            Caserec3.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec3.Status = GlobalConstants.CASE_NEW;
            Caserec3.Sub_Status__c = GlobalConstants.WITHDRAWN_CASE_SUB_STATUS;
            Caserec3.ParentId = Caserec1.Id;
            Caserec3.RecordTypeId = rtIdforIndividual;
            casesToBeInsert.add(CaseRec3);
            
            insert casesToBeInsert;
            
            Test.startTest();
            Boolean result;
            System.runAs(user){
                result = InviteTaxiApplicantController.isAllTenderApplicationsCompleted(Caserec1.Id);
            }
            Test.stopTest();
            system.assertEquals(true, result);
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InviteTaxiApplicantControllerTest','isAllTenderApplicationsCompletedPositiveTest',ex.getMessage(),ex);
        }   
    }
    
    //Is all tender applications are completed checking
    @isTest
    private static void isAllTenderApplicationsCompletedNegativeTest(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
            Id rtIdforTender = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TENDER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            Id p = GlobalUtility.getASPProfile().id;
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                 contactId = conId,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            List<Case> casesToBeInsert = new List<Case>();
            
            Case Caserec1 = new Case();
            Caserec1.AccountId = user.AccountId;
            Caserec1.ContactId = user.ContactId;
            Caserec1.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec1.Status = GlobalConstants.CASE_NEW;
            Caserec1.RecordTypeId = rtIdforTender;
            
            insert Caserec1;
            
            Case Caserec2 = new Case();
            Caserec2.AccountId = user.AccountId;
            Caserec2.ContactId = user.ContactId;
            Caserec2.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec2.Status = GlobalConstants.CASE_NEW;
            Caserec2.Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT;
            Caserec2.ParentId = Caserec1.Id;
            Caserec2.RecordTypeId = rtIdforIndividual;
            casesToBeInsert.add(CaseRec2);
            
            Case Caserec3 = new Case();
            Caserec3.AccountId = user.AccountId;
            Caserec3.ContactId = user.ContactId;
            Caserec3.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec3.Status = GlobalConstants.CASE_NEW;
            Caserec3.Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT;
            Caserec3.ParentId = Caserec1.Id;
            Caserec3.RecordTypeId = rtIdforIndividual;
            casesToBeInsert.add(CaseRec3);
            
            insert casesToBeInsert;
            
            Test.startTest();
            Boolean result;
            System.runAs(user){
                result = InviteTaxiApplicantController.isAllTenderApplicationsCompleted(Caserec1.Id);
            }
            Test.stopTest();
            system.assertEquals(false, result);
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InviteTaxiApplicantControllerTest','isAllTenderApplicationsCompletedNegativeTest',ex.getMessage(),ex);
        }   
    }
    */

    //Is all tender applications have email
    @isTest
    private static void isAllTenderAppsHaveContactEmailPositiveTest(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Contact con = [select id, Email from contact where AccountId =:accountId LIMIT 1];
            Id rtIdforTender = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TENDER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            Id p = GlobalUtility.getASPProfile().id;
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                 contactId = con.Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            
            List<Case> casesToBeInsert = new List<Case>();
            
            Case Caserec1 = new Case();
            Caserec1.AccountId = user.AccountId;
            Caserec1.ContactId = user.ContactId;
            Caserec1.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec1.Status = GlobalConstants.CASE_NEW;
            Caserec1.RecordTypeId = rtIdforTender;
            
            insert Caserec1;
            
            Case Caserec2 = new Case();
            Caserec2.AccountId = user.AccountId;
            Caserec2.ContactId = user.ContactId;
            Caserec2.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec2.Status = GlobalConstants.CASE_NEW;
            Caserec2.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            Caserec2.ParentId = Caserec1.Id;
            Caserec2.RecordTypeId = rtIdforIndividual;
            casesToBeInsert.add(CaseRec2);
            
            Case Caserec3 = new Case();
            Caserec3.AccountId = user.AccountId;
            Caserec3.ContactId = user.ContactId;
            Caserec3.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec3.Status = GlobalConstants.CASE_NEW;
            Caserec3.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            Caserec3.ParentId = Caserec1.Id;
            Caserec3.RecordTypeId = rtIdforIndividual;
            casesToBeInsert.add(CaseRec3);
            
            insert casesToBeInsert;
            
            Test.startTest();
            Boolean result;
            System.runAs(user){
                result = InviteTaxiApplicantController.validateApplicationDetails(Caserec1.Id);
                system.assertEquals(false, result);
                //Negative test
                con.Email = '';
                update con;
                result = InviteTaxiApplicantController.validateApplicationDetails(Caserec1.Id);
                system.assertEquals(true, result);

            }
            Test.stopTest();
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InviteTaxiApplicantControllerTest','isAllTenderAppsHaveContactEmailPositiveTest',ex.getMessage(),ex);
        }   
    }

    @isTest
    private static void processAccountForCaseTestForActivatedAccount(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
            Id rtIdforTender = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TENDER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            List<Account> accToBeInsert = new List<Account>();
            List<Contact> contactsToBeInserted = new List<Contact>();
            List<User> userListToBeInserted = new List<User>();
            
            
            Account childAcc1,childAcc2;
            Contact childcon1,childcon2;
            Case parentCase = new Case();
            
            Account parentacc = new Account(name ='parent Account', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            insert parentacc;
            
            Contact parentcon = new Contact(LastName ='parent Contact',AccountId = parentacc.Id, Email='test@contest.com');
            insert parentcon;
            
            
            parentCase.AccountId = parentcon.AccountId;
            parentCase.ContactId = parentcon.Id;
            parentCase.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            parentCase.Status = GlobalConstants.CASE_NEW;
            parentCase.RecordTypeId = rtIdforTender;
            insert parentCase;
            
            childAcc1 = new Account(name ='child Account1', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            accToBeInsert.add(childAcc1);
            childAcc2 = new Account(name ='child Account2', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000'); 
            accToBeInsert.add(childAcc2);
            insert  accToBeInsert;
            
            childcon1 = new Contact(LastName ='child Contact 1',AccountId = childAcc1.Id, Email='test1@contest1.com');
            contactsToBeInserted.add(childcon1);
            childcon2 = new Contact(LastName ='child Contact 2',AccountId = childAcc2.Id, Email='test2@contest2.com');
            contactsToBeInserted.add(childcon2);
            insert contactsToBeInserted;
            
            Id p = [select id from profile where name = 'Authorised Service Provider'].id;
            User user1 = new User(alias = 'test123', email='test123@noemail1.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid = p, country='United States', IsActive =true,contactId = childcon1.Id,timezonesidkey='America/Los_Angeles',
                                  username='tester1@noemail.com');
            userListToBeInserted.add(user1);
            
            
            insert userListToBeInserted;
            
            
            List<Case> CaseToCreate = new List<Case> ();
            
            Case childCase1 = new Case();
            childCase1.AccountId = childcon1.AccountId;
            childCase1.ContactId = childcon1.Id;
            childCase1.ParentId = parentCase.Id;
            childCase1.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            childCase1.Status = GlobalConstants.CASE_NEW;
            childCase1.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            childCase1.RecordTypeId = rtIdforIndividual;
            CaseToCreate.add(childCase1);
            
            Case childCase2 = new Case();
            childCase2.AccountId = childcon1.AccountId;
            childCase2.ContactId = childcon1.Id;
            childCase2.ParentId = parentCase.Id;
            childCase2.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            childCase2.Status = GlobalConstants.CASE_NEW;
            childCase2.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            childCase2.RecordTypeId = rtIdforIndividual;
            CaseToCreate.add(childCase2);
            
            Case childCase3 = new Case();
            childCase3.AccountId = childcon2.AccountId;
            childCase3.ContactId = childcon2.Id;
            childCase3.ParentId = parentCase.Id;
            childCase3.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            childCase3.Status = GlobalConstants.CASE_NEW;
            childCase3.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            childCase3.RecordTypeId = rtIdforIndividual;
            CaseToCreate.add(childCase3);
            
            Case childCase4 = new Case();
            childCase4.AccountId = childcon2.AccountId;
            childCase4.ContactId = childcon2.Id;
            childCase4.ParentId = parentCase.Id;
            childCase4.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            childCase4.Status = GlobalConstants.CASE_NEW;
            childCase4.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            childCase4.RecordTypeId = rtIdforIndividual;
            CaseToCreate.add(childCase4);
            
            insert CaseToCreate;
            
            test.startTest();
            InviteTaxiApplicantController.processAccountForCase(parentCase.Id);
            test.stopTest();
            
            User u = [Select Id, Profile.Name from User Where ContactId =: childcon1.Id];
            
            System.assertEquals(u.Profile.Name, GlobalConstants.Taxi_ASP_PROFILE_NAME);
            
        }
        catch(Exception ex){
        
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InviteTaxiApplicantControllerTest','processAccountForCaseTestForActivatedAccount',ex.getMessage(),ex);
        }   
    }
    
    @isTest
    private static void processAccountForCaseTestForDeactivatedAccount(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
            Id rtIdforTender = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TENDER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            List<Account> accToBeInsert = new List<Account>();
            List<Contact> contactsToBeInserted = new List<Contact>();
            
            Account childAcc1,childAcc2;
            Contact childcon1,childcon2;
            Case parentCase = new Case();
            
            Account parentacc = new Account(name ='parent Account', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            insert parentacc;
            
            Contact parentcon = new Contact(LastName ='parent Contact',AccountId = parentacc.Id, Email='test@contest.com');
            insert parentcon;
            
            
            parentCase.AccountId = parentcon.AccountId;
            parentCase.ContactId = parentcon.Id;
            parentCase.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            parentCase.Status = GlobalConstants.CASE_NEW;
            parentCase.RecordTypeId = rtIdforTender;
            insert parentCase;
            
            childAcc1 = new Account(name ='child Account1', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            accToBeInsert.add(childAcc1);
            childAcc2 = new Account(name ='child Account2', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000'); 
            accToBeInsert.add(childAcc2);
            insert  accToBeInsert;
            
            childcon1 = new Contact(LastName ='child Contact 1',AccountId = childAcc1.Id, Email='test1@contest1.com');
            contactsToBeInserted.add(childcon1);
            childcon2 = new Contact(LastName ='child Contact 2',AccountId = childAcc2.Id, Email='test2@contest2.com');
            contactsToBeInserted.add(childcon2);
            insert contactsToBeInserted;
            
            
            List<Case> CaseToCreate = new List<Case> ();
            
            Case childCase1 = new Case();
            childCase1.AccountId = childcon1.AccountId;
            childCase1.ContactId = childcon1.Id;
            childCase1.ParentId = parentCase.Id;
            childCase1.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            childCase1.Status = GlobalConstants.CASE_NEW;
            childCase1.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            childCase1.RecordTypeId = rtIdforIndividual;
            CaseToCreate.add(childCase1);
            
            Case childCase2 = new Case();
            childCase2.AccountId = childcon1.AccountId;
            childCase2.ContactId = childcon1.Id;
            childCase2.ParentId = parentCase.Id;
            childCase2.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            childCase2.Status = GlobalConstants.CASE_NEW;
            childCase2.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            childCase2.RecordTypeId = rtIdforIndividual;
            CaseToCreate.add(childCase2);
            
            Case childCase3 = new Case();
            childCase3.AccountId = childcon2.AccountId;
            childCase3.ContactId = childcon2.Id;
            childCase3.ParentId = parentCase.Id;
            childCase3.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            childCase3.Status = GlobalConstants.CASE_NEW;
            childCase3.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            childCase3.RecordTypeId = rtIdforIndividual;
            CaseToCreate.add(childCase3);
            
            Case childCase4 = new Case();
            childCase4.AccountId = childcon2.AccountId;
            childCase4.ContactId = childcon2.Id;
            childCase4.ParentId = parentCase.Id;
            childCase4.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            childCase4.Status = GlobalConstants.CASE_NEW;
            childCase4.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
            childCase4.RecordTypeId = rtIdforIndividual;
            CaseToCreate.add(childCase4);
            
            insert CaseToCreate;
            
            test.startTest();
            string str =  InviteTaxiApplicantController.processAccountForCase(parentCase.Id);
            test.stopTest();
            system.assertEquals('Success',str);  
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InviteTaxiApplicantControllerTest','processAccountForCaseTestForDeactivatedAccount',ex.getMessage(),ex);
        } 
    }
}