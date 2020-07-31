@isTest
private class CriminalOffenceCaseFormControllerTest
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
     		 	valid = CriminalOffenceCaseFormController.isValidUser();
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
     		 	valid = CriminalOffenceCaseFormController.isValidUser();
     		 }
     	Test.stopTest();
     	System.assertEquals(false,valid);
	}
}