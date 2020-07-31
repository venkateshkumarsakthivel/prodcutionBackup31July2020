/**
* An apex page controller that takes the user to the right start page based on credentials or lack thereof
*/
@IsTest
public with sharing class CommunitiesLandingControllerTest {
    
    @testSetup 
    static void testSetup(){
           Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc',Notice_Email__c = 'test@sample.com', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    
    @IsTest
    public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        CommunitiesLandingController controller = new CommunitiesLandingController();
        PageReference pageRef = controller.forwardToStartPage();
        //PageRef is either null or an empty object in test context
        if(pageRef != null){
            String url = pageRef.getUrl();
            if(url != null){
                System.assertEquals(true, String.isEmpty(url));
                //show up in perforce
            }
        }
    }
    
    // test for forwardTocustomStartPage
    @isTest
    private static void forwardTocustomStartPageASPTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
           
        system.runAs(user){
            CommunitiesLandingController controller = new CommunitiesLandingController();
            PageReference pageRef = controller.forwardTocustomStartPage();
            
            if(pageRef != null){
                String url = pageRef.getUrl();
                if(url != null){
                    System.assertEquals(false, String.isEmpty(url));
                }
            }
        }
        test.stopTest();
    }
    
     // test for forwardTocustomStartPage
    @isTest
    private static void forwardTocustomStartPageTaxiTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        system.runAs(user){
            CommunitiesLandingController controller = new CommunitiesLandingController();
            PageReference pageRef = controller.forwardTocustomStartPage();
            
            if(pageRef != null){
                String url = pageRef.getUrl();
                if(url != null){
                    System.assertEquals(false, String.isEmpty(url));
                }
            }
        }
        test.stopTest();
    }
}