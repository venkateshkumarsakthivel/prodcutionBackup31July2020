@IsTest
private with sharing class AuthorisationNumberGeneratorTest {
    
    private static Account act;
    
    private static testMethod void testForNewTsp(){
        act = [SELECT ID FROM Account];
        Authorisation__c auth = createAuthorisation(GlobalConstants.AUTHORISATION_TYPE_TSP);
        
        System.Test.startTest();
        AuthorisationNumberGenerator numberGenerator = new AuthorisationNumberGenerator();
        numberGenerator.generate(new List<Authorisation__c>{auth});
        System.Test.stopTest();
        
        System.assert(auth.Auto_Generate_Number__c);
    }
    
    private static testMethod void testForNewBsp(){
        act = [SELECT ID FROM Account];
        Authorisation__c auth = createAuthorisation(GlobalConstants.AUTHORISATION_TYPE_BSP);
        
        System.Test.startTest();
        AuthorisationNumberGenerator numberGenerator = new AuthorisationNumberGenerator();
        numberGenerator.generate(new List<Authorisation__c>{auth});
        System.Test.stopTest();
        
        System.assert(auth.Auto_Generate_Number__c);
    }
    
    private static testMethod void testForTaxiLicence(){
        act = [SELECT ID FROM Account];
        Authorisation__c auth = createAuthorisation(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
        
        System.Test.startTest();
        AuthorisationNumberGenerator numberGenerator = new AuthorisationNumberGenerator();
        numberGenerator.generate(new List<Authorisation__c>{auth});
        System.Test.stopTest();
        
        System.assert(auth.Auto_Generate_Number__c);
    }
    
    private static testMethod void testForExistingTsp(){
        act = [SELECT ID FROM Account];
        insert createAuthorisation(GlobalConstants.AUTHORISATION_TYPE_TSP);
        
        Authorisation__c existingAuthorisation = [SELECT Id, Name FROM Authorisation__c 
                                                    WHERE Service_Provider__c = :act.Id];
        Authorisation__c auth = createAuthorisation(GlobalConstants.AUTHORISATION_TYPE_TSP);
        
        System.Test.startTest();
        AuthorisationNumberGenerator numberGenerator = new AuthorisationNumberGenerator();
        numberGenerator.generate(new List<Authorisation__c>{auth});
        System.Test.stopTest();
        
        System.assert(!auth.Auto_Generate_Number__c);
        System.assert(auth.Name == existingAuthorisation.Name);
    }
    
    private static testMethod void testForExistingBsp(){
        act = [SELECT ID FROM Account];
        insert createAuthorisation(GlobalConstants.AUTHORISATION_TYPE_BSP);
        
        Authorisation__c existingAuthorisation = [SELECT Id, Name FROM Authorisation__c 
                                                    WHERE Service_Provider__c = :act.Id];
        Authorisation__c auth = createAuthorisation(GlobalConstants.AUTHORISATION_TYPE_BSP);
        
        System.Test.startTest();
        AuthorisationNumberGenerator numberGenerator = new AuthorisationNumberGenerator();
        numberGenerator.generate(new List<Authorisation__c>{auth});
        System.Test.stopTest();
        
        System.assert(!auth.Auto_Generate_Number__c);
        System.assert(auth.Name == existingAuthorisation.Name);
    }
    
    private static testMethod void testForExistingLicence(){
        act = [SELECT ID FROM Account];
        insert createAuthorisation(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        
        Authorisation__c existingAuthorisation = [SELECT Id, Name FROM Authorisation__c 
                                                    WHERE Service_Provider__c = :act.Id];
        Authorisation__c auth = createAuthorisation(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        auth.Variation_Auth_Id__c = existingAuthorisation.Id;
        
        System.Test.startTest();
        AuthorisationNumberGenerator numberGenerator = new AuthorisationNumberGenerator();
        numberGenerator.generate(new List<Authorisation__c>{auth});
        System.Test.stopTest();
        
        System.assert(!auth.Auto_Generate_Number__c);
    }
    
    @TestSetup
    private static void setupTestData(){
        createAccount();
    }
    
    private static void createAccount(){
        act = new Account();
        act.Name = 'Test Account';
        act.Document_Delivery_Preference__c = 'Email';
        act.ACN__c = '123123123';
        act.Phone = '0231313112';
        act.Notice_Address_City__c = 'Sydney';
        act.Notice_Address_Country__c = 'Australia';
        act.Notice_Address_Postal_Code__c = '2000';
        act.Notice_Address_State__c = 'NSW';
        act.Notice_Address_Street__c = '241 Pitt Street, Haymarket';
        
        insert act;
    }
    
    private static Authorisation__c createAuthorisation(String type){
        Authorisation__c auth = new Authorisation__c();
        auth.Service_Provider__c = act.Id;
        auth.Authorisation_Type__c = type;
        auth.Start_Date__c = System.today().addMonths(-6);
        auth.End_Date__c = System.today().addMonths(6);
        auth.Authorisation_Name__c = 'Test Account';
        
        return auth;
    }
}