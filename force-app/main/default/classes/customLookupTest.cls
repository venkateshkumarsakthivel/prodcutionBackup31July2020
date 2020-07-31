@isTest
public class customLookupTest {
    
    @testSetup
    private static void setupTestData()
    {
        
        Id ownerid = GlobalUtility.getOwnerId();
        
        /* Account created------ */
        Account acc = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                  Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                  Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                  BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                  ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',OwnerId= ownerid);
        insert acc;
        
        
        /* Contact ---*/
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = acc.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        
        /*---Authorisation related to Account--*/
        
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = acc.Id,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = con.Id, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        
        insert taxiAuth;
        
        
    }
    
    @isTest
    private static void fetchAutorisationsTest(){
        String searchKeyWord 		= 'BSP';
        String searchKey 			= searchKeyWord + '%';
        String ObjectName			= 'Authorisation__c';
       
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testClassUser', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
   
        //create new authorisation
        Authorisation__c au = new Authorisation__c(Service_Provider__c = ac.Id, Authorisation_Type__c = 'BSP', Status__c = 'Suspended');
        insert au;
        
        String ObjectId = ac.Id;
        
        String [] aspStatusArray = new List<String>();
		aspStatusArray.add('Granted With Conditions');
        aspStatusArray.add('Granted Unconditionally');
        aspStatusArray.add('Granted With Conditions');
        aspStatusArray.add('Suspended');
        aspStatusArray.add('Cancelled');
        aspStatusArray.add('Refused');
        
    	String aspStatusList = JSON.serialize(aspStatusArray);    
        
        String [] taxiStatusArray = new List<String>();
		taxiStatusArray.add('Suspended');
        taxiStatusArray.add('Cancelled');
        taxiStatusArray.add('Granted');
        
        String taxiStatusList = JSON.serialize(taxiStatusArray);
        
        List < sObject > returnList = new List < sObject > ();
        
        Test.startTest();
        	returnList = customLookUpController.fetchAutorisations(searchKeyWord, ObjectName, ObjectId, aspStatusList, taxiStatusList);           
        Test.stopTest();
        
        for (sObject obj: returnList) {
            Authorisation__c auth = (Authorisation__c)obj;
            if(auth.Authorisation_Type__c == 'BSP' || auth.Authorisation_Type__c == 'TSP'){
				System.assert(auth.Status__c == 'Suspended');
            }else if(auth.Authorisation_Type__c == 'Taxi Licence'){
                System.assert(auth.Status__c == 'Suspended');
            }else{
                //
            }
        }
    }
    
    @isTest
    private static void fetchContactsTest(){
        String searchKeyWord 		= 'test';
        String searchKey 			= searchKeyWord + '%';
        String ObjectName			= 'Contact';
        
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact cont = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert cont;
        
        String ObjectId = ac.Id;
        
        List < sObject > returnList = new List < sObject > ();
        
        Test.startTest();
        	returnList = customLookUpController.fetchContacts(searchKeyWord, ObjectName, ObjectId);           
        Test.stopTest();
        
        for (sObject obj: returnList) {
            Contact con = (Contact)obj;
            system.assert(con.Name == 'testCon');
        }
    }
    
    @isTest
    private static void fetchUsersTest(){
        String searchKeyWord 		= 'shrad';
        String searchKey 			= searchKeyWord + '%';
        String ObjectName			= 'User';
        String ObjectId             = '';
        
        List < sObject > returnList = new List < sObject > ();
        
        Test.startTest();
        	returnList = customLookUpController.fetchUsers(searchKeyWord, ObjectName, ObjectId);           
        Test.stopTest();
        
        for (sObject obj: returnList) {
            User usr = (User)obj;
            system.assert(usr.Name == 'Shraddha Ingle');
        }
    }

}