@isTest
public class CheckUserPermissionTest {
    
    @testSetup 
    static void createAccountAndContact(){
              Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    
   @isTest
    public static void testcheCkObjectReadAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Boolean b;
        
        Schema.DescribeSobjectResult r = Account.SobjectType.getDescribe();
        
        test.startTest();
        System.runAs(user) {
            b = CheckUserPermission.checkObjectReadAccess(r);           
        }
        test.stopTest();
        System.assertEquals(True, b);
        
    }
    
    
    @isTest
    public static void testExceptionCheckObjectReadAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Boolean b;
        
        Schema.DescribeSobjectResult r = null;
        
        test.startTest();
        System.runAs(user) {
            b = CheckUserPermission.checkObjectReadAccess(r);           
        }
        test.stopTest();
        System.assertEquals(False, b);
        
    }
    
    
    @isTest
    public static void testCheckObjectUpdateAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Boolean b;
        
        Schema.DescribeSobjectResult r = Account.SobjectType.getDescribe();
        
        test.startTest();
        System.runAs(user) {
            b = CheckUserPermission.checkObjectUpdateAccess(r);           
        }
        test.stopTest();
        System.assertEquals(True, b);
        
    }
    
    
    @isTest
    public static void testExceptionCheckObjectUpdateAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Boolean b;
        
        Schema.DescribeSobjectResult r = null;
        
        test.startTest();
        System.runAs(user) {
            b = CheckUserPermission.checkObjectUpdateAccess(r);           
        }
        test.stopTest();
        System.assertEquals(False, b);
        
    }
    
    @isTest
    public static void testcheckFieldsReadAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id contactId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id profileId = [select id from profile where name='Account Manager'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        // Get a map of field name and field token
        String objectName = 'Account';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<Schema.DescribeFieldResult> accessibleFields = new List<Schema.DescribeFieldResult>();
        
        if(fMap != null){
            
            for(Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isAccessible()){ // field is accessible
                    accessibleFields.add(fd);
                }
            }
        }
		
        Boolean result;
        test.startTest();
        System.runAs(user) {
            result = CheckUserPermission.checkFieldsReadAccess(accessibleFields);      
        }
        test.stopTest();
        System.assertEquals(true, result);
    }
    
    @isTest
    public static void testExceptioncheckFieldsReadAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id contactId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id profileId = [select id from profile where name='Account Manager'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        // Get a map of field name and field token
        String objectName = 'Account';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<Schema.DescribeFieldResult> accessibleFields = null;
		
        Boolean result;
        test.startTest();
        System.runAs(user) {
            result = CheckUserPermission.checkFieldsReadAccess(accessibleFields);      
        }
        test.stopTest();
        System.assertEquals(false, result);
    }
    
    @isTest
    public static void testcheckFieldsCreateAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id contactId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id profileId = [select id from profile where name='Account Manager'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        // Get a map of field name and field token
        String objectName = 'Account';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<Schema.DescribeFieldResult> creatableFields = new List<Schema.DescribeFieldResult>();
        
        if(fMap != null){
            
            for(Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable() ){ // field is creatable
                    creatableFields.add(fd);
                }
            }
        }
		
        Boolean result;
        test.startTest();
        System.runAs(user) {
            result = CheckUserPermission.checkFieldsCreateAccess(creatableFields);      
        }
        test.stopTest();
        System.assertEquals(true, result);
    }
    
    @isTest
    public static void testExceptioncheckFieldsCreateAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id contactId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id profileId = [select id from profile where name='Account Manager'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        // Get a map of field name and field token
        String objectName = 'Account';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<Schema.DescribeFieldResult> creatableFields = null;
		
        Boolean result;
        test.startTest();
        System.runAs(user) {
            result = CheckUserPermission.checkFieldsCreateAccess(creatableFields);      
        }
        test.stopTest();
        System.assertEquals(false, result);
    }
    
    @isTest
    public static void testcheckFieldsUpdateAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id contactId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id profileId = [select id from profile where name='Account Manager'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        // Get a map of field name and field token
        String objectName = 'Account';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<Schema.DescribeFieldResult> updatabaleFields = new List<Schema.DescribeFieldResult>();
        
        if(fMap != null){
            
            for(Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isUpdateable()){ // field is updatable
                    updatabaleFields.add(fd);
                }
            }
        }
		
        Boolean result;
        test.startTest();
        System.runAs(user) {
            result = CheckUserPermission.checkFieldsUpdateAccess(updatabaleFields);      
        }
        test.stopTest();
        System.assertEquals(true, result);
    }
    
    @isTest
    public static void testExceptioncheckFieldsUpdateAccess(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id contactId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id profileId = [select id from profile where name='Account Manager'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        // Get a map of field name and field token
        String objectName = 'Account';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<Schema.DescribeFieldResult> updatabaleFields = null;
		
        Boolean result;
        test.startTest();
        System.runAs(user) {
            result = CheckUserPermission.checkFieldsUpdateAccess(updatabaleFields);      
        }
        test.stopTest();
        System.assertEquals(false, result);
    }
}