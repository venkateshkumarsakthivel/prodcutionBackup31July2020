@isTest
private class RetryOverturnControllerTest
{
    @isTest
    static void isValidUserPositiveTest()
    {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.ADMIN_PROFILE_NAME LIMIT 1];
        
        User usr = new User(LastName = 'Smith',
                           FirstName='John',
                           Alias = 'jsmith',
                           Email = 'Smith.John@abc.com',
                           Username = 'John.Smith'+ System.Now().minute()+System.Now().second()+ System.Now().hour()+'@abc.com',
                           ProfileId = adminProfile.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        boolean valid=false;
        Test.startTest();
             System.runAs(usr) {
                valid = RetryOverturnController.isValidUser();
             }
        Test.stopTest();
        System.assertEquals(true,valid);
    }

    
    @isTest
    static void isValidUserNegativeTest()
    {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'Smith',
                           FirstName='John',
                           Alias = 'jsmith',
                           Email = 'Smith.John@abc.com',
                           Username = 'John.Smith'+ System.Now().minute()+System.Now().second()+ System.Now().hour()+'@abc.com',
                           ProfileId = standardProfile.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        boolean valid=false;
        Test.startTest();
             System.runAs(usr) {
                valid = RetryOverturnController.isValidUser();
             }
        Test.stopTest();
        System.assertEquals(false,valid);
    }
    
    @isTest
    static void updateOvertunStatusInRMSPositiveTest()
    {
        Law_Part_Code__c code=new Law_Part_Code__c();
        code.Name='Test123';
        code.Law_Part_Description__c='Test Data';
        code.Law_Part_Commencement_Date__c=System.Today();
        code.Legislation__c='Crimes Act 1900';
        code.Section_Clause__c='530(1A)';
        code.Status__C='Approved';
        insert code;

        Case parentCase=new Case();
        parentCase.Subject='Overturn charge for licence';
        parentCase.Status='New';
        parentCase.Sub_Status__c='Draft';
        parentCase.Charge_Code_Identifier__c='123456789';
        insert parentCase;

        Case childCase=new Case();
        childCase.Subject='Criminal Offence case for charge code 123456789 : offence code 671478478';
        childCase.ParentId=parentCase.id;
        childCase.Offence_Code__c='671478478';
        childCase.Law_Part_Code__c=code.id;
        childCase.Status='Lodged';
        childCase.Sub_Status__c='Assessment In Progress';
        childCase.Decision__c = 'Record Corrected';
        insert childCase;

        boolean valid=false;
        Test.startTest();
        P2PRMSOvtMockImplementation.reandomCode1=50;
        valid = RetryOverturnController.updateOvertunStatusInRMS(childCase.id);
             
        Test.stopTest();
        System.assertEquals(true,valid);
    }


    @isTest
    static void updateOvertunStatusInRMSNegativeTest()
    {
        Law_Part_Code__c code=new Law_Part_Code__c();
        code.Name='Test123';
        code.Law_Part_Description__c='Test Data';
        code.Law_Part_Commencement_Date__c=System.Today();
        code.Legislation__c='Crimes Act 1900';
        code.Section_Clause__c='530(1A)';
        code.Status__C='Approved';
        insert code;

        Case parentCase=new Case();
        parentCase.Subject='Overturn charge for licence';
        parentCase.Status='New';
        parentCase.Sub_Status__c='Draft';
        parentCase.Charge_Code_Identifier__c='123456789';
        insert parentCase;

        Case childCase=new Case();
        childCase.Subject='Criminal Offence case for charge code 123456789 : offence code 671478478';
        childCase.ParentId=parentCase.id;
        childCase.Offence_Code__c='671478478';
        childCase.Law_Part_Code__c=code.id;
        childCase.Status='Lodged';
        childCase.Sub_Status__c='Assessment In Progress';
        insert childCase;

        boolean valid=false;
        Test.startTest();
        P2PRMSOvtMockImplementation.reandomCode1=50;
        valid = RetryOverturnController.updateOvertunStatusInRMS(childCase.id);
             
        Test.stopTest();
        System.assertEquals(false,valid);
    }
}