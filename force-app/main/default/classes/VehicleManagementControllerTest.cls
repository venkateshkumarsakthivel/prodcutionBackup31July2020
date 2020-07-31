@isTest
public class VehicleManagementControllerTest {

     @testSetup 
    static void createASPAccountAndContact(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    
    @isTest
    private static void dvdVehicleRecordUpdateTest(){
       Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        List<DVD_Entity__c> insertdvdList = new List<DVD_Entity__c>();
        List<DVD_Entity__c> retrivedvdList = new List<DVD_Entity__c>();
        
        test.startTest();
        system.runAs(user){          
            DVD_Entity__c record = new DVD_Entity__c(Plate_Number__c = 'BB03BB', PLate_Type__c = 'O', VIN_Number_or_Chassis_Number__c = '65E4');
            insertdvdList.add(record);          
            
            insert insertdvdList;
                      
            retrivedvdList = VehicleManagementController.getVehicles();
        }
        test.stopTest();
        
        system.assertEquals(1, retrivedvdList.size());
    }
}