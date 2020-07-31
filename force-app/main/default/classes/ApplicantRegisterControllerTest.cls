@isTest
private class ApplicantRegisterControllerTest {
    @isTest
    private static void handleApplicantRegister_IndividualTest(){
        ApplicantRegisterController ar = new ApplicantRegisterController();
        String returnValue;
        String firstname = 'John';
        String lastname = 'Walker';
        string email = 'p2p+test@arxxus.com';
        String mobile = '0423456789';
        String entity = 'Individual';
        String acn = '';  
        String companyName = '';
        test.startTest();
        system.runAs(new User(Id = userInfo.getUserId())){
            returnValue = ApplicantRegisterController.handleApplicantRegister(firstname,lastname,GlobalConstants.PROSPECTIVE_SERVICE_PROVIDER_USER_PROFILE_NAME, email,mobile,entity,acn,companyName,'');
        }
        test.stopTest();
        System.assertEquals('Success', returnValue);
    }
    
     @isTest
    private static void handleApplicantRegister_CorporationTest(){
        String returnValue;
        String firstname = 'John';
        String lastname = 'Walker';
        string email = 'p2p+test1@arxxus.com';
        String mobile = '0423456789';
        String entity = 'Corporation';
        String acn = '128705733';
        String companyName = 'ARXXUS TECHNOLOGY PARTNERS PTY LTD';
        test.startTest();
        system.runAs(new User(Id = userInfo.getUserId())){
            returnValue = ApplicantRegisterController.handleApplicantRegister(firstname,lastname,GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME, email,mobile,entity,acn,companyName,'');
            System.assertEquals('Success', returnValue);        
            //Check existing ACN
            mobile = '0423456780';
            returnValue = ApplicantRegisterController.handleApplicantRegister(firstname,lastname,GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME, email,mobile,entity,acn,companyName,companyName);
            System.assertEquals('Already registerd', returnValue);
        }
        test.stopTest();

    }
    
       
     @isTest
    private static void handleApplicantRegister_IndvCorpTest(){
        
        String returnValue;
        String firstname = 'John';
        String lastname = 'Walker';
        string email = 'p2p+test1@arxxus.com';
        String mobile = '0423456789';
        String entity = GlobalConstants.ACCOUNT_ENTITY_TYPE_INDIVIDUAL_PARTNERSHIP;
        String acn = '128705733';
        String companyName = 'ARXXUS TECHNOLOGY PARTNERS PTY LTD';
        test.startTest();
        system.runAs(new User(Id = userInfo.getUserId())){
            returnValue = ApplicantRegisterController.handleApplicantRegister(firstname,lastname,GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME, email,mobile,entity,acn,companyName,companyName);
        }
        test.stopTest();
        System.assertEquals('Success', returnValue);
    }
    
    @isTest
    private static void handleApplicantRegister_CorporatePartnershipTest(){
        
        String returnValue;
        String firstname = 'John';
        String lastname = 'Walker';
        string email = 'p2p+test1@arxxus.com';
        String mobile = '0423456789';
        String entity = GlobalConstants.ACCOUNT_ENTITY_TYPE_CORPORATE_PARTNERSHIP;
        String acn = '128705733';
        String companyName = 'ARXXUS TECHNOLOGY PARTNERS PTY LTD';
        test.startTest();
        system.runAs(new User(Id = userInfo.getUserId())){
            returnValue = ApplicantRegisterController.handleApplicantRegister(firstname,lastname,GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME, email,mobile,entity,acn,companyName,companyName);
        }
        test.stopTest();
         System.assertEquals('Success', returnValue);
    }
    
    @isTest
    private static void handleApplicantRegister_ExceptionTest() {
    
        String returnValue;
        String firstname = 'John';
        String lastname = 'Walker';
        string email = 'pritisingh9217@gmail.com';
        String mobile = '0423456789';
        String entity = 'Corporation Account';
        String acn = '128705733';
        String companyName = 'ARXXUS TECHNOLOGY PARTNERS PTY LTD';
        test.startTest();
        system.runAs(new User(Id = userInfo.getUserId())){
            returnValue = ApplicantRegisterController.handleApplicantRegister(firstname, lastname, GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME, email, mobile, entity, acn,companyName, '');
        }
        test.stopTest();
        System.assertNotEquals('Success', returnValue);
    }
    
    @isTest
    private static void checkForExistingEmailTest(){
        
        Boolean returnValue;
       
        test.startTest();
        
        system.runAs(new User(Id = userInfo.getUserId())){
        
            returnValue = ApplicantRegisterController.checkForExistingEmail('sample@test.com');
        }
        
        test.stopTest();
        System.assertEquals(false, returnValue);
    }

    @isTest
    private static void handleApplicantRegister_MobileRegisteredTest() {
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=UserInfo.getUserId()) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com', MobilePhone = '0423456789');
        insert con;
        String returnValue;
        String firstname = 'John';
        String lastname = 'Walker';
        string email = 'test123@test.com';
        String mobile = '0423456789';
        String entity = 'Corporation Account';
        String acn = '128705733';
        String companyName = 'ARXXUS TECHNOLOGY PARTNERS PTY LTD';
        test.startTest();
        system.runAs(new User(Id = userInfo.getUserId())){
            returnValue = ApplicantRegisterController.handleApplicantRegister(firstname, lastname, GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME, email, mobile, entity, acn,companyName, '');
        }
        test.stopTest();
        System.assertEquals('Mobile registered', returnValue);
    }
}