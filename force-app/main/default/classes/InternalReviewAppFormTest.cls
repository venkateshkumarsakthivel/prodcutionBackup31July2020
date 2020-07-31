@isTest
public class InternalReviewAppFormTest {
    
    @isTest
    private static void getAuthorisationDetailsTest(){
        //create new account
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testClassUser', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
   
        //create new authorisation
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id);
        insert auth;
  
        String portalContextName = 'ASP';
        
        InternalReviewAppFormController.InternalReviewAppWrapper interReviewWrap = new InternalReviewAppFormController.InternalReviewAppWrapper();
        
        Test.startTest();
            interReviewWrap = InternalReviewAppFormController.getAuthorisationDetails(auth.Id, portalContextName);
        Test.stopTest();
        
        String reviewableDecisionsRecordId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS).getRecordTypeId();
        System.assert(interReviewWrap.csObj.RecordTypeId == reviewableDecisionsRecordId);
    }
    
    @isTest
    private static void saveSectionDataTest(){
        //create new account
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testClassUser', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
   
        //create new authorisation
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id);
        insert auth;
        
        InternalReviewAppFormController.InternalReviewAppWrapper interReviewWrap = new InternalReviewAppFormController.InternalReviewAppWrapper();
        interReviewWrap.isAuthorisationNumberValid = true;
        interReviewWrap.authorisationRecordID = auth.Id;
        
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('SObject', interReviewWrap);
        String jsonstr = (String)JSON.serialize(parameters.get('SObject'));
        
        Test.startTest();
            interReviewWrap = InternalReviewAppFormController.saveSectionData(jsonstr);
        Test.stopTest();
        
        System.assert(interReviewWrap.isAuthorisationNumberValid == true);
        
    }
    
    @isTest
    private static void saveSectionDataTestIncorrectAuthorisationNumber(){
        //create new account
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testClassUser', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
   
        //create new authorisation
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id);
        insert auth;
       
        InternalReviewAppFormController.InternalReviewAppWrapper interReviewWrap = new InternalReviewAppFormController.InternalReviewAppWrapper();
        interReviewWrap.isAuthorisationNumberValid = false;
        interReviewWrap.authorisationRecordID = auth.Id;
        
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('SObject', interReviewWrap);
        String jsonstr = (String)JSON.serialize(parameters.get('SObject'));
        
        Test.startTest();
            interReviewWrap = InternalReviewAppFormController.saveSectionData(jsonstr);
        Test.stopTest();
        
        System.assert(interReviewWrap.message == 'Please enter the valid Authorisation number');
    }
   
    @isTest
    private static void saveSectionDataTestASPAuthorisation(){
        //create new account
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testClassUser', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
   
        //create new authorisation
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Status__c = 'New');
        insert auth;
        
        InternalReviewAppFormController.InternalReviewAppWrapper interReviewWrap = new InternalReviewAppFormController.InternalReviewAppWrapper();
        interReviewWrap.isAuthorisationNumberValid = false;
        interReviewWrap.portalContextName = 'ASP';
        
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('SObject', interReviewWrap);
        String jsonstr = (String)JSON.serialize(parameters.get('SObject'));
        
        Test.startTest();
            interReviewWrap = InternalReviewAppFormController.saveSectionData(jsonstr);
        Test.stopTest();
        
        System.assert(interReviewWrap.isSuccess == false);
        
    }
    
    @isTest
    private static void submitReviewApplicationTest(){
        InternalReviewAppFormController.InternalReviewAppWrapper interReviewWrap = new InternalReviewAppFormController.InternalReviewAppWrapper();
        
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('SObject', interReviewWrap);
        String jsonstr = (String)JSON.serialize(parameters.get('SObject'));
        
        Test.startTest();
            interReviewWrap = InternalReviewAppFormController.submitReviewApplication(jsonstr);
        Test.stopTest();
        
        System.assert(interReviewWrap.csObj.status == 'Lodged');
    }
    
    @isTest
    private static void attachmentUploadedCheckTest(){
        Boolean check = false;
        Id ownerid = GlobalUtility.getOwnerId();
        Id internalReviewCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS).getRecordTypeId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Contact__c = con.Id, Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth;
        Case cas = new Case(AccountId=ac.id,RecordtypeId=internalReviewCaseRecordTypeId,Authorisation__c=auth.Id,ContactId=con.Id,Postcode__c='2000',City__c='Sydney',Status = 'Closed',State__c='NSW',Street_Address_Line_1__c='Castlereagh Street',A__c=true,Full_Occurrence_description__c='Test',Description_of_cause_contributing_factor__c='Test',Description_of_follow_up_action__c='Test');
        insert cas;
        
        Attachment tempAtt = new Attachment();
            tempAtt.ParentId = cas.Id;
            tempAtt.Body = Blob.valueOf('Unit Test Attachment Body');
            tempAtt.Name = 'Unit Test Attachment';
            insert tempAtt;
        
        Test.startTest();
            check = InternalReviewAppFormController.attachmentUploadedCheck(cas.Id);
        Test.stopTest();
        
        System.assert(check == true);    
    }
    
    @isTest
    private static void getAuthorisationDetailsForAccountTest(){
        //create new account
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testClassUser', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
   
        //create new authorisation
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id);
        insert auth;
  
        String portalContextName = 'ASP';
        
        InternalReviewAppFormController.InternalReviewAppWrapper interReviewWrap = new InternalReviewAppFormController.InternalReviewAppWrapper();
        
        Test.startTest();
            interReviewWrap = InternalReviewAppFormController.getAuthorisationDetailsForAccount(ac.Id);
        Test.stopTest();
        
        String reviewableDecisionsRecordId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS).getRecordTypeId();
        System.assert(interReviewWrap.csObj.RecordTypeId == reviewableDecisionsRecordId);
    }
    
    @isTest
    private static void getAuthorisationTypeTest(){
        Id ownerid = GlobalUtility.getOwnerId();
        
        Account ac = new Account(name ='testClassUser', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
   
        //create new authorisation
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Authorisation_Type__c = 'BSP');
        insert auth;
        
        Test.startTest();
            String authType = InternalReviewAppFormController.getAuthorisationType(auth.Id);
        Test.stopTest();
        
        System.assert(authType == 'BSP');
    }
    
    @isTest
    private static void getValidateUserTest(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='P2P Operations Level 2'];
        
        String userName = 'testpermissionsetuser12'+Datetime.Now().Millisecond()+'@testorg.com';
        
        User user = new User(Alias = 'stand', Email='standarduser12@testorg.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p.Id,
                             TimeZoneSidKey='America/Los_Angeles',   UserName=userName);
        
        
        insert user;
        
        Id userId = [Select id , Name from User where UserName=:userName].id;
        PermissionSet ps = [select Id from PermissionSet where Name ='Sanctions_Operations_Staff'];
        
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        boolean result;   
        Test.startTest();
        System.runAs(user){   
            result =  InternalReviewAppFormController.getValidateUser();
            System.assertEquals(true, result);
        }
        result = InternalReviewAppFormController.getValidateUser();
        System.assertNotEquals(true, result);
        System.debug('result is '+ result);
        Test.stopTest();   
    }
    
    @isTest static void getAuthorisationDetailsByIdTest(){
        InternalReviewAppFormController.AuthorisationWrapper authWrap = new InternalReviewAppFormController.AuthorisationWrapper();
        
        Id ownerid = GlobalUtility.getOwnerId();
        
        Account ac = new Account(name ='testClassUser', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
   
        //create new authorisation
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Authorisation_Type__c = 'BSP',Name = 'BSP-00100');
        insert auth;
        
        system.debug(auth);
        
        Test.startTest();
            authWrap = InternalReviewAppFormController.getAuthorisationDetailsbyId(auth.Name);
        Test.stopTest();
        
        System.assert(authWrap.isSuccess == false);        
    }
}